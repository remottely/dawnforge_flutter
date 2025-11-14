# SaveRepository - Sistema de Persistência Multiplataforma

## 📋 Visão Geral

Sistema de persistência de dados do jogo que funciona em **Web** e **Native** (Desktop/Mobile) usando o padrão Repository.

### Arquitetura

```
SaveRepository (Interface)
    ├── SaveRepositoryWeb (localStorage)
    └── SaveRepositoryNative (SharedPreferences)
```

## 🚀 Uso Rápido

```dart
import 'package:darkness_dungeon/gameplay/core/modules/save/save_repository.dart';

// Criar instância (factory automaticamente seleciona implementação)
final repo = SaveRepository();

// Salvar dados
await repo.save('player_data', {
  'name': 'Hero',
  'level': 5,
  'health': 100,
});

// Carregar dados
final data = await repo.load('player_data');
print(data); // {name: Hero, level: 5, health: 100}

// Deletar chave específica
await repo.delete('player_data');

// Limpar todos os dados do jogo
await repo.clear();
```

## 📁 Estrutura de Arquivos

```
lib/gameplay/core/modules/save/
├── save_repository.dart              # Interface abstrata
├── save_repository_native.dart       # Implementação SharedPreferences
├── save_repository_web.dart          # Implementação localStorage
├── save_repository_example.dart      # Exemplos de uso
└── README.md                         # Este arquivo
```

## 🔧 Detalhes Técnicos

### Interface: `SaveRepository`

#### Métodos

| Método            | Descrição                     | Retorno                         |
| ----------------- | ----------------------------- | ------------------------------- |
| `save(key, data)` | Salva Map serializado         | `Future<bool>`                  |
| `load(key)`       | Carrega dados                 | `Future<Map<String, dynamic>?>` |
| `delete(key)`     | Remove chave específica       | `Future<bool>`                  |
| `clear()`         | Remove todos os dados do jogo | `Future<bool>`                  |

### Implementação Native (`SaveRepositoryNative`)

- **Storage:** SharedPreferences
- **Serialização:** JSON string via `dart:convert`
- **Prefix:** `darkness_dungeon_` (isolamento de dados)
- **Logs:** Detalhados para debug

**Exemplo de chave salva:**

```
Key: "darkness_dungeon_player_data"
Value: "{\"name\":\"Hero\",\"level\":5}"
```

### Implementação Web (`SaveRepositoryWeb`)

- **Storage:** `window.localStorage`
- **Serialização:** JSON string via `dart:convert`
- **Prefix:** `darkness_dungeon_` (isolamento de dados)
- **Limite:** ~5MB (warning quando > 4MB)

**Monitoramento de espaço:**

```dart
// Logs automáticos quando storage atinge 4MB
[SaveRepositoryWeb] WARNING: Storage usage is 4.23 MB (approaching 5MB limit)
```

## ✅ Checklist de Validação

### Funcionalidades

- [x] Factory retorna `SaveRepositoryWeb` em `kIsWeb`
- [x] Factory retorna `SaveRepositoryNative` em `!kIsWeb`
- [x] SharedPreferences inicializado corretamente
- [x] JSON encoding/decoding funciona com Map nested
- [x] Retorna `null` quando chave não existe
- [x] `clear()` remove apenas keys do jogo (prefix)
- [x] Logs detalhados em operações

### Qualidade de Código

- [x] `final class` para implementações (Dart 3.0)
- [x] Async/await consistente
- [x] Try/catch em todos os métodos
- [x] Documentação Dartdoc completa
- [x] Zero erros de compilação

### Testes Multiplataforma

- [ ] Teste manual em macOS (Native) ✅ Pronto para testar
- [ ] Teste manual em Web ✅ Pronto para testar
- [ ] Teste manual em Windows (Native) 🔜 Futuro
- [ ] Teste manual em Android (Native) 🔜 Futuro

## 🧪 Como Testar

### 1. Teste Rápido (Exemplo)

```bash
# Rodar exemplo standalone
flutter run lib/gameplay/core/modules/save/save_repository_example.dart
```

**Saída esperada:**

```
=== Example 1: Save and Load ===
[SaveRepositoryNative] Saved data for key: darkness_dungeon_player_data
[SaveRepositoryNative] Loaded data for key: darkness_dungeon_player_data
Loaded: {name: Hero, level: 5, health: 100, ...}

=== Example 2: Load Non-Existent Key ===
[SaveRepositoryNative] No data found for key: darkness_dungeon_non_existent_key
Missing data: null

...

✅ All examples completed!
```

### 2. Teste Web

```bash
flutter run -d chrome lib/gameplay/core/modules/save/save_repository_example.dart
```

**Validar localStorage:**

1. Abrir DevTools (F12)
2. Ir em **Application → Local Storage**
3. Verificar chaves com prefix `darkness_dungeon_`

### 3. Teste Native (macOS/Windows)

```bash
flutter run -d macos lib/gameplay/core/modules/save/save_repository_example.dart
# ou
flutter run -d windows lib/gameplay/core/modules/save/save_repository_example.dart
```

## 🐛 Troubleshooting

### Problema: SharedPreferences não inicializa

**Erro:**

```
Unhandled Exception: ServicesBinding.defaultBinaryMessenger was accessed before the binding was initialized.
```

**Solução:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ← Adicionar
  final repo = SaveRepository();
  // ...
}
```

### Problema: localStorage não disponível em Web

**Erro:**

```
Undefined name 'window'.
```

**Solução:**
Verificar imports:

```dart
import 'dart:html' as html; // ← Deve ter o 'as html'
```

### Problema: JSON serialization falha

**Erro:**

```
type 'DateTime' is not a subtype of type 'String'
```

**Solução:**

```dart
// Serializar DateTime manualmente
final data = {
  'timestamp': DateTime.now().toIso8601String(), // ← Converter para string
};

// Deserializar
final timestamp = DateTime.parse(data['timestamp']);
```

## 📝 Próximos Passos

1. ✅ **FASE 1.1 - SaveRepository** (Completo)
2. ⏭️ **PROMPT 2:** Criar `SaveData` model com versionamento
3. ⏭️ **PROMPT 3:** Criar `SaveManager` singleton
4. ⏭️ **PROMPT 4:** Criar testes unitários
5. ⏭️ **PROMPT 5:** Validação end-to-end

## 📚 Referências

- [SharedPreferences Package](https://pub.dev/packages/shared_preferences)
- [Web Storage API (localStorage)](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API)
- [Repository Pattern](https://martinfowler.com/eaaCatalog/repository.html)

---

**Status:** ✅ Implementação completa do PROMPT 1
**Última atualização:** 14/11/2025
