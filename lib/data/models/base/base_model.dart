/// Base interface for all data models
abstract class BaseModel {
  /// Unique identifier for the model
  String get id;

  /// Convert model to JSON
  Map<String, dynamic> toJson();

  /// Convert model to Firestore format
  Map<String, dynamic> toFirestore();
}

/// Mixin for models with timestamps
mixin TimestampMixin {
  DateTime? get createdAt;
  DateTime? get updatedAt;
}

/// Mixin for models that can be serialized from/to JSON
mixin SerializableMixin {
  Map<String, dynamic> toJson();
}

/// Mixin for models that can be cached
mixin CacheableMixin {
  String get cacheKey;
  Duration get cacheDuration;
}

/// Mixin for models that support equality comparison
mixin EquatableMixin {
  List<Object?> get props;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other.runtimeType == runtimeType &&
          _propsEqual((other as EquatableMixin).props);

  @override
  int get hashCode => Object.hashAll(props);

  bool _propsEqual(List<Object?> otherProps) {
    if (props.length != otherProps.length) return false;
    for (int i = 0; i < props.length; i++) {
      if (props[i] != otherProps[i]) return false;
    }
    return true;
  }
}

/// Base class for models with common functionality
abstract class BaseDataModel implements BaseModel {
  @override
  final String id;

  const BaseDataModel({required this.id});

  /// Create a copy with modified fields
  BaseDataModel copyWith();

  @override
  String toString() => '$runtimeType(id: $id)';
}

/// Extension for safe parsing from dynamic data
extension SafeParser on Map<String, dynamic> {
  /// Get value with type safety and default value
  T getValue<T>(String key, T defaultValue) {
    try {
      final value = this[key];
      if (value == null) return defaultValue;
      if (value is T) return value;

      // Handle common type conversions
      if (T == String) {
        return value.toString() as T;
      } else if (T == int) {
        if (value is num) return value.toInt() as T;
        if (value is String) return int.tryParse(value) as T? ?? defaultValue;
      } else if (T == double) {
        if (value is num) return value.toDouble() as T;
        if (value is String) {
          return double.tryParse(value) as T? ?? defaultValue;
        }
      } else if (T == bool) {
        if (value is bool) return value as T;
        if (value is String) return (value.toLowerCase() == 'true') as T;
        if (value is num) return (value != 0) as T;
      }

      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Get DateTime value with safe parsing
  DateTime? getDateTime(String key) {
    try {
      final value = this[key];
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get enum value with safe parsing
  T? getEnum<T extends Enum>(String key, List<T> values) {
    try {
      final value = this[key];
      if (value == null) return null;
      if (value is T) return value;
      if (value is String) {
        return values.firstWhere(
          (e) => e.name == value || e.toString() == value,
          orElse: () => values.first,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get list value with type safety
  List<T> getList<T>(String key, [List<T>? defaultValue]) {
    try {
      final value = this[key];
      if (value == null) return defaultValue ?? [];
      if (value is List) {
        return value.whereType<T>().toList();
      }
      return defaultValue ?? [];
    } catch (e) {
      return defaultValue ?? [];
    }
  }

  /// Get map value with type safety
  Map<String, T> getMap<T>(String key, [Map<String, T>? defaultValue]) {
    try {
      final value = this[key];
      if (value == null) return defaultValue ?? {};
      if (value is Map) {
        return Map<String, T>.from(value);
      }
      return defaultValue ?? {};
    } catch (e) {
      return defaultValue ?? {};
    }
  }
}

/// Extension for Firestore timestamp conversion
extension FirestoreTimestamp on DateTime {
  /// Convert to Firestore timestamp format
  Map<String, dynamic> toTimestamp() {
    return {
      '_seconds': millisecondsSinceEpoch ~/ 1000,
      '_nanoseconds': (millisecondsSinceEpoch % 1000) * 1000000,
    };
  }

  /// Create from Firestore timestamp
  static DateTime? fromTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;

    if (timestamp is DateTime) return timestamp;

    if (timestamp is Map) {
      final seconds = timestamp['_seconds'] ?? timestamp['seconds'];
      final nanoseconds =
          timestamp['_nanoseconds'] ?? timestamp['nanoseconds'] ?? 0;
      if (seconds != null) {
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds ~/ 1000000),
        );
      }
    }

    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }

    if (timestamp is String) {
      return DateTime.tryParse(timestamp);
    }

    return null;
  }
}
