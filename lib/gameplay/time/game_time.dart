import 'time_constants.dart';

/// Represents the in-game clock (hour/minute).
class GameTime {
  final int hour;
  final int minute;

  const GameTime({required this.hour, required this.minute});

  /// Convert to total minutes in day.
  int get totalMinutes => hour * 60 + minute;

  /// Returns a new GameTime advanced by [minutes], wrapping by 24h.
  GameTime addMinutes(int minutes) {
    final total = (totalMinutes + minutes) % (TimeConstants.kHoursPerDay * 60);
    final h = total ~/ 60;
    final m = total % 60;
    return GameTime(hour: h, minute: m);
  }

  GameTime copyWith({int? hour, int? minute}) {
    return GameTime(hour: hour ?? this.hour, minute: minute ?? this.minute);
  }

  Map<String, dynamic> toJson() => {'hour': hour, 'minute': minute};

  static GameTime fromJson(Map<String, dynamic> json) {
    return GameTime(
      hour: json['hour'] as int,
      minute: json['minute'] as int,
    );
  }

  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
