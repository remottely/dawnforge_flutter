# Checklist de Limpeza de developer.log

## Farm Module (refatorado para GameLogger)

- [x] lib/gameplay/farm/usecases/till_soil_use_case.dart — substituído por GameLogger
- [x] lib/gameplay/farm/usecases/water_tile_use_case.dart — substituído por GameLogger
- [x] lib/gameplay/farm/services/crop_factory_service.dart — substituído por GameLogger
- [x] lib/gameplay/farm/services/farm_action_service.dart — substituído por GameLogger

Este documento lista todos os arquivos e linhas do projeto que possuem `developer.log`. Use este checklist para acompanhar a substituição/remover dos logs por `GameLogger`.

## Como usar
- [ ] Marque cada item conforme for revisando/substituindo o log.
- [ ] Adicione observações importantes sobre cada log, se necessário.
- [ ] Ao finalizar, mantenha este arquivo como histórico de manutenção.

---

## Exemplos de arquivos e linhas com developer.log (parcial, revise o projeto para a lista completa):

### lib/shared/framework/player/dd_farm_player/dd_farm_player_controller.dart
- [ ] Linhas: 64, 79, 82, 85, 88, 91, 101, 106, 118, 131, 136, 148, 161, 166, 178, 191, 196, 208

### lib/shared/framework/player/dd_farm_player/dd_farm_player_view.dart
- [ ] Linhas: 107, 112, 135, 169, 174, 197

### lib/shared/framework/player/dd_farm_player/dd_mine_player/dd_mine_player_controller.dart
- [ ] Linhas: 45, 60, 63, 73, 78, 90

### lib/shared/framework/player/dd_farm_player/dd_consumable_player/dd_consumable_player_controller.dart
- [ ] Linhas: 58, 86, 91, 97, 104, 150, 163

### lib/gameplay/inventory/usecases/add_item_use_case.dart
- [ ] Linhas: 30, 33, 75, 94, 114, 119, 133, 135

### lib/gameplay/inventory/state/inventory_state.dart
- [ ] Linhas: 16, 21, 26

### lib/gameplay/inventory/managers/inventory_manager.dart
- [ ] Linhas: 14, 30, 60, 77, 102, 205, 249, 262

### lib/gameplay/inventory/services/item_factory_service.dart
- [ ] Linhas: 29, 61, 67, 78, 110, 113

### lib/gameplay/inventory/state/equipment_state.dart
- [ ] Linhas: 21, 25

### lib/gameplay/inventory/managers/equipment_manager.dart
- [ ] Linhas: 14, 52, 61, 128, 140

### lib/gameplay/inventory/services/item_price_service.dart
- [ ] Linhas: 30, 57, 147

### lib/gameplay/inventory/usecases/remove_item_use_case.dart
- [ ] Linhas: 16, 19, 25, 45, 48

### lib/gameplay/inventory/usecases/load_inventory_use_case.dart
- [ ] Linhas: 30, 44

### lib/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_combat_player_controller.dart
- [ ] Linhas: 41, 46, 60, 75, 80, 94, 111, 121, 126, 129

### lib/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_controller.dart
- [ ] Linha: 35

### lib/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart
- [ ] Linhas: 69, 73, 79, 84

### lib/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_view.dart
- [ ] Linhas: 135, 143, 148, 152

### lib/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart
- [ ] Linhas: 102, 105, 110

### lib/gameplay/farm/usecases/save_farm_use_case.dart
- [ ] Linhas: 20, 34

### lib/gameplay/farm/services/farm_tool_service.dart
- [ ] Linhas: 39, 47, 52, 63, 67, 77, 82

### lib/gameplay/core/modules/hud/inputs/mobile_inputs_state.dart
- [ ] Linhas: 16, 21, 26

### lib/gameplay/farm/handlers/farm_input_handler.dart
- [ ] Linhas: 52, 60, 72, 74, 78, 83, 95, 97, 101

---

> Última atualização: 08/01/2026

(Obs: Para a lista completa, revise todos os matches do grep_search.)
