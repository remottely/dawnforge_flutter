final class SaveResult {
  final bool success;

  final String? errorMessage;

  final DateTime? timestamp;

  final int? saveCount;

  final int? sizeBytes;

  const SaveResult({
    required this.success,
    this.errorMessage,
    this.timestamp,
    this.saveCount,
    this.sizeBytes,
  });

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

final class LoadResult {
  final bool success;

  final String? errorMessage;

  final dynamic saveData;

  final bool wasCorrupted;

  final bool wasMigrated;

  final int? version;

  const LoadResult({
    required this.success,
    this.errorMessage,
    this.saveData,
    this.wasCorrupted = false,
    this.wasMigrated = false,
    this.version,
  });

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

  factory LoadResult.failure({required String errorMessage}) {
    return LoadResult(success: false, errorMessage: errorMessage);
  }

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

final class DeleteResult {
  final bool success;

  final String? errorMessage;

  final int keysDeleted;

  const DeleteResult({
    required this.success,
    this.errorMessage,
    this.keysDeleted = 0,
  });

  factory DeleteResult.success({int keysDeleted = 0}) {
    return DeleteResult(success: true, keysDeleted: keysDeleted);
  }

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

final class ValidationResult {
  final bool isValid;

  final List<String> issues;

  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    this.issues = const [],
    this.warnings = const [],
  });

  factory ValidationResult.valid({List<String> warnings = const []}) {
    return ValidationResult(isValid: true, warnings: warnings);
  }

  factory ValidationResult.invalid({
    required List<String> issues,
    List<String> warnings = const [],
  }) {
    return ValidationResult(isValid: false, issues: issues, warnings: warnings);
  }

  bool get hasWarnings => warnings.isNotEmpty;

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
