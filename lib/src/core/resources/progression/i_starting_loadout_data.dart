import 'package:dawnforge/src/core/resources/items/item_amount.dart';
import 'package:dawnforge/src/core/resources/json_reader.dart';

/// What a brand-new player starts a world with — the Dart port of
/// `i_starting_loadout_data.gd`: a list of item lines and an XP grant, read
/// from `games/<game>/data/progression/<id>.md` through pipeline step 26.
///
/// It is not a world object and owns no state: a loadout is granted once and
/// forgotten, so there is no clone and nothing to serialize. Both fields are
/// REQUIRED in the pack (step 26 refuses a document that omits either) — an
/// empty list is a real answer, absence is not.
final class IStartingLoadoutData {
  IStartingLoadoutData({
    required this.id,
    required this.entries,
    required this.grantedXp,
  }) : assert(id != '', '[IStartingLoadoutData] empty id'),
       assert(grantedXp >= 0, '[IStartingLoadoutData($id)] negative XP');

  factory IStartingLoadoutData.fromJson(Map<String, Object?> json) {
    final reader = JsonReader(json, 'IStartingLoadoutData');
    return IStartingLoadoutData(
      id: reader.requiredString('id'),
      // `ItemAmount` asserts each line's two fields on the way in — the
      // spec's `validate()` loop, done by the type instead of by a walk.
      entries: reader
          .requiredObjectList('entries')
          .map(ItemAmount.fromJson)
          .toList(),
      grantedXp: reader.requiredInt('granted_xp'),
    );
  }

  final String id;

  /// What is granted, in order. Empty means the player starts with nothing.
  final List<ItemAmount> entries;

  /// XP granted alongside. Progression is FP7.5; until it lands a loadout
  /// that authors any is refused by `StartingLoadoutRules`, not ignored.
  final int grantedXp;
}
