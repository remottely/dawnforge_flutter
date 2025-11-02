/// Model base abstrato para todos os inimigos.
/// Contém apenas dados e validações simples.
abstract class DDBaseEnemyModel {
  double attackDamage;
  double visionRadius;
  int attackInterval;
  // bool isAttacking;

  DDBaseEnemyModel({
    required this.attackDamage,
    required this.visionRadius,
    required this.attackInterval,
  }); // : isAttacking = false;

  // Validações simples
  // bool get canAttack => !isAttacking;

  // // Mutações de estado
  // void startAttack() => isAttacking = true;
  // void finishAttack() => isAttacking = false;
}
