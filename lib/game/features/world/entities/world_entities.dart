/// World Grid System — tiles e objetos genéricos do mundo do jogo.
///
/// Barrel do domínio puro: grid (`GridTile`, `TileObject`) e os objetos de
/// fazenda que vivem sobre ele (`FarmObject`, `CropEntity`).
library;

export 'grid_tile.dart';
export 'objects/farm/crop_entity.dart';
export 'objects/farm/crop_regrow_data.dart';
export 'objects/farm/crop_stage_type.dart';
export 'objects/farm/farm_object.dart';
export 'objects/farm/soil_state.dart';
export 'tile_object.dart';
export 'tile_object_type.dart';
