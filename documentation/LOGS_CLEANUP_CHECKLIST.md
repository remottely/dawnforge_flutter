# Checklist de Limpeza de Logs

Este documento lista todos os arquivos e linhas do projeto que possuem logs (`print` ou `debugPrint`). Use este checklist para acompanhar a substituição/remover dos logs por `GameLogger` ou para remoção definitiva.

## Como usar
- [ ] Marque cada item conforme for revisando/substituindo o log.
- [ ] Adicione observações importantes sobre cada log, se necessário.
- [ ] Ao finalizar, mantenha este arquivo como histórico de manutenção.

---

## Arquivos e Linhas com Logs

### assets/analyze_assets.dart
- [ ] Linha 5
- [ ] Linha 12
- [ ] Linha 14
- [ ] Linha 17
- [ ] Linha 21
- [ ] Linha 25
- [ ] Linha 28
- [ ] Linha 29
- [ ] Linha 33
- [ ] Linha 34
- [ ] Linha 43
- [ ] Linha 45
- [ ] Linha 53
- [ ] Linha 54
- [ ] Linha 56
- [ ] Linha 61
- [ ] Linha 62
- [ ] Linha 65
- [ ] Linha 213
- [ ] Linha 214
- [ ] Linha 215
- [ ] Linha 216
- [ ] Linha 219
- [ ] Linha 221
- [ ] Linha 223
- [ ] Linha 226
- [ ] Linha 227
- [ ] Linha 228
- [ ] Linha 229

### test_debug.dart
- [ ] Linha 12
- [ ] Linha 15
- [ ] Linha 19
- [ ] Linha 20
- [ ] Linha 21
- [ ] Linha 25
- [ ] Linha 28
- [ ] Linha 29
- [ ] Linha 35
- [ ] Linha 40
- [ ] Linha 43
- [ ] Linha 44

### lib/gameplay/market/widgets/market_panel.dart
- [ ] Linha 58
- [ ] Linha 64
- [ ] Linha 157

### lib/gameplay/market/market_decoration.dart
- [ ] Linha 20
- [ ] Linha 64
- [ ] Linha 76
- [ ] Linha 86
- [ ] Linha 104
- [ ] Linha 113
- [ ] Linha 120
- [ ] Linha 133
- [ ] Linha 145
- [ ] Linha 153
- [ ] Linha 167

### lib/gameplay/gameplay_screen_viewmodel.dart
- [ ] Linha 56
- [ ] Linha 69
- [ ] Linha 72
- [ ] Linha 75
- [ ] Linha 78
- [ ] Linha 81
- [ ] Linha 82
- [ ] Linha 89
- [ ] Linha 116
- [ ] Linha 133
- [ ] Linha 139
- [ ] Linha 180
- [ ] Linha 201

### lib/gameplay/core/modules/hud/inputs/widgets/fullscreen_helper_web.dart
- [ ] Linha 15

### lib/gameplay/core/modules/audio/audio_manager.dart
- [ ] Linha 26
- [ ] Linha 33
- [ ] Linha 41
- [ ] Linha 46
- [ ] Linha 93
- [ ] Linha 102
- [ ] Linha 103
- [ ] Linha 111
- [ ] Linha 118
- [ ] Linha 134
- [ ] Linha 146
- [ ] Linha 150

### lib/gameplay/core/modules/game/game_state_manager.dart
- [ ] Linha 41
- [ ] Linha 47
- [ ] Linha 55
- [ ] Linha 58
- [ ] Linha 65

### lib/shared/framework/enemies/dd_base_enemy/dd_base_enemy_view.dart
- [ ] Linha 302

---

## Logs Comentados (debugPrint)

### lib/gameplay/market/market_decoration copy.dart
- [ ] Linhas: 17, 59, 71, 100, 110, 120, 138, 147, 154, 167, 179, 187, 201

### lib/gameplay/market/market_decoration copy 2.dart
- [ ] Linhas: 17, 59, 71, 100, 110, 120, 138, 147, 154, 167, 179, 187, 201

---

## Exemplos e Documentação (não precisa alterar, apenas referência)
- CLAUDE.md: 191
- documentation/WORLD_GRID_SYSTEM.md: 113, 114
- documentation/DICAS_CUSTO_BENEFICIO.md: 12, 24, 36, 238
- documentation/new/INVENTORY_REFACTORING_MIGRATION_GUIDE.md: 424
- documentation/DICAS_DESEMPENHO.md: 334

---

> Última atualização: 08/01/2026
