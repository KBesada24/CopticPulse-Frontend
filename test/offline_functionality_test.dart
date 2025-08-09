import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:coptic_pulse/models/post.dart';
import 'package:coptic_pulse/models/liturgy_event.dart';
import 'package:coptic_pulse/models/sermon.dart';
import 'package:coptic_pulse/models/cache_metadata.dart';
import 'package:coptic_pulse/repositories/post_repository.dart';
import 'package:coptic_pulse/repositories/liturgy_repository.dart';
import 'package:coptic_pulse/repositories/sermon_repository.dart';
import 'package:coptic_pulse/services/offline_sync_service.dart';
import 'package:coptic_pulse/services/post_service.dart';
import 'package:coptic_pulse/services/liturgy_service.dart';
import 'package:coptic_pulse/services/sermon_service.dart';
import 'package:coptic_pulse/database/database_helper.dart';

// Generate mocks
@GenerateMocks([
  PostRepository,
  LiturgyRepository,
  SermonRepository,
  PostService,
  LiturgyService,
  SermonService,
  DatabaseHelper,
])
import 'offline_functionality_test.mocks.dart';

void main() {
  group('Offline Functionality Tests', () {
    late MockPostRepository mockPostRepository;
    late MockLiturgyRepository mockLiturgyRepository;
    late MockSermonRepository mockSermonRepository;
    late MockPostService mockPostService;
    late MockLiturgyService mockLiturgyService;
    late MockSermonService mockSermonService;
    late OfflineSyncService offlineSyncService;

    setUp(() {
      mockPostRepository = MockPostRepository();
      mockLiturgyRepository = MockLiturgyRepository();
      mockSermonRepository = MockSermonRepository();
      mockPostService = MockPostService();
      mockLiturgyService = MockLiturgyService();
      mockSermonService = MockSermonService();

      offlineSyncService = OfflineSyncService(
        postRepository: mockPostRepository,
        liturgyRepository: mockLiturgyRepository,
        sermonRepository: mockSermonRepository,
        postService: mockPostService,
        liturgyService: mockLiturgyService,
        sermonService: mockSermonService,
      );
    });

    group('Cache Metadata Tests', () {
      test('should create cache metadata with correct properties', () {
        final now = DateTime.now();
        final expiresAt = now.add(const Duration(hours: 1));

        final metadata = CacheMetadata(
          key: 'test_key',
          lastSync: now,
          expiresAt: expiresAt,
          syncStatus: CacheSyncStatus.success,
        );

        expect(metadata.key, equals('test_key'));
        expect(metadata.lastSync, equals(now));
        expect(metadata.expiresAt, equals(expiresAt));
        expect(metadata.syncStatus, equals(CacheSyncStatus.success));
        expect(metadata.syncStatus.isSuccessful, isTrue);
        expect(metadata.isExpired, isFalse);
      });

      test('should detect expired cache', () {
        final pastTime = DateTime.now().subtract(const Duration(hours: 2));
        final metadata = CacheMetadata(
          key: 'test_key',
          lastSync: pastTime,
          expiresAt: pastTime.add(const Duration(hours: 1)),
          syncStatus: CacheSyncStatus.success,
        );

        expect(metadata.isExpired, isTrue);
        expect(metadata.needsRefresh, isTrue);
      });

      test('should convert to and from JSON correctly', () {
        final now = DateTime.now();
        final metadata = CacheMetadata(
          key: 'test_key',
          lastSync: now,
          syncStatus: CacheSyncStatus.success,
        );

        final json = metadata.toJson();
        final fromJson = CacheMetadata.fromJson(json);

        expect(fromJson.key, equals(metadata.key));
        expect(fromJson.lastSync, equals(metadata.lastSync));
        expect(fromJson.syncStatus, equals(metadata.syncStatus));
      });
    });

    group('Post Repository Tests', () {
      test('should cache posts correctly', () async {
        final posts = [
          Post(
            id: '1',
            title: 'Test Post',
            content: 'Test Content',
            type: PostType.announcement,
            status: PostStatus.approved,
            authorId: 'author1',
            createdAt: DateTime.now(),
          ),
        ];

        when(mockPostRepository.cacheItems(posts)).thenAnswer((_) async => {});

        await mockPostRepository.cacheItems(posts);

        verify(mockPostRepository.cacheItems(posts)).called(1);
      });

      test('should retrieve cached posts by type', () async {
        final posts = [
          Post(
            id: '1',
            title: 'Announcement',
            content: 'Test Content',
            type: PostType.announcement,
            status: PostStatus.approved,
            authorId: 'author1',
            createdAt: DateTime.now(),
          ),
        ];

        when(
          mockPostRepository.getCachedPostsByType(PostType.announcement),
        ).thenAnswer((_) async => posts);

        final result = await mockPostRepository.getCachedPostsByType(
          PostType.announcement,
        );

        expect(result, equals(posts));
        verify(
          mockPostRepository.getCachedPostsByType(PostType.announcement),
        ).called(1);
      });

      test('should get cached posts count', () async {
        when(
          mockPostRepository.getCachedPostsCount(),
        ).thenAnswer((_) async => 5);

        final count = await mockPostRepository.getCachedPostsCount();

        expect(count, equals(5));
        verify(mockPostRepository.getCachedPostsCount()).called(1);
      });
    });

    group('Liturgy Repository Tests', () {
      test('should cache liturgy events correctly', () async {
        final events = [
          LiturgyEvent(
            id: '1',
            title: 'Sunday Service',
            dateTime: DateTime.now().add(const Duration(days: 1)),
            location: 'Main Church',
            serviceType: 'Divine Liturgy',
          ),
        ];

        when(
          mockLiturgyRepository.cacheItems(events),
        ).thenAnswer((_) async => {});

        await mockLiturgyRepository.cacheItems(events);

        verify(mockLiturgyRepository.cacheItems(events)).called(1);
      });

      test('should retrieve upcoming events', () async {
        final upcomingEvents = [
          LiturgyEvent(
            id: '1',
            title: 'Sunday Service',
            dateTime: DateTime.now().add(const Duration(days: 1)),
            location: 'Main Church',
            serviceType: 'Divine Liturgy',
          ),
        ];

        when(
          mockLiturgyRepository.getCachedUpcomingEvents(),
        ).thenAnswer((_) async => upcomingEvents);

        final result = await mockLiturgyRepository.getCachedUpcomingEvents();

        expect(result, equals(upcomingEvents));
        verify(mockLiturgyRepository.getCachedUpcomingEvents()).called(1);
      });
    });

    group('Sermon Repository Tests', () {
      test('should cache sermons correctly', () async {
        final sermons = [
          Sermon(
            id: '1',
            title: 'Test Sermon',
            description: 'Test Description',
            publishedAt: DateTime.now(),
            speaker: 'Father John',
          ),
        ];

        when(
          mockSermonRepository.cacheItems(sermons),
        ).thenAnswer((_) async => {});

        await mockSermonRepository.cacheItems(sermons);

        verify(mockSermonRepository.cacheItems(sermons)).called(1);
      });

      test('should search cached sermons', () async {
        final sermons = [
          Sermon(
            id: '1',
            title: 'Christmas Sermon',
            description: 'About Christmas',
            publishedAt: DateTime.now(),
            speaker: 'Father John',
          ),
        ];

        when(
          mockSermonRepository.searchCachedSermons('Christmas'),
        ).thenAnswer((_) async => sermons);

        final result = await mockSermonRepository.searchCachedSermons(
          'Christmas',
        );

        expect(result, equals(sermons));
        verify(mockSermonRepository.searchCachedSermons('Christmas')).called(1);
      });
    });

    group('Offline Sync Service Tests', () {
      test('should sync posts successfully', () async {
        final posts = [
          Post(
            id: '1',
            title: 'Test Post',
            content: 'Test Content',
            type: PostType.announcement,
            status: PostStatus.approved,
            authorId: 'author1',
            createdAt: DateTime.now(),
          ),
        ];

        final postResponse = PostResponse(
          posts: posts,
          totalCount: 1,
          currentPage: 1,
          totalPages: 1,
          hasNextPage: false,
          hasPreviousPage: false,
        );

        when(
          mockPostRepository.isCacheValid('posts_all'),
        ).thenAnswer((_) async => false);
        when(
          mockPostRepository.markCacheAsSyncing('posts_all'),
        ).thenAnswer((_) async => {});
        when(mockPostService.getPosts()).thenAnswer((_) async => postResponse);
        when(mockPostRepository.cacheItems(posts)).thenAnswer((_) async => {});
        when(
          mockPostRepository.markCacheAsSuccess(
            'posts_all',
            expiresIn: anyNamed('expiresIn'),
          ),
        ).thenAnswer((_) async => {});

        final result = await offlineSyncService.syncPosts();

        expect(result.success, isTrue);
        expect(result.syncedItems, equals(1));
        verify(mockPostService.getPosts()).called(1);
        verify(mockPostRepository.cacheItems(posts)).called(1);
      });

      test('should handle sync failure gracefully', () async {
        when(
          mockPostRepository.isCacheValid('posts_all'),
        ).thenAnswer((_) async => false);
        when(
          mockPostRepository.markCacheAsSyncing('posts_all'),
        ).thenAnswer((_) async => {});
        when(mockPostService.getPosts()).thenThrow(Exception('Network error'));
        when(
          mockPostRepository.markCacheAsFailed('posts_all'),
        ).thenAnswer((_) async => {});

        final result = await offlineSyncService.syncPosts();

        expect(result.success, isFalse);
        expect(result.message, contains('Failed to sync posts'));
        verify(mockPostRepository.markCacheAsFailed('posts_all')).called(1);
      });

      test('should skip sync if cache is valid', () async {
        when(
          mockPostRepository.isCacheValid('posts_all'),
        ).thenAnswer((_) async => true);

        final result = await offlineSyncService.syncPosts();

        expect(result.success, isTrue);
        expect(result.message, contains('cache is still valid'));
        expect(result.syncedItems, equals(0));
        verifyNever(mockPostService.getPosts());
      });

      test('should get cache statistics', () async {
        when(
          mockPostRepository.getCachedPostsCount(),
        ).thenAnswer((_) async => 10);
        when(
          mockLiturgyRepository.getCachedEventsCount(upcomingOnly: false),
        ).thenAnswer((_) async => 5);
        when(
          mockSermonRepository.getCachedSermonsCount(),
        ).thenAnswer((_) async => 8);

        final mockMetadata = CacheMetadata(
          key: 'posts_all',
          lastSync: DateTime.now(),
          syncStatus: CacheSyncStatus.success,
        );

        when(
          mockPostRepository.getCacheMetadata('posts_all'),
        ).thenAnswer((_) async => mockMetadata);
        when(
          mockLiturgyRepository.getCacheMetadata('liturgy_events_all'),
        ).thenAnswer((_) async => mockMetadata);
        when(
          mockSermonRepository.getCacheMetadata('sermons_all'),
        ).thenAnswer((_) async => mockMetadata);

        final stats = await offlineSyncService.getCacheStatistics();

        expect(stats.postsCount, equals(10));
        expect(stats.liturgyEventsCount, equals(5));
        expect(stats.sermonsCount, equals(8));
        expect(stats.totalCachedItems, equals(23));
      });
    });

    group('Cache Invalidation Tests', () {
      test('should clear all caches', () async {
        when(mockPostRepository.clearCache()).thenAnswer((_) async => {});
        when(mockLiturgyRepository.clearCache()).thenAnswer((_) async => {});
        when(mockSermonRepository.clearCache()).thenAnswer((_) async => {});

        await offlineSyncService.forceRefreshAll();

        verify(mockPostRepository.clearCache()).called(1);
        verify(mockLiturgyRepository.clearCache()).called(1);
        verify(mockSermonRepository.clearCache()).called(1);
      });

      test('should handle cache expiration correctly', () {
        final expiredTime = DateTime.now().subtract(const Duration(hours: 2));
        final metadata = CacheMetadata(
          key: 'test_key',
          lastSync: expiredTime,
          expiresAt: expiredTime.add(const Duration(hours: 1)),
          syncStatus: CacheSyncStatus.success,
        );

        expect(metadata.isExpired, isTrue);
        expect(metadata.needsRefresh, isTrue);
      });

      test('should handle failed cache status', () {
        final metadata = CacheMetadata(
          key: 'test_key',
          lastSync: DateTime.now(),
          syncStatus: CacheSyncStatus.failed,
        );

        expect(metadata.needsRefresh, isTrue);
        expect(metadata.syncStatus.isFailed, isTrue);
      });
    });

    group('Background Sync Tests', () {
      test('should start and stop background sync', () {
        expect(offlineSyncService.isSyncing, isFalse);

        offlineSyncService.startBackgroundSync(
          interval: const Duration(seconds: 1),
        );

        // Background sync should be started (timer created)
        // We can't easily test the timer execution in unit tests

        offlineSyncService.stopBackgroundSync();

        // Background sync should be stopped
      });
    });
  });
}
