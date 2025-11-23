enum CustomPlayerHandSlot { right, left }

extension CustomPlayerHandSlotX on CustomPlayerHandSlot {
  bool get isRight => this == CustomPlayerHandSlot.right;
  bool get isLeft => this == CustomPlayerHandSlot.left;

  String get debugLabel => name;
}
