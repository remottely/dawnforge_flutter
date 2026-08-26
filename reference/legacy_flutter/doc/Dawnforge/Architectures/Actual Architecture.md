Architecture

global/
- global_input_handler.dart
- global_state_machine.dart
- global_state_ui_overlay.dart

features/
- farm/
- mine/
- inventory/
- 
- characters/
	- enemies/
	- player/
	- npcs/
- database/
	- crop_database.dart
	- material_database.dart
	- seed_bag_database.dart
	- tool_item_database.dart
- decorations/
	- barrel/
	- chest/
	- life_potion/
- world/
	- objects/
	- grid_tile.dart
	- tile_object_type.dart
	- tile_object.dart
- game_world/
- market/
- time/

systems/
- audio/
- camera/
- combat(bonfire entrega pronto)/
- game/
- input_actions/
- localizations/
- map/
- overlay/
- save/
- ui/
- world/
	- map_state_model.dart
	- season.dart
	- world_state_manager.dart


GridTile:
- class FarmTile
- class MineTile
