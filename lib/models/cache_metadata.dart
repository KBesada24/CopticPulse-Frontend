/// Cache metadata model for tracking cache status and sync information
class CacheMetadata {
  final String key;
  final DateTime lastSync;
  final DateTime? expiresAt;
  final CacheSyncStatus syncStatus;

  const CacheMetadata({
    required this.key,
    required this.lastSync,
    this.expiresAt,
    required this.syncStatus,
  });

  /// Creates CacheMetadata from JSON data
  factory CacheMetadata.fromJson(Map<String, dynamic> json) {
    return CacheMetadata(
      key: json['key'] as String,
      lastSync: DateTime.parse(json['last_sync'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      syncStatus: CacheSyncStatus.values.firstWhere(
        (e) => e.name == json['sync_status'],
        orElse: () => CacheSyncStatus.pending,
      ),
    );
  }

  /// Converts CacheMetadata to JSON
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'last_sync': lastSync.toIso8601String(),
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
      'sync_status': syncStatus.name,
    };
  }

  /// Creates a copy of this CacheMetadata with updated fields
  CacheMetadata copyWith({
    String? key,
    DateTime? lastSync,
    DateTime? expiresAt,
    CacheSyncStatus? syncStatus,
  }) {
    return CacheMetadata(
      key: key ?? this.key,
      lastSync: lastSync ?? this.lastSync,
      expiresAt: expiresAt ?? this.expiresAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  /// Returns whether the cache is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Returns whether the cache needs refresh (expired or failed)
  bool get needsRefresh {
    return isExpired || syncStatus == CacheSyncStatus.failed;
  }

  /// Returns age of the cache in minutes
  int get ageInMinutes {
    return DateTime.now().difference(lastSync).inMinutes;
  }

  /// Returns whether the cache is fresh (less than 5 minutes old)
  bool get isFresh {
    return ageInMinutes < 5;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CacheMetadata &&
        other.key == key &&
        other.lastSync == lastSync &&
        other.expiresAt == expiresAt &&
        other.syncStatus == syncStatus;
  }

  @override
  int get hashCode {
    return Object.hash(key, lastSync, expiresAt, syncStatus);
  }

  @override
  String toString() {
    return 'CacheMetadata(key: $key, lastSync: $lastSync, syncStatus: $syncStatus, isExpired: $isExpired)';
  }
}

/// Enum for cache synchronization status
enum CacheSyncStatus {
  pending,
  syncing,
  success,
  failed;

  /// Returns display name for the sync status
  String get displayName {
    switch (this) {
      case CacheSyncStatus.pending:
        return 'Pending';
      case CacheSyncStatus.syncing:
        return 'Syncing';
      case CacheSyncStatus.success:
        return 'Success';
      case CacheSyncStatus.failed:
        return 'Failed';
    }
  }

  /// Returns whether sync is in progress
  bool get isInProgress {
    return this == CacheSyncStatus.syncing;
  }

  /// Returns whether sync was successful
  bool get isSuccessful {
    return this == CacheSyncStatus.success;
  }

  /// Returns whether sync failed
  bool get isFailed {
    return this == CacheSyncStatus.failed;
  }
}