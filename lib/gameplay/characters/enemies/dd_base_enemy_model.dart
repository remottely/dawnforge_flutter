/// Model base abstrato para todos os inimigos.
/// Contém apenas dados e validações simples.
abstract class DDBaseEnemyModel {
  double attackDamage;
  double visionRadius;
  int attackInterval;

  DDBaseEnemyModel({
    required this.attackDamage,
    required this.visionRadius,
    required this.attackInterval,
  });
}
