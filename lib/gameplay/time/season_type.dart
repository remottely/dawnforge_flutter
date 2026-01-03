/// Seasons aligned with Stardew Valley rules.
enum SeasonType { spring, summer, fall, winter; }

extension SeasonTypeJson on SeasonType {
  String toJson() => name;

  static SeasonType fromJson(String value) => SeasonType.values.byName(value);

  SeasonType next() => SeasonType.values[(index + 1) % SeasonType.values.length];
}
