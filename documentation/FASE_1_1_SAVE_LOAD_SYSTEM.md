# 🎯 FASE 1.1 - Sistema de Save/Load Base

> **Objetivo:** Implementar sistema de persistência multiplataforma com JSON + SharedPreferences
>
> **Prioridade:** 🔴 CRÍTICO (Fundação de tudo)
>
> **Tempo Estimado:** 2-3 dias
>
> **Dependências:** Nenhuma

---

## 📋 Estrutura Final

```
lib/gameplay/core/modules/save/
├── save_manager.dart                 ✅ Singleton, orquestra save/load/delete
├── save_data_model.dart              ✅ Model principal, versionamento
├── save_repository.dart              ✅ Interface abstrata
├── save_repository_native.dart       ✅ Implementação SharedPreferences
└── save_repository_web.dart          ✅ Implementação localStorage

test/gameplay/core/modules/save/
├── save_manager_test.dart            ✅ Testes do singleton
├── save_data_model_test.dart         ✅ Testes de serialização
└── save_repository_test.dart         ✅ Testes de persistência
```

---

## 🚀 PROMPT 1: Criar SaveRepository (Interface + Implementações)

### Contexto

Precisamos de uma camada de abstração para persistência que funcione tanto em Web (localStorage) quanto em Native (SharedPreferences). O Repository Pattern permite trocar a implementação sem afetar o resto do código.

### Prompt para o Claude

```
Crie a estrutura completa do SaveRepository seguindo o padrão Repository com factory multiplataforma:

REQUISITOS TÉCNICOS:
1. Interface abstrata em save_repository.dart
   - Métodos: save(key, data), load(key), delete(key), clear()
   - Factory constructor que retorna Web ou Native baseado em kIsWeb

2. Implementação Native (save_repository_native.dart)
   - Usar SharedPreferences
   - Serializar Map<String, dynamic> para JSON string
   - Tratamento de erro: retornar null se chave não existe
   - Método clear() deve remover apenas keys do jogo (prefixo 'darkness_dungeon_')

3. Implementação Web (save_repository_web.dart)
   - Usar dart:html window.localStorage
   - Mesma interface que Native
   - Validar limite de 5MB (logar warning se próximo)

ESTRUTURA DE ARQUIVOS:
lib/gameplay/core/modules/save/
├── save_repository.dart
├── save_repository_native.dart
└── save_repository_web.dart

PADRÃO DE CÓDIGO:
- Usar 'final class' para implementações (Dart 3.0)
- Async/await para todos os métodos
- Try/catch com logs detalhados
- Documentação Dartdoc em métodos públicos

EXEMPLO DE USO ESPERADO:

final repo = SaveRepository();
await repo.save('player_data', {'name': 'Hero', 'level': 5});
final data = await repo.load('player_data');
print(data); // {name: Hero, level: 5}

CHECKLIST DE VALIDAÇÃO:
[ ] Factory retorna SaveRepositoryWeb em kIsWeb
[ ] Factory retorna SaveRepositoryNative em !kIsWeb
[ ] SharedPreferences inicializado corretamente
[ ] JSON encoding/decoding funciona com Map nested
[ ] Retorna null quando chave não existe
[ ] clear() remove apenas keys do jogo

### Critérios de Aceitação
- [ ] Código compila sem erros
- [ ] Factory funciona em Web e Native
- [ ] Serialização/deserialização JSON funcional
- [ ] Tratamento de erro robusto (não crashea)
- [ ] Documentação completa em Dartdoc
```

---

## 🚀 PROMPT 2: Criar SaveData Model (Serialização + Versionamento)

### Contexto

O SaveData é o model principal que encapsula todos os dados persistentes do jogo. Ele deve ter versionamento para permitir migrações futuras quando adicionarmos novos campos.

### Prompt para o Claude

````

Crie o SaveData model completo com sistema de versionamento e serialização robusta:

REQUISITOS DO MODEL:

1. Campos obrigatórios:

   - int version (sempre = kCurrentVersion, const int = 1)
   - DateTime timestamp (momento do save)
   - Map<String, dynamic> playerData (dados do player)
   - Map<String, dynamic> worldData (estado do mundo)
   - Map<String, dynamic> inventoryData (inventário)

2. Sistema de versionamento:

   - Constante: static const int kCurrentVersion = 1
   - Factory fromJson detecta version antiga e migra automaticamente
   - Método privado: \_migrateFromVersion(int oldVersion, Map json)
   - Se version == null, assume version 1 (save antigo)

