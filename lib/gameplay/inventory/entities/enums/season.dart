enum SeasonType {
  spring,
  summer,
  fall,
  winter,
  any,
  unknown;

  String toJson() => name;

  static SeasonType fromJson(String json) {
    return SeasonType.values.firstWhere(
      (value) => value.name == json,
      orElse: () => SeasonType.unknown,
    );
  }

  bool matches(SeasonType other) {
    if (this == SeasonType.any || other == SeasonType.any) return true;
    return this == other;
  }

  SeasonType next() =>
      SeasonType.values[(index + 1) % SeasonType.values.length];
}
