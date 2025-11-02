abstract class DDBaseEnemyModel {
  final double closeVisionRadius;
  final double primaryAttackDamage;
  final int primaryAttackInterval;

  const DDBaseEnemyModel({
    required this.closeVisionRadius,
    required this.primaryAttackDamage,
    required this.primaryAttackInterval,
  });
}
