import 'package:dawnforge/src/core/resources/json_reader.dart';
import 'package:dawnforge/src/core/systems/localization/localization_system.dart';

/// The root of every data class the player can be shown the name of — the Dart
/// port of `ILocalizedResource.cs`.
///
/// It carries the three things identity is made of in this pack: the `id` the
/// content is addressed by, and the two translation KEYS the player is shown
/// instead of it. A name is never authored as text (rule 19); the pack authors
/// a key, pipeline step 05 puts the text for it in every locale table, and
/// [displayName] is where the two meet.
///
/// PORT DELTA — WHAT IS NOT HERE. The spec's `ILocalizedResource` also mints a
/// per-instance `world_id` off the network allocator, and clones itself by
/// reflection over the exported property list. Neither crosses: identity on the
/// wire is the network layer (study D4, unported), and cloning here is the
/// explicit `clone()` every data class already writes, which rule 3 requires be
/// readable rather than derived.
///
/// PORT DELTA — WHO EXTENDS IT. In the spec, `BiomeData` does too. Here it does
/// not, and the pack is the reason: of the 62 generated documents that carry an
/// `id`, the only two that author no `display_name_key` are the biome table and
/// the starting loadout — neither is a thing a player is ever shown the name
/// of. The base goes where the keys are authored.
abstract class ILocalizedData {
  ILocalizedData({
    required this.id,
    this.displayNameKey = '',
    this.descriptionKey = '',
  }) {
    assert(id.isNotEmpty, '[$runtimeType] id cannot be empty');
  }

  ILocalizedData.fromReader(JsonReader reader)
      : id = reader.requiredString('id'),
        displayNameKey = reader.stringOr('display_name_key', ''),
        descriptionKey = reader.stringOr('description_key', '') {
    assert(id.isNotEmpty, '[$runtimeType] id cannot be empty');
  }

  /// What KIND of thing this is, and how content addresses it.
  final String id;

  /// The translation key of the name a player reads. Empty means the document
  /// authored none.
  final String displayNameKey;

  /// The translation key of the longer text a player reads. Empty means the
  /// document authored none, which is an ordinary state — the spec's
  /// `get_description` says so by answering with nothing.
  final String descriptionKey;

  /// The name a player reads, in the player's language.
  ///
  /// A document with no key CRASHES here rather than answering with its id
  /// (rule 5). The spec throws in the same place for the same reason: an id on
  /// screen is not a degraded name, it is a content bug wearing a name's
  /// clothes, and it survives exactly as long as nobody notices.
  ///
  /// PORT DELTA — WHERE THE GUARD SITS. The spec ALSO refuses the empty key at
  /// construction, in `validate()`. Here the guard is at the point of use only,
  /// because construction has a second caller the spec does not have: a test
  /// hands these classes a literal map, and a map that names no content owes no
  /// name. Content itself cannot reach the crash — every document the pipeline
  /// emits for this hierarchy authors the key.
  String get displayName {
    if (displayNameKey.isEmpty) {
      throw StateError('[$runtimeType($id)] no display_name_key authored');
    }
    return tr(displayNameKey);
  }

  /// The longer text, or nothing when the document authored no key. Empty is
  /// the answer, not a fallback: descriptions are optional in the pack and the
  /// spec's `get_description` returns the same emptiness.
  String get description => descriptionKey.isEmpty ? '' : tr(descriptionKey);
}
