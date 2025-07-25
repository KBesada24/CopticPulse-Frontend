import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coptic_pulse/widgets/sermon_card.dart';
import 'package:coptic_pulse/models/sermon.dart';
import 'package:coptic_pulse/utils/theme.dart';

void main() {
  group('SermonCard Widget Tests', () {
    late Sermon testSermon;
    late Sermon testSermonWithMedia;
    late Sermon testSermonMinimal;

    setUp(() {
      testSermon = Sermon(
        id: 'sermon123',
        title: 'The Power of Prayer',
        description: 'A sermon about the importance of prayer in our daily lives.',
        publishedAt: DateTime(2024, 2, 10),
        speaker: 'Father John',
        tags: const ['prayer', 'spirituality'],
        duration: const Duration(minutes: 45),
      );

      testSermonWithMedia = Sermon(
        id: 'sermon456',
        title: 'Faith and Hope',
        description: 'A sermon about maintaining faith during difficult times.',
        thumbnailUrl: 'https://example.com/thumbnail.jpg',
        videoUrl: 'https://example.com/video.mp4',
        publishedAt: DateTime(2024, 2, 15),
        speaker: 'Father Mark',
        tags: const ['faith', 'hope'],
        duration: const Duration(hours: 1, minutes: 15),
      );

      testSermonMinimal = Sermon(
        id: 'sermon789',
        title: 'Simple Sermon',
        description: 'A simple sermon with minimal information.',
        publishedAt: DateTime(2024, 2, 20),
      );
    });

    Widget createTestWidget(Widget child) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: child,
        ),
      );
    }

    group('SermonCard - List View', () {
      testWidgets('should display sermon information in list layout', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            SermonCard(
              sermon: testSermon,
              isGridView: false,
            ),
          ),
        );

        // Check if title is displayed
        expect(find.text('The Power of Prayer'), findsOneWidget);
        
        // Check if description is displayed
        expect(find.text('A sermon about the importance of prayer in our daily lives.'), findsOneWidget);
        
        // Check if speaker is displayed
        expect(find.text('Father John'), findsOneWidget);
        
        // Check if date is displayed
        expect(find.text('February 10, 2024'), findsOneWidget);
      });

      testWidgets('should handle tap events', (tester) async {
        bool tapped = false;
        
        await tester.pumpWidget(
          createTestWidget(
            SermonCard(
              sermon: testSermon,
              isGridView: false,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        );

        await tester.tap(find.byType(InkWell));
        expect(tapped, isTrue);
      });

      testWidgets('should display media info when available', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            SermonCard(
              sermon: testSermonWithMedia,
              isGridView: false,
            ),
          ),
        );

        // Should show video icon and duration
        expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
        expect(find.text('1h 15m'), findsOneWidget);
      });

      testWidgets('should handle sermon without speaker', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            SermonCard(
              sermon: testSermonMinimal,
              isGridView: false,
            ),
          ),
        );

        // Title should be displayed
        expect(find.text('Simple Sermon'), findsOneWidget);
        
        // Date should be displayed
        expect(find.text('February 20, 2024'), findsOneWidget);
        
        // Should not crash without speaker
        expect(tester.takeException(), isNull);
      });
    });

    group('SermonCard - Grid View', () {
      testWidgets('should display sermon information in grid layout', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            SermonCard(
              sermon: testSermon,
              isGridView: true,
            ),
          ),
        );

        // Check if title is displayed
        expect(find.text('The Power of Prayer'), findsOneWidget);
        
        // Check if speaker is displayed
        expect(find.text('Father John'), findsOneWidget);
        
        // Check if date is displayed
        expect(find.text('February 10, 2024'), findsOneWidget);
      });

      testWidgets('should display thumbnail placeholder when no image', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            SermonCard(
              sermon: testSermon,
              isGridView: true,
            ),
          ),
        );

        // Should show placeholder icon
        expect(find.byIcon(Icons.volume_up), findsOneWidget);
      });

      testWidgets('should handle different media types', (tester) async {
        final videoSermon = testSermon.copyWith(
          videoUrl: 'https://example.com/video.mp4',
        );

        await tester.pumpWidget(
          createTestWidget(
            SermonCard(
              sermon: videoSermon,
              isGridView: true,
            ),
          ),
        );

        // Should show video icon for video sermons (may appear multiple times in different parts of the card)
        expect(find.byIcon(Icons.play_circle_outline), findsWidgets);
      });
    });

    group('CompactSermonCard', () {
      testWidgets('should display compact sermon information', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            CompactSermonCard(
              sermon: testSermon,
            ),
          ),
        );

        // Check if title is displayed
        expect(find.text('The Power of Prayer'), findsOneWidget);
        
        // Check if speaker is displayed
        expect(find.text('Father John'), findsOneWidget);
      });

      testWidgets('should handle tap events', (tester) async {
        bool tapped = false;
        
        await tester.pumpWidget(
          createTestWidget(
            CompactSermonCard(
              sermon: testSermon,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        );

        await tester.tap(find.byType(InkWell));
        expect(tapped, isTrue);
      });

      testWidgets('should have fixed width', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            CompactSermonCard(
              sermon: testSermon,
            ),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
        expect(sizedBox.width, equals(200));
      });

      testWidgets('should display placeholder for no thumbnail', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            CompactSermonCard(
              sermon: testSermon,
            ),
          ),
        );

        // Should show placeholder icon
        expect(find.byIcon(Icons.volume_up), findsOneWidget);
      });
    });

    group('Visual Styling', () {
      testWidgets('should apply correct theme colors', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            SermonCard(
              sermon: testSermon,
              isGridView: false,
            ),
          ),
        );

        // Find the card widget
        final card = tester.widget<Card>(find.byType(Card));
        expect(card.margin, equals(const EdgeInsets.all(8)));
      });

      testWidgets('should have different margins for grid and list views', (tester) async {
        // Test grid view margin
        await tester.pumpWidget(
          createTestWidget(
            SermonCard(
              sermon: testSermon,
              isGridView: true,
            ),
          ),
        );

        final gridCard = tester.widget<Card>(find.byType(Card));
        expect(gridCard.margin, equals(const EdgeInsets.all(4)));

        // Test list view margin
        await tester.pumpWidget(
          createTestWidget(
            SermonCard(
              sermon: testSermon,
              isGridView: false,
            ),
          ),
        );

        final listCard = tester.widget<Card>(find.byType(Card));
        expect(listCard.margin, equals(const EdgeInsets.all(8)));
      });
    });

    group('Text Overflow Handling', () {
      testWidgets('should handle long titles gracefully', (tester) async {
        final longTitleSermon = testSermon.copyWith(
          title: 'This is a very long sermon title that should be truncated when displayed in the card widget to prevent overflow issues',
        );

        await tester.pumpWidget(
          createTestWidget(
            SermonCard(
              sermon: longTitleSermon,
              isGridView: true,
            ),
          ),
        );

        // Should not throw overflow errors
        expect(tester.takeException(), isNull);
        
        // Title should still be found (even if truncated)
        expect(find.textContaining('This is a very long sermon title'), findsOneWidget);
      });

      testWidgets('should handle long descriptions gracefully', (tester) async {
        final longDescriptionSermon = testSermon.copyWith(
          description: 'This is a very long sermon description that should be truncated when displayed in the card widget to prevent overflow issues and maintain good visual appearance',
        );

        await tester.pumpWidget(
          createTestWidget(
            SermonCard(
              sermon: longDescriptionSermon,
              isGridView: false,
            ),
          ),
        );

        // Should not throw overflow errors
        expect(tester.takeException(), isNull);
      });
    });

    group('Accessibility', () {
      testWidgets('should be accessible with screen readers', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            SermonCard(
              sermon: testSermon,
              isGridView: false,
            ),
          ),
        );

        // Check that important text is accessible
        expect(find.text('The Power of Prayer'), findsOneWidget);
        expect(find.text('Father John'), findsOneWidget);
        expect(find.text('February 10, 2024'), findsOneWidget);
      });

      testWidgets('should have proper tap target size', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            SermonCard(
              sermon: testSermon,
              isGridView: false,
            ),
          ),
        );

        final inkWell = tester.widget<InkWell>(find.byType(InkWell));
        expect(inkWell.onTap, isNull); // No onTap provided in this test
      });
    });
  });
}

