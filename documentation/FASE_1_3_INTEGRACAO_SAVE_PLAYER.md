# 🎯 FASE 1.3 - Integração Save ↔ Player

> **Objetivo:** Integrar sistema de persistência com os models do Player existentes
>
> **Prioridade:** 🟡 IMPORTANTE (Conecta fundação com gameplay)
>
> **Tempo Estimado:** 1-2 dias
>
> **Dependências:** Save/Load (1.1), Managers Globais (1.2), PlayerModel existente

---

## 📋 Estrutura Final

```
lib/gameplay/player/
├── player_model.dart              ✅ Já existe - adicionar toJson/fromJson
├── player_attributes.dart         ✅ Já existe - adicionar serialização
├── player_stats.dart              ✅ Já existe - adicionar serialização
└── player_equipment.dart          ✅ Já existe - adicionar serialização

lib/gameplay/core/modules/save/
└── player_save_adapter.dart       ✅ Novo - adaptador Player ↔ SaveData

test/gameplay/core/modules/save/
└── player_save_integration_test.dart  ✅ Teste de integração
```

---

## 🚀 PROMPT 1: Adicionar Serialização ao PlayerModel

### Contexto

O código atual já tem `PlayerModel` mas sem serialização JSON. Precisamos adicionar `toJson()` e `fromJson()` mantendo compatibilidade com código existente.

### Prompt para o Claude

````
Adicione serialização JSON ao PlayerModel existente sem quebrar código:

TAREFAS:

1. Analisar estrutura atual:
   - Ler lib/gameplay/player/player_model.dart
   - Identificar todos os campos
   - Mapear dependências (PlayerAttributes, PlayerStats, etc)

2. Adicionar métodos de serialização:
   - Map<String, dynamic> toJson()
   - factory PlayerModel.fromJson(Map<String, dynamic> json)
   - Serializar todos os campos
   - Deserializar com valores padrão seguros

3. Adicionar serialização a classes dependentes:
   - PlayerAttributes: toJson() / fromJson()
   - PlayerStats: toJson() / fromJson()
   - PlayerEquipment: toJson() / fromJson()
   - Qualquer outra classe usada pelo PlayerModel

4. Manter compatibilidade:
   - NÃO mudar construtores existentes
   - NÃO quebrar código que já usa PlayerModel
   - Adicionar apenas métodos novos

5. Validação de dados:
   - fromJson() deve validar tipos
   - Usar valores padrão se campo não existe
   - Logar warnings se JSON inválido

PADRÃO DE CÓDIGO:
```dart
// Exemplo para PlayerModel
final class PlayerModel {
  // Campos existentes não mudam...

  /// Serializa o player para JSON persistível
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'experience': experience,
      'attributes': attributes.toJson(),
      'stats': stats.toJson(),
      'equipment': equipment?.toJson(),
      // ... todos os campos
    };
  }

  /// Deserializa player de JSON
  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      level: json['level'] as int? ?? 1,
      experience: json['experience'] as int? ?? 0,
      attributes: json['attributes'] != null
        ? PlayerAttributes.fromJson(json['attributes'])
        : PlayerAttributes.initial(),
      // ... todos os campos com valores padrão
    );
  }
}
````

CHECKLIST DE VALIDAÇÃO:
[ ] PlayerModel.toJson() funciona
[ ] PlayerModel.fromJson() funciona
[ ] Roundtrip serialization (toJson → fromJson) mantém dados
[ ] Valores padrão seguros se campo não existe
[ ] Código existente não quebrou
[ ] Todos os sub-models serializam

### Critérios de Aceitação

- [ ] Serialização completa funciona
- [ ] Roundtrip mantém todos os dados
- [ ] Código existente compatível
- [ ] Valores padrão robustos
- [ ] Logs de warning para dados inválidos

```

---

## 🚀 PROMPT 2: Criar PlayerSaveAdapter

### Contexto
Precisamos de um adaptador que converte PlayerModel ↔ SaveData sem acoplamento direto entre os dois sistemas.

### Prompt para o Claude

