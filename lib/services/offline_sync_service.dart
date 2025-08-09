import 'dart:async';
import 'dart:io';
import '../models/cache_metadata.dart';
import '../repositories/post_repository.dart';
import '../repositories/liturgy_repository.dart';
import '../repositories/sermon_repository.dart';
import '../config/environment.dart';
import 'post_service.dart';
import 'liturgy_service.dart';
import 'sermon_service.dart';

/// Service for managing offline synchronization and background sync
class OfflineSyncService {
  final PostRepository _postRepository;
  final LiturgyRepository _liturgyRepository;
  final SermonRepository _sermonRepository;
  final PostService _postService;
  final LiturgyService _liturgyService;
  final SermonService _sermonService;

  // Sync intervals - Use environment-specific values
  static Duration get _defaultSyncInterval => EnvironmentConfig.syncInterval;
  static Duration get _cacheExpiration => EnvironmentConfig.cacheExpiration;

  Timer? _syncTimer;
  bool _isSyncing = false;

  OfflineSyncService({
    PostRepository? postRepository,
    LiturgyRepository? liturgyRepository,
    SermonRepository? sermonRepository,
    PostService? postService,
    LiturgyService? liturgyService,
    SermonService? sermonService,
  }) : _postRepository = postRepository ?? PostRepository(),
       _liturgyRepository = liturgyRepository ?? LiturgyRepository(),
       _sermonRepository = sermonRepository ?? SermonRepository(),
       _postService = postService ?? PostService(),
       _liturgyService = liturgyService ?? LiturgyService(),
       _sermonService = sermonService ?? SermonService();

  /// Start background sync with specified interval
  void startBackgroundSync({Duration? interval}) {
    stopBackgroundSync();

    final syncInterval = interval ?? _defaultSyncInterval;
    _syncTimer = Timer.periodic(syncInterval, (_) {
      syncAll();
    });
  }

  /// Stop background sync
  void stopBackgroundSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Check if currently syncing
  bool get isSyncing => _isSyncing;

