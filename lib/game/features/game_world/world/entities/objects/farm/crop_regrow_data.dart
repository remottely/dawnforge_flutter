import 'package:equatable/equatable.dart';

/// Encapsulates regrowth rules and transient state for a crop.
final class CropRegrowData extends Equatable {
  final bool isRegrow;
  final int regrowStageRollback;
  final int regrowStepDays;
  final bool isRegrowing;
  final int daysInStage;

  const CropRegrowData({
    required this.isRegrow,
    required this.regrowStageRollback,
    required this.regrowStepDays,
    required this.isRegrowing,
    required this.daysInStage,
  });

  CropRegrowData copyWith({
    bool? isRegrow,
    int? regrowStageRollback,
    int? regrowStepDays,
    bool? isRegrowing,
    int? daysInStage,
  }) {
    return CropRegrowData(
      isRegrow: isRegrow ?? this.isRegrow,
      regrowStageRollback: regrowStageRollback ?? this.regrowStageRollback,
      regrowStepDays: regrowStepDays ?? this.regrowStepDays,
      isRegrowing: isRegrowing ?? this.isRegrowing,
      daysInStage: daysInStage ?? this.daysInStage,
    );
  }

  CropRegrowData resetState() => copyWith(isRegrowing: false, daysInStage: 0);

  Map<String, dynamic> toJson() {
    return {
      'isRegrow': isRegrow,
      'regrowStageRollback': regrowStageRollback,
      'regrowStepDays': regrowStepDays,
      'isRegrowing': isRegrowing,
      'daysInStage': daysInStage,
    };
  }

  factory CropRegrowData.fromJson(Map<String, dynamic> json) {
    return CropRegrowData(
      isRegrow: json['isRegrow'] as bool,
      regrowStageRollback: json['regrowStageRollback'] as int,
      regrowStepDays: json['regrowStepDays'] as int,
      isRegrowing: json['isRegrowing'] as bool,
      daysInStage: json['daysInStage'] as int,
    );
  }

  @override
  List<Object?> get props => [
    isRegrow,
    regrowStageRollback,
    regrowStepDays,
    isRegrowing,
    daysInStage,
  ];
}
