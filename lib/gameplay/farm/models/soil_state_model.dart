enum SoilStateModel {
  untilled,

  tilled,

  watered,

  fertilized;

  String toJson() => name;

  static SoilStateModel fromJson(String json) => values.byName(json);
}
