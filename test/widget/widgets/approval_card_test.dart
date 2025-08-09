import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coptic_pulse/widgets/approval_card.dart';
import 'package:coptic_pulse/models/post.dart';

void main() {
  group('ApprovalCard', () {
    late Post testPost;

    setUp(() {
      testPost = Post(
        id: '1',
        title: 'Test Post Title',
        content: 'This is a test post content that should be displayed in the card.',
        type: PostType.announcement,
        status: PostStatus.pending,
        authorId: 'user1',
        createdAt: DateTime(2024, 1, 1, 12, 0),
        attachments: ['attachment1.jpg', 'attachment2.pdf'],
      );
    });

    testWidgets('should display post information correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(post: testPost),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Post Title'), findsOneWidget);
      expect(find.text('This is a test post content that should be displayed in the card.'), findsOneWidget);
      expect(find.text('Announcement'), findsOneWidget);
      expect(find.text('2 attachments'), findsOneWidget);
    });

    testWidgets('should display correct post type chip for announcement', (tester) async {
      // Arrange
      final announcementPost = testPost.copyWith(type: PostType.announcement);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(post: announcementPost),
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
            body: ApprovalCard(post: eventPost),
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
            body: ApprovalCard(post: prayerPost),
          ),
        ),
      );

      // Assert
      expect(find.text('Prayer Request'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should display all action buttons', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(post: testPost),
          ),
        ),
      );

      // Assert
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Request Revision'), findsOneWidget);
    });

    testWidgets('should call onApprove when approve button is tapped', (tester) async {
      // Arrange
      bool onApproveCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(
              post: testPost,
              onApprove: () => onApproveCalled = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Approve'));
      await tester.pump();

      // Assert
      expect(onApproveCalled, true);
    });

    testWidgets('should call onReject when reject button is tapped', (tester) async {
      // Arrange
      bool onRejectCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(
              post: testPost,
              onReject: () => onRejectCalled = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Reject'));
      await tester.pump();

      // Assert
      expect(onRejectCalled, true);
    });

    testWidgets('should call onRequestRevision when request revision button is tapped', (tester) async {
      // Arrange
      bool onRequestRevisionCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(
              post: testPost,
              onRequestRevision: () => onRequestRevisionCalled = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Request Revision'));
      await tester.pump();

      // Assert
      expect(onRequestRevisionCalled, true);
    });

    testWidgets('should call onPreview when preview button is tapped', (tester) async {
      // Arrange
      bool onPreviewCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(
              post: testPost,
              onPreview: () => onPreviewCalled = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Preview'));
      await tester.pump();

      // Assert
      expect(onPreviewCalled, true);
    });

    testWidgets('should handle post with no attachments', (tester) async {
      // Arrange
      final postWithoutAttachments = testPost.copyWith(attachments: []);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(post: postWithoutAttachments),
          ),
        ),
      );

      // Assert
      expect(find.text('attachments'), findsNothing);
      expect(find.byIcon(Icons.attachment), findsNothing);
    });

    testWidgets('should handle post with single attachment', (tester) async {
      // Arrange
      final postWithOneAttachment = testPost.copyWith(attachments: ['single.jpg']);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(post: postWithOneAttachment),
          ),
        ),
      );

      // Assert
      expect(find.text('1 attachment'), findsOneWidget);
      expect(find.byIcon(Icons.attachment), findsOneWidget);
    });

    testWidgets('should truncate long content', (tester) async {
      // Arrange
      final longContentPost = testPost.copyWith(
        content: 'This is a very long content that should be truncated when displayed in the card. ' * 10,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(post: longContentPost),
          ),
        ),
      );

      // Assert
      final contentText = tester.widget<Text>(
        find.text(longContentPost.content).first,
      );
      expect(contentText.maxLines, 3);
      expect(contentText.overflow, TextOverflow.ellipsis);
    });

    testWidgets('should format timestamp correctly', (tester) async {
      // Arrange
      final recentPost = testPost.copyWith(
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(post: recentPost),
          ),
        ),
      );

      // Assert
      expect(find.text('30m ago'), findsOneWidget);
    });
  });

  group('CompactApprovalCard', () {
    late Post testPost;

    setUp(() {
      testPost = Post(
        id: '1',
        title: 'Test Post Title',
        content: 'This is a test post content.',
        type: PostType.event,
        status: PostStatus.pending,
        authorId: 'user1',
        createdAt: DateTime(2024, 1, 1, 12, 0),
        attachments: [],
      );
    });

    testWidgets('should display post information in compact format', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactApprovalCard(post: testPost),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Post Title'), findsOneWidget);
      expect(find.text('This is a test post content.'), findsOneWidget);
      expect(find.byIcon(Icons.event), findsOneWidget);
    });

    testWidgets('should display approve and reject buttons', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactApprovalCard(post: testPost),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should call onTap when card is tapped', (tester) async {
      // Arrange
      bool onTapCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactApprovalCard(
              post: testPost,
              onTap: () => onTapCalled = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ListTile));
      await tester.pump();

      // Assert
      expect(onTapCalled, true);
    });

    testWidgets('should call onApprove when approve button is tapped', (tester) async {
      // Arrange
      bool onApproveCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactApprovalCard(
              post: testPost,
              onApprove: () => onApproveCalled = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();

      // Assert
      expect(onApproveCalled, true);
    });

    testWidgets('should call onReject when reject button is tapped', (tester) async {
      // Arrange
      bool onRejectCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactApprovalCard(
              post: testPost,
              onReject: () => onRejectCalled = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // Assert
      expect(onRejectCalled, true);
    });

    testWidgets('should display correct colors for different post types', (tester) async {
      // Test announcement
      final announcementPost = testPost.copyWith(type: PostType.announcement);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactApprovalCard(post: announcementPost),
          ),
        ),
      );
      expect(find.byIcon(Icons.campaign), findsOneWidget);

      // Test prayer request
      final prayerPost = testPost.copyWith(type: PostType.prayerRequest);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactApprovalCard(post: prayerPost),
          ),
        ),
      );
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });
}