```

Crie o PlayerSaveAdapter para intermediar Player e SaveManager:

REQUISITOS DO ADAPTER:

1. Conversão Player → SaveData:

   - static SaveData playerToSaveData(PlayerModel player)
   - Coletar dados do player
   - Coletar dados dos managers (World, Time, Progress)
   - Retornar SaveData completo

2. Conversão SaveData → Player:

   - static PlayerModel? saveDataToPlayer(SaveData saveData)
   - Validar saveData.playerData não vazio
   - Deserializar PlayerModel
   - Retornar null se dados corrompidos

3. Restauração completa do jogo:

   - static Future<bool> saveGame(PlayerModel player)
   - Coletar dados de todos os sistemas
   - Chamar SaveManager.save()
   - Retornar sucesso/falha

4. Carregamento completo do jogo:

   - static Future<PlayerModel?> loadGame()
   - Chamar SaveManager.load()
   - Restaurar managers globais
   - Restaurar player
   - Retornar null se não há save

5. Validação e recuperação:
   - Validar integridade dos dados
   - Criar backup antes de sobrescrever save
   - Recuperar de save corrompido se possível

ESTRUTURA DO ARQUIVO:
lib/gameplay/core/modules/save/player_save_adapter.dart

PADRÃO DE CÓDIGO:

```dart
final class PlayerSaveAdapter {
  PlayerSaveAdapter._(); // Prevent instantiation

