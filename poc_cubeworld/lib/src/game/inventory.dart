import '../core/items.dart';

/// One stack: an item id, a count and (for loot weapons) a random bonus.
class ItemStack {
  ItemStack(this.id, this.count, {this.bonus = 0, this.dur = -1});
  String id;
  int count;
  int bonus;

  /// Stage 23: uses left on a tool or weapon; -1 when never worn (Godot's
  /// absent `dur` key: full).
  int dur;

  ItemStack copy() => ItemStack(id, count, bonus: bonus, dur: dur);

  Map<String, Object> toJson() => {'id': id, 'count': count, if (bonus > 0) 'bonus': bonus, if (dur >= 0) 'dur': dur};
}

/// Slots of ItemStack?. Slot 0..8 is the hotbar.
class Inventory {
  static const int hotbar = 9;
  static const int size = 36;

  final List<ItemStack?> slots = List<ItemStack?>.filled(size, null);
  final List<void Function()> listeners = [];

  void _changed() {
    for (final l in List.of(listeners)) {
      l();
    }
  }

  void emitChanged() => _changed();

  bool isEmptySlot(int i) => slots[i] == null;
  String idAt(int i) => slots[i]?.id ?? '';
  int countAt(int i) => slots[i]?.count ?? 0;
  int bonusAt(int i) => slots[i]?.bonus ?? 0;

  /// Stage 23: uses left on the tool or weapon in slot [i] (the item's maximum
  /// when the stack was never worn), 0 for an item that never wears.
  int durAt(int i) {
    final s = slots[i];
    if (s == null) return 0;
    final maxDur = Items.durabilityOf(s.id);
    if (maxDur <= 0) return 0;
    return s.dur >= 0 ? s.dur : maxDur;
  }

  /// One use of the item in slot [i]; true when it broke (the slot is emptied).
  bool wear(int i, [int uses = 1]) {
    var left = durAt(i);
    if (left <= 0) return false;
    left -= uses;
    if (left <= 0) {
      slots[i] = null;
      _changed();
      return true;
    }
    slots[i]!.dur = left;
    _changed();
    return false;
  }

  int countOf(String id) {
    var total = 0;
    for (final s in slots) {
      if (s != null && s.id == id) total += s.count;
    }
    return total;
  }

  /// Adds up to `count`; returns what did not fit.
  int add(String id, int count) {
    final maxStack = Items.stackSize(id);
    for (final s in slots) {
      if (count <= 0) break;
      if (s != null && s.id == id && s.count < maxStack) {
        final room = maxStack - s.count;
        final take = room < count ? room : count;
        s.count += take;
        count -= take;
      }
    }
    for (var i = 0; i < size; i++) {
      if (count <= 0) break;
      if (slots[i] == null) {
        final take = maxStack < count ? maxStack : count;
        slots[i] = ItemStack(id, take);
        count -= take;
      }
    }
    _changed();
    return count;
  }

  /// How many of [count] [id] would fit right now (stage 25: the host asks
  /// before a pull).
  int roomFor(String id, int count) {
    final maxStack = Items.stackSize(id);
    var room = 0;
    for (final s in slots) {
      if (s == null) {
        room += maxStack;
      } else if (s.id == id) {
        room += maxStack - s.count;
      }
    }
    return room < count ? room : count;
  }

  /// Whether any slot is empty (a bonus item needs one to itself).
  bool get hasEmptySlot => slots.contains(null);

  /// Places a whole stack (with its bonus) in the first empty slot.
  bool addStack(ItemStack stack) {
    for (var i = 0; i < size; i++) {
      if (slots[i] == null) {
        slots[i] = stack.copy();
        _changed();
        return true;
      }
    }
    return false;
  }

  bool remove(String id, int count) {
    if (countOf(id) < count) return false;
    for (var i = size - 1; i >= 0; i--) {
      if (count <= 0) break;
      final s = slots[i];
      if (s != null && s.id == id) {
        final take = s.count < count ? s.count : count;
        s.count -= take;
        count -= take;
        if (s.count <= 0) slots[i] = null;
      }
    }
    _changed();
    return true;
  }

  ItemStack? takeFromSlot(int i, int count) {
    final s = slots[i];
    if (s == null) return null;
    final take = count < s.count ? count : s.count;
    final out = ItemStack(s.id, take, bonus: s.bonus, dur: s.dur);
    s.count -= take;
    if (s.count <= 0) slots[i] = null;
    _changed();
    return out;
  }

  void setSlot(int i, ItemStack? stack) {
    slots[i] = stack?.copy();
    _changed();
  }

  void swap(int a, int b) {
    final t = slots[a];
    slots[a] = slots[b];
    slots[b] = t;
    _changed();
  }

  int find(String id) {
    for (var i = 0; i < size; i++) {
      if (slots[i]?.id == id) return i;
    }
    return -1;
  }

  List<Object> toJson() => [for (final s in slots) s?.toJson() ?? <String, Object>{}];

  void fromJson(List<dynamic> data) {
    for (var i = 0; i < size; i++) {
      final s = i < data.length ? data[i] : null;
      slots[i] = null;
      if (s is Map && s['id'] != null && Items.has(s['id'].toString())) {
        slots[i] = ItemStack(s['id'].toString(), (s['count'] as num).toInt(),
            bonus: s['bonus'] == null ? 0 : (s['bonus'] as num).toInt(),
            dur: s['dur'] == null ? -1 : (s['dur'] as num).toInt());
      }
    }
    _changed();
  }
}
