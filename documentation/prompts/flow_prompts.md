estou criando um clone de stardew valley em Flutter, com a mesmo filosofia de querer entender cada linha de codigo, mas com a ajuda da IA acabo deixando coisas passarem e depois refatoro de todas maneira. sou senior flutter, trabalho com flutter de 2019 ate hj, 2026. mas já estudei por 1 ano unity e unreal e estaria disposto a aprender godot. no flutter encontro algumas barreiras em relacao a UX que outras frameworks entregam prontas. consumi 4 meses com esse meu clone de stardew valley / forager e gostaria de saber se vale a pena continuar com flutter. achei q o desemepnho seria um problema, mas ate entao consigo criar mapas com milhares de componentes vivos e com as estrategias q adotei os fps continuam a 60fps+. me diga os pros e contras de eu utilizar cada framework. estou usando flutter + bonfire + flame. vejo que em unity e unreal possuo atralhos para UX e input actions por exemplo. Mas eu queria um jogo totalmente modularizado e escalavel atraves do uso intensivo de orientacao a objetos, como criar GridTiles e dai possui FarmTiles, MineTiles etc para facilitar a manutencao a longo prazo. vou mandar mais ou menos como esta a arquitetura atual:
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