3. Serialização:

   - toJson() retorna Map<String, dynamic> completo
   - fromJson(Map<String, dynamic>) com validação de campos obrigatórios
   - copyWith() para modificações imutáveis
   - toString() para debug legível

4. Validação:
   - Validar que playerData não é vazio
   - Validar que timestamp não é futuro (corrupt save)
   - Método isValid() retorna bool

ESTRUTURA DO ARQUIVO:
lib/gameplay/core/modules/save/save_data_model.dart

EXEMPLO DE JSON ESPERADO:

```json
{
  "version": 1,
  "timestamp": "2025-11-14T10:30:00.000Z",
  "playerData": {
    "positionX": 100.0,
    "positionY": 200.0,
    "health": 80,
    "maxHealth": 100
  },
  "worldData": {
    "currentDay": 5,
    "timeOfDay": "morning"
  },
  "inventoryData": {
    "slots": []
  }
}
````

PADRÃO DE CÓDIGO:

- Usar classe imutável (final fields)
- Documentação Dartdoc completa
- Testes de edge cases (version antiga, campos faltando)

CHECKLIST DE VALIDAÇÃO:
[ ] toJson() serializa corretamente todos os campos
[ ] fromJson() deserializa e valida
[ ] Versionamento detecta e migra saves antigos
[ ] isValid() retorna false para save corrompido
[ ] copyWith() permite modificações imutáveis
[ ] toString() é legível para debug

```

### Critérios de Aceitação
- [ ] Serialização bidirecional funciona
- [ ] Versionamento preparado para migrações futuras
- [ ] Validação impede loads de saves corrompidos
- [ ] Código é imutável e seguro
- [ ] Documentação completa

---

## 🚀 PROMPT 3: Criar SaveManager (Singleton + Orquestração)

### Contexto
O SaveManager é o singleton que coordena todas as operações de save/load. Ele usa o SaveRepository internamente e expõe API simples para o resto do jogo.

### Prompt para o Claude

```

Crie o SaveManager singleton que orquestra todo o sistema de persistência:

REQUISITOS DO SINGLETON:

1. Padrão Singleton:

   - Construtor privado: SaveManager.\_()
   - Instance estática: static final instance = SaveManager.\_()
   - Inicialização lazy do repository

2. API Pública:

   - Future<bool> save(SaveData data) → salva e retorna success
   - Future<SaveData?> load() → carrega último save
   - Future<bool> hasSave() → verifica se existe save
   - Future<void> deleteSave() → apaga save
   - Future<void> autoSave() → salva sem bloquear (debounced)

3. Chaves de persistência:

   - const String \_kSaveKey = 'darkness_dungeon_main_save'
   - const String \_kMetadataKey = 'darkness_dungeon_save_metadata'

4. Auto-save debouncing:

   - Timer? \_autoSaveTimer
   - Último save não pode ter sido há menos de 30 segundos
   - Logar quando auto-save acontece

5. Error Handling:

   - Try/catch em todos os métodos async
   - Logar erros detalhados (stack trace)
   - Retornar false/null em erro (não crashea)
   - Método recoverCorruptedSave() para backup

6. Metadata (opcional, mas útil):
   - Salvar metadata separado: { "lastSaveTime", "playTime", "saveCount" }
   - Método getSaveMetadata() para exibir em menu

ESTRUTURA DO ARQUIVO:
lib/gameplay/core/modules/save/save_manager.dart

EXEMPLO DE USO ESPERADO:

```dart
// Salvar
final saveData = SaveData(
  version: SaveData.kCurrentVersion,
  timestamp: DateTime.now(),
  playerData: playerModel.toJson(),
  worldData: worldStateManager.toJson(),
  inventoryData: inventoryManager.toJson(),
);
final success = await SaveManager.instance.save(saveData);

// Carregar
final loadedData = await SaveManager.instance.load();
if (loadedData != null && loadedData.isValid()) {
  // Restaurar estado
}

// Auto-save (não espera)
SaveManager.instance.autoSave();
```

PADRÃO DE CÓDIGO:

- Usar 'final class' (sealed)
- Logs com prefixo [SaveManager]
- Async/await consistente
- Documentação Dartdoc

CHECKLIST DE VALIDAÇÃO:
[ ] Singleton funciona (mesma instância)
[ ] save() retorna true em sucesso
[ ] load() retorna null se não existe save
[ ] autoSave() é debounced (não salva múltiplas vezes seguidas)
[ ] deleteSave() remove todos os dados
[ ] hasSave() retorna bool corretamente
[ ] Error handling não crashea

```