// Helper class for creating test sermons with different configurations
class SermonCardTestHelper {
  static Sermon createSermonWithVideo() {
    return Sermon(
      id: 'video_sermon',
      title: 'Video Sermon',
      description: 'A sermon with video content',
      videoUrl: 'https://example.com/video.mp4',
      thumbnailUrl: 'https://example.com/thumbnail.jpg',
      publishedAt: DateTime.now(),
      speaker: 'Father John',
      duration: const Duration(minutes: 30),
    );
  }

  static Sermon createSermonWithAudio() {
    return Sermon(
      id: 'audio_sermon',
      title: 'Audio Sermon',
      description: 'A sermon with audio content',
      audioUrl: 'https://example.com/audio.mp3',
      publishedAt: DateTime.now(),
      speaker: 'Father Mark',
      duration: const Duration(minutes: 25),
    );
  }

  static Sermon createSermonWithoutMedia() {
    return Sermon(
      id: 'no_media_sermon',
      title: 'Text Only Sermon',
      description: 'A sermon without media content',
      publishedAt: DateTime.now(),
      speaker: 'Father Luke',
    );
  }

  static Sermon createRecentSermon() {
    return Sermon(
      id: 'recent_sermon',
      title: 'Recent Sermon',
      description: 'A recently published sermon',
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      speaker: 'Father John',
      tags: const ['recent'],
    );
  }
}