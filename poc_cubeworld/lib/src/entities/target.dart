import 'package:vector_math/vector_math.dart';

/// Every body a mob may hunt: the local player and each peer's puppet.
abstract class Target {
  Vector3 get position;
  Vector3 centre();
  bool get isDead;
  void takeDamage(double amount, String source, [Vector3? from]);
}