  /// Check if device has internet connectivity
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Sync all data types
  Future<SyncResult> syncAll() async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        message: 'Sync already in progress',
        syncedItems: 0,
      );
    }

    if (!await hasInternetConnection()) {
      return SyncResult(
        success: false,
        message: 'No internet connection',
        syncedItems: 0,
      );
    }

    _isSyncing = true;
    int totalSyncedItems = 0;
    final errors = <String>[];

    try {
      // Sync posts
      final postResult = await syncPosts();
      if (postResult.success) {
        totalSyncedItems += postResult.syncedItems;
      } else {
        errors.add('Posts: ${postResult.message}');
      }

      // Sync liturgy events
      final liturgyResult = await syncLiturgyEvents();
      if (liturgyResult.success) {
        totalSyncedItems += liturgyResult.syncedItems;
      } else {
        errors.add('Liturgy: ${liturgyResult.message}');
      }

      // Sync sermons
      final sermonResult = await syncSermons();
      if (sermonResult.success) {
        totalSyncedItems += sermonResult.syncedItems;
      } else {
        errors.add('Sermons: ${sermonResult.message}');
      }

      final success = errors.isEmpty;
      final message =
          success
              ? 'Sync completed successfully'
              : 'Sync completed with errors: ${errors.join(', ')}';

      return SyncResult(
        success: success,
        message: message,
        syncedItems: totalSyncedItems,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Sync failed: $e',
        syncedItems: totalSyncedItems,
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync posts data
  Future<SyncResult> syncPosts() async {
    const cacheKey = 'posts_all';

    try {
      // Check if cache is still valid
      if (await _postRepository.isCacheValid(cacheKey)) {
        return SyncResult(
          success: true,
          message: 'Posts cache is still valid',
          syncedItems: 0,
        );
      }

      await _postRepository.markCacheAsSyncing(cacheKey);

      // Fetch approved posts from API
      final response = await _postService.getPosts();

      // Cache the posts
      await _postRepository.cacheItems(response.posts);

      // Mark cache as successful
      await _postRepository.markCacheAsSuccess(
        cacheKey,
        expiresIn: _cacheExpiration,
      );

      return SyncResult(
        success: true,
        message: 'Posts synced successfully',
        syncedItems: response.posts.length,
      );
    } catch (e) {
      await _postRepository.markCacheAsFailed(cacheKey);
      return SyncResult(
        success: false,
        message: 'Failed to sync posts: $e',
        syncedItems: 0,
      );
    }
  }

  /// Sync liturgy events data
  Future<SyncResult> syncLiturgyEvents() async {
    const cacheKey = 'liturgy_events_all';

    try {
      // Check if cache is still valid
      if (await _liturgyRepository.isCacheValid(cacheKey)) {
        return SyncResult(
          success: true,
          message: 'Liturgy events cache is still valid',
          syncedItems: 0,
        );
      }

      await _liturgyRepository.markCacheAsSyncing(cacheKey);

      // Fetch liturgy events from API
      final events = await _liturgyService.getLiturgyEvents();

      // Cache the events
      await _liturgyRepository.cacheItems(events);

      // Mark cache as successful
      await _liturgyRepository.markCacheAsSuccess(
        cacheKey,
        expiresIn: _cacheExpiration,
      );

      return SyncResult(
        success: true,
        message: 'Liturgy events synced successfully',
        syncedItems: events.length,
      );
    } catch (e) {
      await _liturgyRepository.markCacheAsFailed(cacheKey);
      return SyncResult(
        success: false,
        message: 'Failed to sync liturgy events: $e',
        syncedItems: 0,
      );
    }
  }

  /// Sync sermons data
  Future<SyncResult> syncSermons() async {
    const cacheKey = 'sermons_all';

    try {
      // Check if cache is still valid
      if (await _sermonRepository.isCacheValid(cacheKey)) {
        return SyncResult(
          success: true,
          message: 'Sermons cache is still valid',
          syncedItems: 0,
        );
      }

      await _sermonRepository.markCacheAsSyncing(cacheKey);

      // Fetch sermons from API
      final sermons = await _sermonService.getSermons();

      // Cache the sermons
      await _sermonRepository.cacheItems(sermons);

      // Mark cache as successful
      await _sermonRepository.markCacheAsSuccess(
        cacheKey,
        expiresIn: _cacheExpiration,
      );

      return SyncResult(
        success: true,
        message: 'Sermons synced successfully',
        syncedItems: sermons.length,
      );
    } catch (e) {
      await _sermonRepository.markCacheAsFailed(cacheKey);
      return SyncResult(
        success: false,
        message: 'Failed to sync sermons: $e',
        syncedItems: 0,
      );
    }
  }

  /// Force refresh all cached data
  Future<SyncResult> forceRefreshAll() async {
    // Clear all cache metadata to force refresh
    await _postRepository.clearCache();
    await _liturgyRepository.clearCache();
    await _sermonRepository.clearCache();

    return await syncAll();
  }

  /// Get sync status for all data types
  Future<Map<String, CacheMetadata?>> getSyncStatus() async {
    return {
      'posts': await _postRepository.getCacheMetadata('posts_all'),
      'liturgy': await _liturgyRepository.getCacheMetadata(
        'liturgy_events_all',
      ),
      'sermons': await _sermonRepository.getCacheMetadata('sermons_all'),
    };
  }

  /// Get cache statistics
  Future<CacheStatistics> getCacheStatistics() async {
    final postsCount = await _postRepository.getCachedPostsCount();
    final liturgyCount = await _liturgyRepository.getCachedEventsCount(
      upcomingOnly: false,
    );
    final sermonsCount = await _sermonRepository.getCachedSermonsCount();

    final syncStatus = await getSyncStatus();

    return CacheStatistics(
      postsCount: postsCount,
      liturgyEventsCount: liturgyCount,
      sermonsCount: sermonsCount,
      lastSyncTimes: {
        'posts': syncStatus['posts']?.lastSync,
        'liturgy': syncStatus['liturgy']?.lastSync,
        'sermons': syncStatus['sermons']?.lastSync,
      },
    );
  }

  /// Dispose resources
  void dispose() {
    stopBackgroundSync();
  }
}

/// Result of a sync operation
class SyncResult {
  final bool success;
  final String message;
  final int syncedItems;

  const SyncResult({
    required this.success,
    required this.message,
    required this.syncedItems,
  });

  @override
  String toString() {
    return 'SyncResult(success: $success, message: $message, syncedItems: $syncedItems)';
  }
}

/// Cache statistics for monitoring
class CacheStatistics {
  final int postsCount;
  final int liturgyEventsCount;
  final int sermonsCount;
  final Map<String, DateTime?> lastSyncTimes;

  const CacheStatistics({
    required this.postsCount,
    required this.liturgyEventsCount,
    required this.sermonsCount,
    required this.lastSyncTimes,
  });

  /// Get total cached items count
  int get totalCachedItems => postsCount + liturgyEventsCount + sermonsCount;

  /// Get oldest sync time
  DateTime? get oldestSyncTime {
    final times =
        lastSyncTimes.values.where((time) => time != null).cast<DateTime>();
    if (times.isEmpty) return null;

    return times.reduce((a, b) => a.isBefore(b) ? a : b);
  }

  /// Get newest sync time
  DateTime? get newestSyncTime {
    final times =
        lastSyncTimes.values.where((time) => time != null).cast<DateTime>();
    if (times.isEmpty) return null;

    return times.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  @override
  String toString() {
    return 'CacheStatistics(total: $totalCachedItems, posts: $postsCount, liturgy: $liturgyEventsCount, sermons: $sermonsCount)';
  }
}
