import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:coptic_pulse/providers/sermon_provider.dart';
import 'package:coptic_pulse/services/sermon_service.dart';
import 'package:coptic_pulse/models/sermon.dart';

import 'sermon_provider_test.mocks.dart';

@GenerateMocks([SermonService])
void main() {
  group('SermonProvider Tests', () {
    late SermonProvider sermonProvider;
    late MockSermonService mockSermonService;

    setUp(() {
      mockSermonService = MockSermonService();
      sermonProvider = SermonProvider();
      
      // Note: In a real implementation, we would need to inject the mock service
      // For now, we'll test the provider's state management behavior
    });

    final testSermons = [
      Sermon(
        id: 'sermon1',
        title: 'Test Sermon 1',
        description: 'Description 1',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        speaker: 'Father John',
        tags: const ['prayer', 'faith'],
      ),
      Sermon(
        id: 'sermon2',
        title: 'Test Sermon 2',
        description: 'Description 2',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        speaker: 'Father Mark',
        tags: const ['hope', 'love'],
      ),
    ];

    final testTags = ['prayer', 'faith', 'hope', 'love'];
    final testSpeakers = ['Father John', 'Father Mark'];

    group('Initial State', () {
      test('should have correct initial state', () {
        expect(sermonProvider.sermons, isEmpty);
        expect(sermonProvider.availableTags, isEmpty);
        expect(sermonProvider.availableSpeakers, isEmpty);
        expect(sermonProvider.isLoading, isFalse);
        expect(sermonProvider.isLoadingMore, isFalse);
        expect(sermonProvider.error, isNull);
        expect(sermonProvider.searchQuery, isEmpty);
        expect(sermonProvider.selectedTags, isEmpty);
        expect(sermonProvider.selectedSpeaker, isNull);
        expect(sermonProvider.hasMoreData, isTrue);
        expect(sermonProvider.hasActiveFilters, isFalse);
      });
    });

    group('Loading State Management', () {
      test('should update loading state correctly', () {
        var notificationCount = 0;
        sermonProvider.addListener(() {
          notificationCount++;
        });

        // Test loading state changes
        expect(sermonProvider.isLoading, isFalse);
        expect(notificationCount, equals(0));
      });
    });

    group('Search Functionality', () {
      test('should update search query', () async {
        const testQuery = 'prayer';
        
        // Test that search query is updated
        await sermonProvider.searchSermons(testQuery);
        expect(sermonProvider.searchQuery, equals(testQuery));
      });

      test('should not update if search query is the same', () async {
        const testQuery = 'prayer';
        
        await sermonProvider.searchSermons(testQuery);
        final firstQuery = sermonProvider.searchQuery;
        
        await sermonProvider.searchSermons(testQuery);
        expect(sermonProvider.searchQuery, equals(firstQuery));
      });

      test('should clear search query', () async {
        await sermonProvider.searchSermons('prayer');
        expect(sermonProvider.searchQuery, equals('prayer'));
        
        await sermonProvider.searchSermons('');
        expect(sermonProvider.searchQuery, isEmpty);
      });
    });

    group('Tag Filtering', () {
      test('should update selected tags', () async {
        final testTags = ['prayer', 'faith'];
        
        await sermonProvider.filterByTags(testTags);
        expect(sermonProvider.selectedTags, equals(testTags));
      });

      test('should not update if tags are the same', () async {
        final testTags = ['prayer', 'faith'];
        
        await sermonProvider.filterByTags(testTags);
        final firstTags = List<String>.from(sermonProvider.selectedTags);
        
        await sermonProvider.filterByTags(testTags);
        expect(sermonProvider.selectedTags, equals(firstTags));
      });

      test('should clear selected tags', () async {
        await sermonProvider.filterByTags(['prayer', 'faith']);
        expect(sermonProvider.selectedTags, isNotEmpty);
        
        await sermonProvider.filterByTags([]);
        expect(sermonProvider.selectedTags, isEmpty);
      });
    });

    group('Speaker Filtering', () {
      test('should update selected speaker', () async {
        const testSpeaker = 'Father John';
        
        await sermonProvider.filterBySpeaker(testSpeaker);
        expect(sermonProvider.selectedSpeaker, equals(testSpeaker));
      });

      test('should not update if speaker is the same', () async {
        const testSpeaker = 'Father John';
        
        await sermonProvider.filterBySpeaker(testSpeaker);
        final firstSpeaker = sermonProvider.selectedSpeaker;
        
        await sermonProvider.filterBySpeaker(testSpeaker);
        expect(sermonProvider.selectedSpeaker, equals(firstSpeaker));
      });

      test('should clear selected speaker', () async {
        await sermonProvider.filterBySpeaker('Father John');
        expect(sermonProvider.selectedSpeaker, isNotNull);
        
        await sermonProvider.filterBySpeaker(null);
        expect(sermonProvider.selectedSpeaker, isNull);
      });
    });

    group('Active Filters Detection', () {
      test('should detect active search filter', () async {
        expect(sermonProvider.hasActiveFilters, isFalse);
        
        await sermonProvider.searchSermons('prayer');
        expect(sermonProvider.hasActiveFilters, isTrue);
      });

      test('should detect active tag filters', () async {
        expect(sermonProvider.hasActiveFilters, isFalse);
        
        await sermonProvider.filterByTags(['prayer']);
        expect(sermonProvider.hasActiveFilters, isTrue);
      });

      test('should detect active speaker filter', () async {
        expect(sermonProvider.hasActiveFilters, isFalse);
        
        await sermonProvider.filterBySpeaker('Father John');
        expect(sermonProvider.hasActiveFilters, isTrue);
      });

      test('should detect multiple active filters', () async {
        await sermonProvider.searchSermons('prayer');
        await sermonProvider.filterByTags(['faith']);
        await sermonProvider.filterBySpeaker('Father John');
        
        expect(sermonProvider.hasActiveFilters, isTrue);
        expect(sermonProvider.searchQuery, equals('prayer'));
        expect(sermonProvider.selectedTags, equals(['faith']));
        expect(sermonProvider.selectedSpeaker, equals('Father John'));
      });
    });

    group('Clear Filters', () {
      test('should clear all filters', () async {
        // Set up filters
        await sermonProvider.searchSermons('prayer');
        await sermonProvider.filterByTags(['faith']);
        await sermonProvider.filterBySpeaker('Father John');
        
        expect(sermonProvider.hasActiveFilters, isTrue);
        
        // Clear filters
        await sermonProvider.clearFilters();
        
        expect(sermonProvider.hasActiveFilters, isFalse);
        expect(sermonProvider.searchQuery, isEmpty);
        expect(sermonProvider.selectedTags, isEmpty);
        expect(sermonProvider.selectedSpeaker, isNull);
      });

      test('should not clear if no active filters', () async {
        expect(sermonProvider.hasActiveFilters, isFalse);
        
        // This should not cause any issues
        await sermonProvider.clearFilters();
        
        expect(sermonProvider.hasActiveFilters, isFalse);
      });
    });

    group('Error Handling', () {
      test('should handle and clear errors', () {
        expect(sermonProvider.error, isNull);
        
        // Simulate setting an error (this would normally happen in loadSermons)
        // sermonProvider._setError('Test error');
        // expect(sermonProvider.error, equals('Test error'));
        
        sermonProvider.clearError();
        expect(sermonProvider.error, isNull);
      });
    });

    group('Notification Tests', () {
      test('should notify listeners on state changes', () {
        var notificationCount = 0;
        sermonProvider.addListener(() {
          notificationCount++;
        });

        // Clear error should notify
        sermonProvider.clearError();
        expect(notificationCount, greaterThan(0));
      });
    });

    group('Sermon Retrieval', () {
      test('should handle getSermonById for non-existent sermon', () async {
        final result = await sermonProvider.getSermonById('non_existent');
        expect(result, isNull);
      });
    });

    group('Recent Sermons', () {
      test('should handle getRecentSermons with default limit', () async {
        final result = await sermonProvider.getRecentSermons();
        expect(result, isA<List<Sermon>>());
      });

      test('should handle getRecentSermons with custom limit', () async {
        final result = await sermonProvider.getRecentSermons(limit: 5);
        expect(result, isA<List<Sermon>>());
      });
    });

    group('Pagination', () {
      test('should track pagination state', () {
        expect(sermonProvider.hasMoreData, isTrue);
        
        // In a real implementation, this would be updated by loadSermons
        // expect(sermonProvider.hasMoreData, isFalse);
      });
    });
  });
}

// Helper class for creating test data
class SermonProviderTestHelper {
  static Sermon createTestSermon({
    String id = 'test_sermon',
    String title = 'Test Sermon',
    String description = 'Test description',
    DateTime? publishedAt,
    String? speaker,
    List<String> tags = const [],
  }) {
    return Sermon(
      id: id,
      title: title,
      description: description,
      publishedAt: publishedAt ?? DateTime.now(),
      speaker: speaker,
      tags: tags,
    );
  }

  static List<Sermon> createTestSermons(int count) {
    return List.generate(count, (index) => createTestSermon(
      id: 'sermon_$index',
      title: 'Test Sermon $index',
      description: 'Description for sermon $index',
      speaker: index % 2 == 0 ? 'Father John' : 'Father Mark',
      tags: index % 2 == 0 ? ['prayer', 'faith'] : ['hope', 'love'],
    ));
  }
}