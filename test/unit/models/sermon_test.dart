import 'package:flutter_test/flutter_test.dart';
import 'package:coptic_pulse/models/sermon.dart';

void main() {
  group('Sermon Model Tests', () {
    final testDateTime = DateTime(2024, 2, 10, 14, 30);
    final testDuration = const Duration(minutes: 45, seconds: 30);

    final testSermonJson = {
      'id': 'sermon123',
      'title': 'The Power of Prayer',
      'description': 'A sermon about the importance of prayer in our daily lives.',
      'thumbnailUrl': 'https://example.com/thumbnail.jpg',
      'videoUrl': 'https://example.com/video.mp4',
      'audioUrl': 'https://example.com/audio.mp3',
      'publishedAt': testDateTime.toIso8601String(),
      'speaker': 'Father John',
      'tags': ['prayer', 'spirituality', 'faith'],
      'duration': testDuration.inSeconds,
    };

    final testSermonJsonMinimal = {
      'id': 'sermon456',
      'title': 'Simple Sermon',
      'description': 'A simple sermon description.',
      'publishedAt': testDateTime.toIso8601String(),
    };

    test('should create Sermon from JSON correctly', () {
      final sermon = Sermon.fromJson(testSermonJson);

      expect(sermon.id, equals('sermon123'));
      expect(sermon.title, equals('The Power of Prayer'));
      expect(sermon.description, equals('A sermon about the importance of prayer in our daily lives.'));
      expect(sermon.thumbnailUrl, equals('https://example.com/thumbnail.jpg'));
      expect(sermon.videoUrl, equals('https://example.com/video.mp4'));
      expect(sermon.audioUrl, equals('https://example.com/audio.mp3'));
      expect(sermon.publishedAt, equals(testDateTime));
      expect(sermon.speaker, equals('Father John'));
      expect(sermon.tags, equals(['prayer', 'spirituality', 'faith']));
      expect(sermon.duration, equals(testDuration));
    });

    test('should create Sermon from minimal JSON correctly', () {
      final sermon = Sermon.fromJson(testSermonJsonMinimal);

      expect(sermon.id, equals('sermon456'));
      expect(sermon.title, equals('Simple Sermon'));
      expect(sermon.description, equals('A simple sermon description.'));
      expect(sermon.thumbnailUrl, isNull);
      expect(sermon.videoUrl, isNull);
      expect(sermon.audioUrl, isNull);
      expect(sermon.publishedAt, equals(testDateTime));
      expect(sermon.speaker, isNull);
      expect(sermon.tags, isEmpty);
      expect(sermon.duration, isNull);
    });

    test('should convert Sermon to JSON correctly', () {
      final sermon = Sermon(
        id: 'sermon123',
        title: 'The Power of Prayer',
        description: 'A sermon about the importance of prayer in our daily lives.',
        thumbnailUrl: 'https://example.com/thumbnail.jpg',
        videoUrl: 'https://example.com/video.mp4',
        audioUrl: 'https://example.com/audio.mp3',
        publishedAt: testDateTime,
        speaker: 'Father John',
        tags: const ['prayer', 'spirituality', 'faith'],
        duration: testDuration,
      );

      final json = sermon.toJson();

      expect(json['id'], equals('sermon123'));
      expect(json['title'], equals('The Power of Prayer'));
      expect(json['description'], equals('A sermon about the importance of prayer in our daily lives.'));
      expect(json['thumbnailUrl'], equals('https://example.com/thumbnail.jpg'));
      expect(json['videoUrl'], equals('https://example.com/video.mp4'));
      expect(json['audioUrl'], equals('https://example.com/audio.mp3'));
      expect(json['publishedAt'], equals(testDateTime.toIso8601String()));
      expect(json['speaker'], equals('Father John'));
      expect(json['tags'], equals(['prayer', 'spirituality', 'faith']));
      expect(json['duration'], equals(testDuration.inSeconds));
    });

    test('should convert Sermon without optional fields to JSON correctly', () {
      final sermon = Sermon(
        id: 'sermon456',
        title: 'Simple Sermon',
        description: 'A simple sermon description.',
        publishedAt: testDateTime,
      );

      final json = sermon.toJson();

      expect(json['id'], equals('sermon456'));
      expect(json['title'], equals('Simple Sermon'));
      expect(json['description'], equals('A simple sermon description.'));
      expect(json['publishedAt'], equals(testDateTime.toIso8601String()));
      expect(json.containsKey('thumbnailUrl'), isFalse);
      expect(json.containsKey('videoUrl'), isFalse);
      expect(json.containsKey('audioUrl'), isFalse);
      expect(json.containsKey('speaker'), isFalse);
      expect(json['tags'], isEmpty);
      expect(json.containsKey('duration'), isFalse);
    });

    test('should create copy with updated fields', () {
      final originalSermon = Sermon(
        id: 'sermon123',
        title: 'Original Title',
        description: 'Original description',
        publishedAt: testDateTime,
      );

      final newDateTime = DateTime(2024, 3, 15, 10, 0);
      final newDuration = const Duration(hours: 1, minutes: 15);

      final updatedSermon = originalSermon.copyWith(
        title: 'Updated Title',
        videoUrl: 'https://example.com/new_video.mp4',
        speaker: 'Father Mark',
        tags: const ['updated', 'sermon'],
        duration: newDuration,
      );

      expect(updatedSermon.id, equals('sermon123'));
      expect(updatedSermon.title, equals('Updated Title'));
      expect(updatedSermon.description, equals('Original description'));
      expect(updatedSermon.publishedAt, equals(testDateTime));
      expect(updatedSermon.videoUrl, equals('https://example.com/new_video.mp4'));
      expect(updatedSermon.speaker, equals('Father Mark'));
      expect(updatedSermon.tags, equals(['updated', 'sermon']));
      expect(updatedSermon.duration, equals(newDuration));
    });

    test('should format published date correctly', () {
      final sermon = Sermon(
        id: 'sermon123',
        title: 'Test Sermon',
        description: 'Test description',
        publishedAt: DateTime(2024, 2, 10), // February 10, 2024
      );

      expect(sermon.formattedPublishedDate, equals('February 10, 2024'));
    });

    test('should format duration correctly', () {
      // Test hours and minutes
      final sermon1 = Sermon(
        id: 'sermon1',
        title: 'Test Sermon',
        description: 'Test description',
        publishedAt: testDateTime,
        duration: const Duration(hours: 1, minutes: 30),
      );

      expect(sermon1.formattedDuration, equals('1h 30m'));

      // Test hours only
      final sermon2 = Sermon(
        id: 'sermon2',
        title: 'Test Sermon',
        description: 'Test description',
        publishedAt: testDateTime,
        duration: const Duration(hours: 2),
      );

      expect(sermon2.formattedDuration, equals('2h'));

      // Test minutes and seconds
      final sermon3 = Sermon(
        id: 'sermon3',
        title: 'Test Sermon',
        description: 'Test description',
        publishedAt: testDateTime,
        duration: const Duration(minutes: 45, seconds: 30),
      );

      expect(sermon3.formattedDuration, equals('45m 30s'));

      // Test minutes only
      final sermon4 = Sermon(
        id: 'sermon4',
        title: 'Test Sermon',
        description: 'Test description',
        publishedAt: testDateTime,
        duration: const Duration(minutes: 30),
      );

      expect(sermon4.formattedDuration, equals('30m'));

      // Test seconds only
      final sermon5 = Sermon(
        id: 'sermon5',
        title: 'Test Sermon',
        description: 'Test description',
        publishedAt: testDateTime,
        duration: const Duration(seconds: 45),
      );

      expect(sermon5.formattedDuration, equals('45s'));

      // Test no duration
      final sermon6 = Sermon(
        id: 'sermon6',
        title: 'Test Sermon',
        description: 'Test description',
        publishedAt: testDateTime,
      );

      expect(sermon6.formattedDuration, isNull);
    });

    test('should correctly identify media availability', () {
      final videoSermon = Sermon(
        id: 'sermon1',
        title: 'Video Sermon',
        description: 'Test description',
        publishedAt: testDateTime,
        videoUrl: 'https://example.com/video.mp4',
      );

      final audioSermon = Sermon(
        id: 'sermon2',
        title: 'Audio Sermon',
        description: 'Test description',
        publishedAt: testDateTime,
        audioUrl: 'https://example.com/audio.mp3',
      );

      final bothMediaSermon = Sermon(
        id: 'sermon3',
        title: 'Both Media Sermon',
        description: 'Test description',
        publishedAt: testDateTime,
        videoUrl: 'https://example.com/video.mp4',
        audioUrl: 'https://example.com/audio.mp3',
      );

      final noMediaSermon = Sermon(
        id: 'sermon4',
        title: 'No Media Sermon',
        description: 'Test description',
        publishedAt: testDateTime,
      );

      expect(videoSermon.hasVideo, isTrue);
      expect(videoSermon.hasAudio, isFalse);
      expect(videoSermon.hasMedia, isTrue);

      expect(audioSermon.hasVideo, isFalse);
      expect(audioSermon.hasAudio, isTrue);
      expect(audioSermon.hasMedia, isTrue);

      expect(bothMediaSermon.hasVideo, isTrue);
      expect(bothMediaSermon.hasAudio, isTrue);
      expect(bothMediaSermon.hasMedia, isTrue);

      expect(noMediaSermon.hasVideo, isFalse);
      expect(noMediaSermon.hasAudio, isFalse);
      expect(noMediaSermon.hasMedia, isFalse);
    });

    test('should correctly identify recent sermons', () {
      final now = DateTime.now();
      final recentSermon = Sermon(
        id: 'sermon1',
        title: 'Recent Sermon',
        description: 'Test description',
        publishedAt: now.subtract(const Duration(days: 3)),
      );

      final oldSermon = Sermon(
        id: 'sermon2',
        title: 'Old Sermon',
        description: 'Test description',
        publishedAt: now.subtract(const Duration(days: 10)),
      );

      expect(recentSermon.isRecent, isTrue);
      expect(oldSermon.isRecent, isFalse);
    });

    test('should return correct primary media URL and type', () {
      final videoOnlySermon = Sermon(
        id: 'sermon1',
        title: 'Video Only',
        description: 'Test description',
        publishedAt: testDateTime,
        videoUrl: 'https://example.com/video.mp4',
      );

      final audioOnlySermon = Sermon(
        id: 'sermon2',
        title: 'Audio Only',
        description: 'Test description',
        publishedAt: testDateTime,
        audioUrl: 'https://example.com/audio.mp3',
      );

      final bothMediaSermon = Sermon(
        id: 'sermon3',
        title: 'Both Media',
        description: 'Test description',
        publishedAt: testDateTime,
        videoUrl: 'https://example.com/video.mp4',
        audioUrl: 'https://example.com/audio.mp3',
      );

      final noMediaSermon = Sermon(
        id: 'sermon4',
        title: 'No Media',
        description: 'Test description',
        publishedAt: testDateTime,
      );

      expect(videoOnlySermon.primaryMediaUrl, equals('https://example.com/video.mp4'));
      expect(videoOnlySermon.primaryMediaType, equals(SermonMediaType.video));

      expect(audioOnlySermon.primaryMediaUrl, equals('https://example.com/audio.mp3'));
      expect(audioOnlySermon.primaryMediaType, equals(SermonMediaType.audio));

      // Video should be preferred over audio
      expect(bothMediaSermon.primaryMediaUrl, equals('https://example.com/video.mp4'));
      expect(bothMediaSermon.primaryMediaType, equals(SermonMediaType.video));

      expect(noMediaSermon.primaryMediaUrl, isNull);
      expect(noMediaSermon.primaryMediaType, isNull);
    });

    test('should implement equality correctly', () {
      final sermon1 = Sermon(
        id: 'sermon123',
        title: 'Test Sermon',
        description: 'Test description',
        publishedAt: testDateTime,
        speaker: 'Father John',
        tags: const ['test', 'sermon'],
        duration: testDuration,
      );

      final sermon2 = Sermon(
        id: 'sermon123',
        title: 'Test Sermon',
        description: 'Test description',
        publishedAt: testDateTime,
        speaker: 'Father John',
        tags: const ['test', 'sermon'],
        duration: testDuration,
      );

      final sermon3 = Sermon(
        id: 'sermon456',
        title: 'Different Sermon',
        description: 'Different description',
        publishedAt: testDateTime,
      );

      expect(sermon1, equals(sermon2));
      expect(sermon1, isNot(equals(sermon3)));
      expect(sermon1.hashCode, equals(sermon2.hashCode));
    });

    test('should have proper toString implementation', () {
      final sermon = Sermon(
        id: 'sermon123',
        title: 'Test Sermon',
        description: 'Test description',
        publishedAt: testDateTime,
        speaker: 'Father John',
      );

      final string = sermon.toString();
      expect(string, contains('sermon123'));
      expect(string, contains('Test Sermon'));
      expect(string, contains('Father John'));
    });

    group('SermonMediaType enum tests', () {
      test('should have correct display names', () {
        expect(SermonMediaType.video.displayName, equals('Video'));
        expect(SermonMediaType.audio.displayName, equals('Audio'));
      });

      test('should have correct icon names', () {
        expect(SermonMediaType.video.iconName, equals('play_circle'));
        expect(SermonMediaType.audio.iconName, equals('volume_up'));
      });

      test('should serialize to correct string values', () {
        expect(SermonMediaType.video.name, equals('video'));
        expect(SermonMediaType.audio.name, equals('audio'));
      });
    });
  });
}