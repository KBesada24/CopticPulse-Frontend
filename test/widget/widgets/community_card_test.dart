import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coptic_pulse/widgets/community_card.dart';
import 'package:coptic_pulse/models/post.dart';

void main() {
  group('CommunityCard', () {
    late Post testPost;

    setUp(() {
      testPost = Post(
        id: '1',
        title: 'Test Post Title',
        content: 'This is a test post content that should be displayed in the card.',
        type: PostType.announcement,
        status: PostStatus.approved,
        authorId: 'user1',
        createdAt: DateTime(2024, 1, 1, 12, 0),
        attachments: [],
      );
    });

    testWidgets('should display post information correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommunityCard(post: testPost),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Post Title'), findsOneWidget);
      expect(find.text('This is a test post content that should be displayed in the card.'), findsOneWidget);
      expect(find.text('Announcement'), findsOneWidget);
      expect(find.text('Read more'), findsOneWidget);
    });

    testWidgets('should display correct post type chip for announcement', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommunityCard(post: testPost),
          ),
        ),
      );

      // Assert
      expect(find.text('Announcement'), findsOneWidget);
      expect(find.byIcon(Icons.campaign), findsOneWidget);
    });

    testWidgets('should display correct post type chip for event', (tester) async {
      // Arrange
      final eventPost = testPost.copyWith(type: PostType.event);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommunityCard(post: eventPost),
          ),
        ),
      );

      // Assert
      expect(find.text('Event'), findsOneWidget);
      expect(find.byIcon(Icons.event), findsOneWidget);
    });

    testWidgets('should display correct post type chip for prayer request', (tester) async {
      // Arrange
      final prayerPost = testPost.copyWith(type: PostType.prayerRequest);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommunityCard(post: prayerPost),
          ),
        ),
      );

      // Assert
      expect(find.text('Prayer Request'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should display attachment indicator when attachments exist', (tester) async {
      // Arrange
      final postWithAttachments = testPost.copyWith(
        attachments: ['file1.jpg', 'file2.pdf'],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommunityCard(post: postWithAttachments),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.attachment), findsOneWidget);
      expect(find.text('2 attachments'), findsOneWidget);
    });

    testWidgets('should display singular attachment text for one attachment', (tester) async {
      // Arrange
      final postWithOneAttachment = testPost.copyWith(
        attachments: ['file1.jpg'],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommunityCard(post: postWithOneAttachment),
          ),
        ),
      );

      // Assert
      expect(find.text('1 attachment'), findsOneWidget);
    });

    testWidgets('should not display attachment indicator when no attachments', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommunityCard(post: testPost),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.attachment), findsNothing);
    });

    testWidgets('should format timestamp correctly for recent posts', (tester) async {
      // Arrange
      final recentPost = testPost.copyWith(
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommunityCard(post: recentPost),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('2h ago'), findsOneWidget);
    });

    testWidgets('should format timestamp correctly for old posts', (tester) async {
      // Arrange
      final oldPost = testPost.copyWith(
        createdAt: DateTime(2023, 12, 25),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommunityCard(post: oldPost),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('25/12/2023'), findsOneWidget);
    });

    testWidgets('should truncate long content with ellipsis', (tester) async {
      // Arrange
      final longContentPost = testPost.copyWith(
        content: 'This is a very long post content that should be truncated when displayed in the card widget because it exceeds the maximum number of lines allowed for the preview. This text should be cut off with ellipsis.',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommunityCard(post: longContentPost),
          ),
        ),
      );

      // Assert
      final contentWidget = tester.widget<Text>(
        find.text(longContentPost.content),
      );
      expect(contentWidget.maxLines, 3);
      expect(contentWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('should truncate long title with ellipsis', (tester) async {
      // Arrange
      final longTitlePost = testPost.copyWith(
        title: 'This is a very long post title that should be truncated when displayed in the card widget',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommunityCard(post: longTitlePost),
          ),
        ),
      );

      // Assert
      final titleWidget = tester.widget<Text>(
        find.text(longTitlePost.title),
      );
      expect(titleWidget.maxLines, 2);
      expect(titleWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('should have tappable InkWell widget', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommunityCard(post: testPost),
          ),
        ),
      );

      // Assert
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('should have proper card styling', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommunityCard(post: testPost),
          ),
        ),
      );

      // Assert
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 2);
      expect(card.shape, isA<RoundedRectangleBorder>());
      
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('should have proper padding', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommunityCard(post: testPost),
          ),
        ),
      );

      // Assert
      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(padding.padding, const EdgeInsets.symmetric(horizontal: 16, vertical: 8));
    });
  });
}