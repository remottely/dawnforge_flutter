enum KnightHandSlot { right, left }

extension KnightHandSlotX on KnightHandSlot {
  bool get isRight => this == KnightHandSlot.right;
  bool get isLeft => this == KnightHandSlot.left;

  String get debugLabel => name;
}