### Critérios de Aceitação
- [ ] Singleton instancia apenas uma vez
- [ ] Todos os métodos async funcionam
- [ ] Auto-save debounced previne spam
- [ ] Error handling robusto
- [ ] Logs claros para debug
- [ ] Documentação completa

---

## 🚀 PROMPT 4: Criar Testes Unitários (Repository + Model + Manager)

### Contexto
Precisamos garantir que o sistema de save/load é robusto com testes automatizados. Isso é crítico pois perder save do jogador é experiência terrível.

### Prompt para o Claude

```

Crie suíte completa de testes unitários para o sistema de save/load:

ARQUIVO 1: test/gameplay/core/modules/save/save_repository_test.dart
TESTES:

1. test_save_and_load_success

   - Salva Map simples
   - Carrega e valida dados idênticos

2. test_load_nonexistent_key_returns_null

   - Tenta carregar chave que não existe
   - Espera null

3. test_delete_removes_key

   - Salva dado
   - Deleta
   - load() retorna null

4. test_clear_removes_only_game_keys

   - Salva múltiplas keys (game + outras)
   - clear() remove apenas game keys
   - Outras keys permanecem

5. test_nested_map_serialization
   - Salva Map com nested Maps e Lists
   - Carrega e valida estrutura intacta

ARQUIVO 2: test/gameplay/core/modules/save/save_data_model_test.dart
TESTES:

1. test_toJson_and_fromJson_roundtrip

   - Cria SaveData
   - toJson() → fromJson()
   - Valida igualdade

2. test_version_migration_from_old_save

   - Cria JSON com version: 0
   - fromJson() migra para version: 1
   - Valida campos novos existem

3. test_isValid_detects_corrupted_save

   - SaveData com playerData vazio → isValid() false
   - timestamp futuro → isValid() false

4. test_copyWith_creates_new_instance
   - copyWith(playerData: novo)
   - Instância original não muda
   - Nova instância tem dados atualizados

ARQUIVO 3: test/gameplay/core/modules/save/save_manager_test.dart
TESTES:

1. test_singleton_returns_same_instance

   - SaveManager.instance == SaveManager.instance

2. test_save_and_load_full_cycle

   - save(saveData) → true
   - load() retorna saveData idêntico

3. test_hasSave_returns_correct_state

   - hasSave() → false (inicial)
   - save() → true
   - hasSave() → true

4. test_deleteSave_removes_all_data

   - save()
   - deleteSave()
   - load() → null

5. test_autoSave_is_debounced

   - Chama autoSave() 3 vezes seguidas
   - Verifica que só 1 save() aconteceu

6. test_load_corrupted_save_returns_null
   - Simula repository.load() retornando JSON inválido
   - load() retorna null (não crashea)

SETUP DOS TESTES:

- Usar mock do SaveRepository (package:mocktail)
- setUp() limpa estado antes de cada teste
- tearDown() reseta singleton (resetForTesting())

PADRÃO DE CÓDIGO:

- Usar matchers do package:test
- expect(actual, equals(expected))
- group() para agrupar testes relacionados
- test() com nomes descritivos

CHECKLIST DE VALIDAÇÃO:
[ ] Todos os testes passam (flutter test)
[ ] Cobertura >= 80% (flutter test --coverage)
[ ] Testes de edge cases incluídos
[ ] Mocks configurados corretamente
[ ] Testes isolados (não dependem de ordem)

```

### Critérios de Aceitação
- [ ] Todos os testes passam em todas as plataformas
- [ ] Cobertura de código >= 80%
- [ ] Testes de erro e edge cases
- [ ] Testes rápidos (< 5 segundos total)
- [ ] Podem rodar em CI/CD

---

## 🚀 PROMPT 5: Integração e Validação End-to-End

### Contexto
Agora que todos os componentes estão criados e testados isoladamente, vamos validar o sistema completo funcionando em conjunto.

### Prompt para o Claude

