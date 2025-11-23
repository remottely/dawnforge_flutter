import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/core/modules/time/time_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/time/time_of_day.dart';
import 'package:darkness_dungeon/gameplay/core/modules/world/world_state_manager.dart';

/// Singleton manager for the game's time system
///
/// Manages the temporal cycle of the game (day/night) and dispatches events
/// when the time period changes. Other systems can register to receive notifications.
///
/// Usage:
/// ```dart
/// // Setup listener
/// TimeManager.instance.addTimeOfDayListener((timeOfDay) {
///   print('Time changed to: $timeOfDay');
/// });
///
/// // Game loop
/// void update(double dt) {
///   TimeManager.instance.update(dt);
/// }
///
/// // Fast forward to night
/// TimeManager.instance.setTime(TimeConfig.nightStartTime);
/// ```
final class TimeManager {
  TimeManager._();

  /// Singleton instance
  static final instance = TimeManager._();

  // ========== STATE ==========

  /// Current time in seconds within the day (0-86400)
  double _currentTime = TimeConfig.morningStartTime; // Start at 6:00 AM

  /// Speed multiplier for time passage (1.0 = normal speed)
  double _timeScale = TimeConfig.defaultTimeScale;

  /// Whether time is paused
  bool _isPaused = false;

  /// Current time of day period
  TimeOfDay _currentTimeOfDay = TimeOfDay.morning;

  /// Callbacks to invoke when time of day changes
  final List<Function(TimeOfDay)> _onTimeOfDayChanged = [];

  // ========== GETTERS ==========

  /// Get current time in seconds
  double get currentTime => _currentTime;

  /// Get current time scale
  double get timeScale => _timeScale;

  /// Check if time is paused
  bool get isPaused => _isPaused;

  /// Get current time of day period
  TimeOfDay get currentTimeOfDay => _currentTimeOfDay;

  /// Get current hour (0-23)
  int get currentHour => (_currentTime / 3600).floor();

  /// Get current minute (0-59)
  int get currentMinute => ((_currentTime % 3600) / 60).floor();

  // ========== TIME PROGRESSION ==========

  /// Update time progression (call from game loop)
  ///
  /// [dt] - Delta time in seconds since last frame
  void update(double dt) {
    if (_isPaused) return;

    final previousTime = _currentTime;
    final previousDay = WorldStateManager.instance.currentDay;

    // Advance time
    _currentTime += dt * _timeScale;

    // Check if we crossed midnight (new day)
    if (previousTime < TimeConfig.secondsPerDay &&
        _currentTime >= TimeConfig.secondsPerDay) {
      developer.log(
        '[TimeManager] New day begins! Advancing to day ${previousDay + 1}',
      );
      WorldStateManager.instance.advanceDay();
    }

    // Wrap time to 24-hour cycle
    _currentTime = _currentTime % TimeConfig.secondsPerDay;

    // Check if time of day changed
    _updateTimeOfDay();
  }