  /// Salva o jogo completo (player + managers)
  static Future<bool> saveGame(PlayerModel player) async {
    try {
      // 1. Coletar dados do player
      final playerJson = player.toJson();

      // 2. Coletar dados dos managers
      final worldJson = WorldStateManager.instance.toJson();
      final timeJson = TimeManager.instance.toJson();
      final progressJson = PlayerProgressManager.instance.toJson();

      // 3. Combinar tudo em SaveData
      final saveData = SaveData(
        version: SaveData.kCurrentVersion,
        timestamp: DateTime.now(),
        playerData: playerJson,
        worldData: worldJson,
        inventoryData: {}, // Será preenchido na Fase 2
      );

      // 4. Persistir
      return await SaveManager.instance.save(saveData);
    } catch (e, stackTrace) {
      developer.log('[PlayerSaveAdapter] Save failed: $e',
        error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Carrega o jogo completo
  static Future<PlayerModel?> loadGame() async {
    // Implementar lógica completa...
  }

  /// Converte PlayerModel → SaveData (para testes)
  static SaveData playerToSaveData(PlayerModel player) {
    // Implementar...
  }

  /// Converte SaveData → PlayerModel (para testes)
  static PlayerModel? saveDataToPlayer(SaveData saveData) {
    // Implementar...
  }
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] saveGame() persiste player e managers
[ ] loadGame() restaura player e managers
[ ] Validação de dados funciona
[ ] Recuperação de save corrompido funciona
[ ] Logs detalhados

### Critérios de Aceitação

- [ ] Save/load completo funciona
- [ ] Validação robusta
- [ ] Recuperação de erros
- [ ] Logs informativos
- [ ] Código desacoplado

```

---

## 🚀 PROMPT 3: Criar Testes de Integração Player ↔ Save

### Contexto
Precisamos validar que o sistema completo de save/load funciona end-to-end com dados reais do player.

### Prompt para o Claude

```

Crie testes de integração completos para sistema Player ↔ Save:

ARQUIVO: test/gameplay/core/modules/save/player_save_integration_test.dart

TESTES:

1. test_save_and_load_player_roundtrip

   - Criar PlayerModel com dados completos
   - Salvar via PlayerSaveAdapter
   - Carregar via PlayerSaveAdapter
   - Validar todos os campos são iguais

2. test_save_includes_world_state

   - Configurar WorldStateManager (dia, estação, mapas)
   - Salvar via PlayerSaveAdapter
   - Carregar e validar world state restaurado

3. test_save_includes_time_state

   - Configurar TimeManager (hora atual, período)
   - Salvar via PlayerSaveAdapter
   - Carregar e validar time state restaurado

4. test_save_includes_progress_state

   - Configurar PlayerProgressManager (flags, conquistas)
   - Salvar via PlayerSaveAdapter
   - Carregar e validar progress restaurado

5. test_load_returns_null_if_no_save

   - Deletar todos os saves
   - loadGame() retorna null

6. test_load_handles_corrupted_save

   - Criar save corrompido (JSON inválido)
   - loadGame() retorna null sem crash
   - Log de erro emitido

7. test_save_creates_backup

   - Salvar jogo
   - Salvar novamente
   - Validar que backup do save anterior existe

8. test_multiple_saves_override_correctly

   - Salvar player nível 1
   - Salvar player nível 2
   - Carregar e validar nível 2

9. test_serialization_handles_missing_fields

   - Criar SaveData sem campo opcional
   - fromJson() usa valor padrão

10. test_serialization_handles_invalid_types
    - Criar SaveData com tipo errado
    - fromJson() usa valor padrão ou falha gracefully

SETUP DOS TESTES:

```dart
void main() {
  late PlayerModel testPlayer;

  setUp(() async {
    // Reset managers
    WorldStateManager.instance.reset();
    TimeManager.instance.reset();
    PlayerProgressManager.instance.reset();

    // Limpar saves
    await SaveManager.instance.deleteSave();

    // Criar player de teste
    testPlayer = PlayerModel(
      id: 'test_player',
      name: 'Test Hero',
      level: 5,
      experience: 1250,
      // ... todos os campos
    );
  });

  tearDown(() async {
    await SaveManager.instance.deleteSave();
  });

  group('Player Save Integration', () {
    test('save_and_load_player_roundtrip', () async {
      // Teste...
    });
  });
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] Todos os testes passam
[ ] Cobertura >= 80%
[ ] Testes rápidos (< 10 segundos)
[ ] Edge cases cobertos

### Critérios de Aceitação

- [ ] Todos os testes passam
- [ ] Integração completa validada
- [ ] Edge cases cobertos
- [ ] Performance adequada

```

---

## 🚀 PROMPT 4: Integrar Auto-Save no Game Loop

### Contexto
Agora que tudo funciona, precisamos integrar auto-save automático no loop principal do jogo.

### Prompt para o Claude

```

Integre auto-save automático ao game loop principal:

TAREFAS:

1. Identificar arquivo de game loop:

   - Procurar por classe que herda de BonfireGame
   - Identificar método update()

2. Adicionar lógica de auto-save:

   - Chamar PlayerSaveAdapter.saveGame() periodicamente
   - Usar debouncing para evitar saves excessivos
   - Salvar em eventos importantes (level up, area change, etc)

3. Feedback visual de save:

   - Mostrar ícone de "salvando..." no UI
   - Mostrar ícone de "save concluído"
   - Avisar se save falhou

4. Configuração de auto-save:

   - Criar SaveConfig com intervalo de auto-save
   - Permitir desabilitar auto-save (para speedruns)
   - Salvar em eventos críticos mesmo se auto-save desabilitado

5. Salvar em eventos importantes:
   - Antes de boss fight
   - Após level up
   - Ao trocar de área
   - Ao entrar/sair de casa

PADRÃO DE CÓDIGO:

```dart
// No game loop principal
@override
void update(double dt) {
  super.update(dt);

  // Auto-save periódico
  _autoSaveTimer += dt;
  if (_autoSaveTimer >= SaveConfig.autoSaveInterval) {
    _autoSaveTimer = 0;
    _triggerAutoSave();
  }
}

Future<void> _triggerAutoSave() async {
  if (!SaveConfig.autoSaveEnabled) return;

  final player = getCurrentPlayer(); // Pegar player atual
  if (player == null) return;

  // Show saving indicator
  showSavingIndicator();

  final success = await PlayerSaveAdapter.saveGame(player);

  if (success) {
    showSaveSuccessIndicator();
  } else {
    showSaveFailedWarning();
  }
}

// Salvar em evento crítico
void onPlayerLevelUp() {
  // ... lógica de level up

  // Salvar imediatamente
  _triggerAutoSave();
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] Auto-save funciona periodicamente
[ ] Debouncing evita saves excessivos
[ ] Feedback visual funciona
[ ] Saves em eventos críticos funcionam
[ ] Configuração funciona

### Critérios de Aceitação

- [ ] Auto-save integrado ao game loop
- [ ] Feedback visual funcional
- [ ] Performance não afetada
- [ ] Saves em eventos críticos funcionam
- [ ] Configuração flexível

```

---

## 🚀 PROMPT 5: Documentação e Exemplos de Uso

### Contexto
Criar documentação completa para que desenvolvedores entendam como usar o sistema de save/load.

### Prompt para o Claude

```

Crie documentação completa do sistema de Save/Load:

ARQUIVO 1: lib/gameplay/core/modules/save/README.md

SEÇÕES:

1. Visão Geral

   - O que é o sistema de save/load
   - Arquitetura (Repository → Model → Manager → Adapter)
   - Diagrama de fluxo

2. Guia de Uso Rápido

   - Como salvar jogo: PlayerSaveAdapter.saveGame()
   - Como carregar jogo: PlayerSaveAdapter.loadGame()
   - Como verificar save existente: SaveManager.instance.hasSave()

3. Guia Avançado

   - Customizar frequência de auto-save
   - Desabilitar auto-save
   - Acessar dados de save diretamente
   - Criar múltiplos slots de save (feature futura)

4. Troubleshooting

   - Save não funciona: verificar permissões
   - Save corrompido: recuperação automática
   - Performance: debouncing configurado

5. API Reference
   - PlayerSaveAdapter (métodos públicos)
   - SaveManager (métodos públicos)
   - SaveData (estrutura)

ARQUIVO 2: lib/gameplay/core/modules/save/EXAMPLES.md

EXEMPLOS:

1. Salvar jogo manualmente
2. Carregar jogo na tela de título
3. Auto-save periódico
4. Salvar antes de boss fight
5. Verificar se há save antes de "Continue"
6. Recuperar de save corrompido
7. Migrar save de versão antiga

ARQUIVO 3: lib/gameplay/core/modules/save/MIGRATION_GUIDE.md

GUIA DE MIGRAÇÃO:

1. Como adicionar novos campos ao PlayerModel
2. Como migrar saves de versão antiga
3. Como manter compatibilidade retroativa
4. Como testar migrações

CHECKLIST DE VALIDAÇÃO:
[ ] README completo e claro
[ ] Exemplos funcionam
[ ] Guia de migração útil
[ ] API reference completa

### Critérios de Aceitação

- [ ] Documentação completa
- [ ] Exemplos funcionais
- [ ] Guias úteis
- [ ] Fácil de entender

```

---

## 📊 Checklist de Conclusão da Fase 1.3

### Arquivos Modificados
- [ ] `lib/gameplay/player/player_model.dart` (+ toJson/fromJson)
- [ ] `lib/gameplay/player/player_attributes.dart` (+ toJson/fromJson)
- [ ] `lib/gameplay/player/player_stats.dart` (+ toJson/fromJson)
- [ ] `lib/gameplay/player/player_equipment.dart` (+ toJson/fromJson)

### Arquivos Criados
- [ ] `lib/gameplay/core/modules/save/player_save_adapter.dart`
- [ ] `lib/gameplay/core/modules/save/README.md`
- [ ] `lib/gameplay/core/modules/save/EXAMPLES.md`
- [ ] `lib/gameplay/core/modules/save/MIGRATION_GUIDE.md`
- [ ] `test/gameplay/core/modules/save/player_save_integration_test.dart`

### Funcionalidades Validadas
- [ ] PlayerModel serializa corretamente
- [ ] PlayerSaveAdapter funciona
- [ ] Auto-save integrado
- [ ] Testes de integração passam
- [ ] Documentação completa

### Próximos Passos
1. ✅ Revisar código gerado
2. ✅ Rodar `flutter test` e validar >= 80% cobertura
3. ✅ Testar auto-save manualmente
4. ⏭️ Avançar para **FASE 2.1** - Sistema de Inventário

---

## 🔧 Troubleshooting

### Problema: PlayerModel.fromJson() retorna null
**Solução:** Validar que JSON tem todos os campos obrigatórios, usar valores padrão

### Problema: Save não persiste após restart
**Solução:** Verificar que SharedPreferences foi inicializado corretamente

### Problema: Auto-save causa lag
**Solução:** Aumentar intervalo de auto-save ou mover para isolate

---

**Status:** 📄 Pronto para execução
**Última atualização:** 14/11/2025
```
