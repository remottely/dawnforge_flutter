/// Result of a save operation.
///
/// Provides detailed information about the success or failure of a save operation,
/// including error messages and save metadata.
///
/// **Example:**
/// ```dart
/// final result = await SaveManager.instance.saveGame();
///
/// if (result.success) {
///   print('Game saved at ${result.timestamp}');
///   print('Save count: ${result.saveCount}');
/// } else {
///   print('Save failed: ${result.errorMessage}');
/// }
/// ```
final class SaveResult {
  /// Whether the save operation succeeded.
  final bool success;

  /// Error message if save failed (null if success).
  final String? errorMessage;

  /// Timestamp when the save was performed.
  final DateTime? timestamp;

  /// Number of times the game has been saved (incremental).
  final int? saveCount;

  /// Size of the save data in bytes (if available).
  final int? sizeBytes;

  const SaveResult({
    required this.success,
    this.errorMessage,
    this.timestamp,
    this.saveCount,
    this.sizeBytes,
  });

  /// Creates a successful save result.
  factory SaveResult.success({
    required DateTime timestamp,
    int? saveCount,
    int? sizeBytes,
  }) {
    return SaveResult(
      success: true,
      timestamp: timestamp,
      saveCount: saveCount,
      sizeBytes: sizeBytes,
    );
  }

  /// Creates a failed save result.
  factory SaveResult.failure({required String errorMessage}) {
    return SaveResult(success: false, errorMessage: errorMessage);
  }

  @override
  String toString() {
    if (success) {
      return 'SaveResult(success: true, timestamp: $timestamp, '
          'saveCount: $saveCount, sizeBytes: $sizeBytes)';
    } else {
      return 'SaveResult(success: false, error: $errorMessage)';
    }
  }
}

/// Result of a load operation.
///
/// Provides detailed information about the success or failure of a load operation,
/// including the loaded save data and validation status.
///
/// **Example:**
/// ```dart
/// final result = await SaveManager.instance.loadGame();
///
/// if (result.success && result.saveData != null) {
///   print('Game loaded from ${result.saveData!.timestamp}');
///   GameStateCollector.restoreGameState(result.saveData!);
/// } else {
///   print('Load failed: ${result.errorMessage}');
/// }
/// ```
final class LoadResult {
  /// Whether the load operation succeeded.
  final bool success;

  /// Error message if load failed (null if success).
  final String? errorMessage;

  /// The loaded save data (null if failed or not found).
  final dynamic saveData; // Will be SaveData, keeping dynamic for now

  /// Whether the save data was corrupted but recovered.
  final bool wasCorrupted;

  /// Whether the save data was migrated from an older version.
  final bool wasMigrated;

  /// Version of the loaded save data.
  final int? version;

  const LoadResult({
    required this.success,
    this.errorMessage,
    this.saveData,
    this.wasCorrupted = false,
    this.wasMigrated = false,
    this.version,
  });

  /// Creates a successful load result.
  factory LoadResult.success({
    required dynamic saveData,
    bool wasCorrupted = false,
    bool wasMigrated = false,
    int? version,
  }) {
    return LoadResult(
      success: true,
      saveData: saveData,
      wasCorrupted: wasCorrupted,
      wasMigrated: wasMigrated,
      version: version,
    );
  }

  /// Creates a failed load result.
  factory LoadResult.failure({required String errorMessage}) {
    return LoadResult(success: false, errorMessage: errorMessage);
  }

  /// Creates a result for when no save was found.
  factory LoadResult.notFound() {
    return const LoadResult(success: false, errorMessage: 'No save file found');
  }

  @override
  String toString() {
    if (success) {
      return 'LoadResult(success: true, version: $version, '
          'wasCorrupted: $wasCorrupted, wasMigrated: $wasMigrated)';
    } else {
      return 'LoadResult(success: false, error: $errorMessage)';
    }
  }
}

/// Result of a delete operation.
///
/// Provides information about the success or failure of deleting save data.
///
/// **Example:**
/// ```dart
/// final result = await SaveManager.instance.deleteSave();
///
/// if (result.success) {
///   print('Save deleted (${result.keysDeleted} keys removed)');
/// } else {
///   print('Delete failed: ${result.errorMessage}');
/// }
/// ```
final class DeleteResult {
  /// Whether the delete operation succeeded.
  final bool success;

  /// Error message if delete failed (null if success).
  final String? errorMessage;

  /// Number of keys deleted.
  final int keysDeleted;

  const DeleteResult({
    required this.success,
    this.errorMessage,
    this.keysDeleted = 0,
  });

  /// Creates a successful delete result.
  factory DeleteResult.success({int keysDeleted = 0}) {
    return DeleteResult(success: true, keysDeleted: keysDeleted);
  }

  /// Creates a failed delete result.
  factory DeleteResult.failure({required String errorMessage}) {
    return DeleteResult(success: false, errorMessage: errorMessage);
  }

  @override
  String toString() {
    if (success) {
      return 'DeleteResult(success: true, keysDeleted: $keysDeleted)';
    } else {
      return 'DeleteResult(success: false, error: $errorMessage)';
    }
  }
}

/// Result of a validation operation.
///
/// Provides detailed information about save data validation.
///
/// **Example:**
/// ```dart
/// final result = SaveManager.instance.validateSave(saveData);
///
/// if (result.isValid) {
///   print('Save data is valid');
/// } else {
///   print('Validation issues: ${result.issues.join(', ')}');
/// }
/// ```
final class ValidationResult {
  /// Whether the save data is valid.
  final bool isValid;

  /// List of validation issues (empty if valid).
  final List<String> issues;

  /// List of warnings (non-critical issues).
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    this.issues = const [],
    this.warnings = const [],
  });

  /// Creates a valid result.
  factory ValidationResult.valid({List<String> warnings = const []}) {
    return ValidationResult(isValid: true, warnings: warnings);
  }

  /// Creates an invalid result.
  factory ValidationResult.invalid({
    required List<String> issues,
    List<String> warnings = const [],
  }) {
    return ValidationResult(isValid: false, issues: issues, warnings: warnings);
  }

  /// Whether there are any warnings.
  bool get hasWarnings => warnings.isNotEmpty;

  /// Whether there are any issues.
  bool get hasIssues => issues.isNotEmpty;

  @override
  String toString() {
    if (isValid) {
      if (hasWarnings) {
        return 'ValidationResult(valid: true, warnings: ${warnings.length})';
      }
      return 'ValidationResult(valid: true)';
    } else {
      return 'ValidationResult(valid: false, issues: ${issues.length}, '
          'warnings: ${warnings.length})';
    }
  }
}