  /// Update the current time of day period and notify listeners if changed
  void _updateTimeOfDay() {
    final newTimeOfDay = _calculateTimeOfDay(_currentTime);

    if (newTimeOfDay != _currentTimeOfDay) {
      final previousTimeOfDay = _currentTimeOfDay;
      _currentTimeOfDay = newTimeOfDay;

      developer.log(
        '[TimeManager] Time of day changed: $previousTimeOfDay -> $newTimeOfDay '
        '(${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')})',
      );

      // Update world state manager
      WorldStateManager.instance.setTimeOfDay(newTimeOfDay);

      // Notify all listeners
      for (final callback in _onTimeOfDayChanged) {
        try {
          callback(newTimeOfDay);
        } catch (e) {
          developer.log(
            '[TimeManager] Error in time of day callback: $e',
            level: 900,
          );
        }
      }
    }
  }

  /// Calculate time of day period based on current time
  TimeOfDay _calculateTimeOfDay(double timeInSeconds) {
    if (timeInSeconds >= TimeConfig.morningStartTime &&
        timeInSeconds < TimeConfig.noonStartTime) {
      return TimeOfDay.morning;
    } else if (timeInSeconds >= TimeConfig.noonStartTime &&
        timeInSeconds < TimeConfig.eveningStartTime) {
      return TimeOfDay.noon;
    } else if (timeInSeconds >= TimeConfig.eveningStartTime &&
        timeInSeconds < TimeConfig.nightStartTime) {
      return TimeOfDay.evening;
    } else {
      return TimeOfDay.night;
    }
  }

  // ========== TIME CONTROL ==========

  /// Set time scale (speed multiplier)
  ///
  /// [scale] - Speed multiplier (1.0 = normal, 2.0 = double speed, 0.5 = half speed)
  void setTimeScale(double scale) {
    if (scale < 0) {
      developer.log(
        '[TimeManager] Warning: Time scale cannot be negative, using absolute value',
        level: 900,
      );
      scale = scale.abs();
    }

    developer.log('[TimeManager] Time scale changed: $_timeScale -> $scale');
    _timeScale = scale;
  }

  /// Pause time progression
  void pause() {
    if (!_isPaused) {
      developer.log('[TimeManager] Time paused');
      _isPaused = true;
    }
  }

  /// Resume time progression
  void resume() {
    if (_isPaused) {
      developer.log('[TimeManager] Time resumed');
      _isPaused = false;
    }
  }

  /// Set time to a specific value
  ///
  /// [timeInSeconds] - Time in seconds (0-86400)
  void setTime(double timeInSeconds) {
    if (timeInSeconds < 0 || timeInSeconds >= TimeConfig.secondsPerDay) {
      developer.log(
        '[TimeManager] Warning: Invalid time value, wrapping to valid range',
        level: 900,
      );
    }

    final previousTime = _currentTime;
    _currentTime = timeInSeconds % TimeConfig.secondsPerDay;

    developer.log(
      '[TimeManager] Time set: ${TimeConfig.secondsToHours(previousTime).toStringAsFixed(2)}h -> '
      '${TimeConfig.secondsToHours(_currentTime).toStringAsFixed(2)}h',
    );

    // Force update time of day
    _updateTimeOfDay();
  }

  /// Get progress through the current day (0.0 to 1.0)
  double getProgress() {
    return _currentTime / TimeConfig.secondsPerDay;
  }

  // ========== CALLBACKS ==========

  /// Add a listener for time of day changes
  ///
  /// [callback] - Function to call when time of day changes
  void addTimeOfDayListener(Function(TimeOfDay) callback) {
    if (!_onTimeOfDayChanged.contains(callback)) {
      _onTimeOfDayChanged.add(callback);
      developer.log(
        '[TimeManager] Time of day listener added (total: ${_onTimeOfDayChanged.length})',
      );
    }
  }

  /// Remove a time of day listener
  ///
  /// [callback] - Function to remove
  void removeTimeOfDayListener(Function(TimeOfDay) callback) {
    if (_onTimeOfDayChanged.remove(callback)) {
      developer.log(
        '[TimeManager] Time of day listener removed (total: ${_onTimeOfDayChanged.length})',
      );
    }
  }

  /// Clear all listeners
  void clearListeners() {
    final count = _onTimeOfDayChanged.length;
    _onTimeOfDayChanged.clear();
    developer.log('[TimeManager] Cleared $count listener(s)');
  }

  // ========== SERIALIZATION ==========

  /// Serialize time state to JSON
  Map<String, dynamic> toJson() {
    return {
      'currentTime': _currentTime,
      'timeScale': _timeScale,
      'isPaused': _isPaused,
      'currentTimeOfDay': _currentTimeOfDay.toJson(),
    };
  }

  /// Deserialize time state from JSON
  void fromJson(Map<String, dynamic> json) {
    developer.log('[TimeManager] Loading time state from JSON');

    _currentTime =
        json['currentTime'] as double? ?? TimeConfig.morningStartTime;
    _timeScale = json['timeScale'] as double? ?? TimeConfig.defaultTimeScale;
    _isPaused = json['isPaused'] as bool? ?? false;
    _currentTimeOfDay = TimeOfDay.fromJson(
      json['currentTimeOfDay'] as String? ?? 'morning',
    );

    developer.log(
      '[TimeManager] Loaded: ${currentHour.toString().padLeft(2, '0')}:'
      '${currentMinute.toString().padLeft(2, '0')}, $_currentTimeOfDay, '
      'scale: $_timeScale, paused: $_isPaused',
    );
  }

  /// Reset time to initial state
  void reset() {
    developer.log('[TimeManager] Resetting time state');
    _currentTime = TimeConfig.morningStartTime;
    _timeScale = TimeConfig.defaultTimeScale;
    _isPaused = false;
    _currentTimeOfDay = TimeOfDay.morning;
    clearListeners();
  }

  @override
  String toString() =>
      'TimeManager(${currentHour.toString().padLeft(2, '0')}:'
      '${currentMinute.toString().padLeft(2, '0')}, $_currentTimeOfDay, '
      'scale: $_timeScale, paused: $_isPaused)';
}
