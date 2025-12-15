enum CropStageModel {
  seed,
  sprout,
  growing,
  mature,
  withered;

  String toJson() => name;

  static CropStageModel fromJson(String json) => values.byName(json);

  bool get canHarvest => this == CropStageModel.mature;

  bool get isDead => this == CropStageModel.withered;
}