```

Crie validação end-to-end do sistema de save/load completo:

ARQUIVO: test/gameplay/core/modules/save/save_system_integration_test.dart

TESTE 1: test_full_save_load_cycle_with_all_modules
CENÁRIO:

1. Criar SaveData com dados complexos:

   - playerData: { position, health, inventory }
   - worldData: { day, time, mapStates }
   - inventoryData: { slots com items }

2. Salvar via SaveManager.instance.save()

3. Simular "reiniciar jogo":

   - Resetar todos os managers
   - Carregar via SaveManager.instance.load()

4. Validar que TODOS os dados foram restaurados corretamente

TESTE 2: test_multiple_saves_override_correctly
CENÁRIO:

1. Salvar saveData1
2. Salvar saveData2 (diferente)
3. Carregar
4. Validar que saveData2 foi carregado (não saveData1)

TESTE 3: test_save_survives_app_restart (manual)
INSTRUÇÕES DE TESTE MANUAL:

1. Rodar app
2. Fazer ações (mover player, adicionar item ao inventário)
3. Salvar
4. Fechar app
5. Reabrir app
6. Carregar save
7. Validar que estado foi restaurado

Documentar passo a passo em comentário no arquivo.

TESTE 4: test_corrupted_save_fallback
CENÁRIO:

1. Salvar saveData válido
2. Corromper manualmente (editar SharedPreferences com JSON inválido)
3. Tentar load()
4. Validar que retorna null (não crashea)
5. Validar que recoverCorruptedSave() foi chamado

ADICIONAR SCRIPT DE VALIDAÇÃO:
Criar script bash: scripts/validate_save_system.sh

```bash
#!/bin/bash
echo "🧪 Validando Sistema de Save/Load..."

# Rodar testes unitários
flutter test test/gameplay/core/modules/save/

# Rodar testes de integração
flutter test test/gameplay/core/modules/save/save_system_integration_test.dart

# Checar cobertura
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

echo "✅ Validação completa!"
```

CHECKLIST FINAL:
[ ] Testes de integração passam
[ ] Save sobrevive a restart do app (teste manual)
[ ] Corrupted save não crashea
[ ] Cobertura >= 80%
[ ] Script de validação funciona
[ ] Documentação atualizada em README

```

### Critérios de Aceitação
- [ ] Integração end-to-end funciona
- [ ] Save persiste entre sessões
- [ ] Error recovery funciona
- [ ] Script de validação automatizado
- [ ] Documentação completa

---

## 📊 Checklist de Conclusão da Fase 1.1

### Arquivos Criados
- [ ] `lib/gameplay/core/modules/save/save_repository.dart`
- [ ] `lib/gameplay/core/modules/save/save_repository_native.dart`
- [ ] `lib/gameplay/core/modules/save/save_repository_web.dart`
- [ ] `lib/gameplay/core/modules/save/save_data_model.dart`
- [ ] `lib/gameplay/core/modules/save/save_manager.dart`
- [ ] `test/gameplay/core/modules/save/save_repository_test.dart`
- [ ] `test/gameplay/core/modules/save/save_data_model_test.dart`
- [ ] `test/gameplay/core/modules/save/save_manager_test.dart`
- [ ] `test/gameplay/core/modules/save/save_system_integration_test.dart`
- [ ] `scripts/validate_save_system.sh`

### Funcionalidades Validadas
- [ ] Save funciona em Web e Native
- [ ] Load recupera dados corretamente
- [ ] Versionamento preparado para migrações
- [ ] Auto-save debounced funciona
- [ ] Corrupted save não crashea
- [ ] Testes >= 80% cobertura
- [ ] Documentação completa

### Próximos Passos
1. ✅ Revisar código gerado
2. ✅ Rodar `flutter test` e validar tudo passa
3. ✅ Testar manualmente em Web e Desktop
4. ⏭️ Avançar para **FASE 1.2** - Managers de Estado Global

---

## 🔧 Troubleshooting

### Problema: SharedPreferences não inicializa
**Solução:** Adicionar `WidgetsFlutterBinding.ensureInitialized()` antes de usar

### Problema: localStorage não disponível em Web
**Solução:** Verificar que `kIsWeb` está importado de `foundation.dart`

### Problema: JSON serialization falha com DateTime
**Solução:** Usar `.toIso8601String()` ao serializar, `DateTime.parse()` ao deserializar

### Problema: Testes falham em Web
**Solução:** Rodar `flutter test --platform chrome` para forçar Web

---

**Status:** 📄 Pronto para execução
**Última atualização:** 14/11/2025
```
