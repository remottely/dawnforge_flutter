enum Season {
  spring,
  summer,
  fall,
  winter;

  String toJson() => name;

  static Season fromJson(String json) => values.byName(json);

  String get displayName {
    switch (this) {
      case Season.spring:
        return 'Spring';
      case Season.summer:
        return 'Summer';
      case Season.fall:
        return 'Fall';
      case Season.winter:
        return 'Winter';
    }
  }
}
