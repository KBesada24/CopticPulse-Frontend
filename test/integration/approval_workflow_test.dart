import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:coptic_pulse/providers/auth_provider.dart';
import 'package:coptic_pulse/widgets/approval_card.dart';
import 'package:coptic_pulse/models/user.dart';
import 'package:coptic_pulse/models/post.dart';

import 'approval_workflow_test.mocks.dart';

@GenerateMocks([AuthProvider])
void main() {
  group('Approval Workflow Integration Tests', () {
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = MockAuthProvider();
    });

    testWidgets('approval card displays post information correctly', (
      tester,
    ) async {
      // Arrange - Create test post
      final testPost = Post(
        id: '1',
        title: 'Test Announcement',
        content: 'This is a test announcement for approval',
        type: PostType.announcement,
        status: PostStatus.pending,
        authorId: 'user1',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        attachments: ['image.jpg'],
      );

      bool approvePressed = false;
      bool rejectPressed = false;
      bool revisionPressed = false;
      bool previewPressed = false;

      // Act - Render approval card
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(
              post: testPost,
              onApprove: () => approvePressed = true,
              onReject: () => rejectPressed = true,
              onRequestRevision: () => revisionPressed = true,
              onPreview: () => previewPressed = true,
            ),
          ),
        ),
      );

      // Assert - Verify post information is displayed
      expect(find.text('Test Announcement'), findsOneWidget);
      expect(
        find.text('This is a test announcement for approval'),
        findsOneWidget,
      );
      expect(find.text('Announcement'), findsOneWidget);
      expect(find.text('1 attachment'), findsOneWidget);

      // Assert - Verify action buttons are present
      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
      expect(find.text('Request Revision'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);

      // Act - Test button interactions
      await tester.tap(find.text('Approve'));
      await tester.pump();
      expect(approvePressed, true);

      await tester.tap(find.text('Reject'));
      await tester.pump();
      expect(rejectPressed, true);

      await tester.tap(find.text('Request Revision'));
      await tester.pump();
      expect(revisionPressed, true);

      await tester.tap(find.text('Preview'));
      await tester.pump();
      expect(previewPressed, true);
    });

    testWidgets('compact approval card works correctly', (tester) async {
      // Arrange - Create test post
      final testPost = Post(
        id: '2',
        title: 'Prayer Request',
        content: 'Please pray for healing',
        type: PostType.prayerRequest,
        status: PostStatus.pending,
        authorId: 'user2',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        attachments: [],
      );

      bool cardTapped = false;
      bool approvePressed = false;
      bool rejectPressed = false;

      // Act - Render compact approval card
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactApprovalCard(
              post: testPost,
              onTap: () => cardTapped = true,
              onApprove: () => approvePressed = true,
              onReject: () => rejectPressed = true,
            ),
          ),
        ),
      );

      // Assert - Verify post information is displayed
      expect(find.text('Prayer Request'), findsOneWidget);
      expect(find.text('Please pray for healing'), findsOneWidget);
      expect(
        find.byIcon(Icons.favorite),
        findsOneWidget,
      ); // Prayer request icon

      // Act - Test interactions
      await tester.tap(find.byType(ListTile));
      await tester.pump();
      expect(cardTapped, true);

      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();
      expect(approvePressed, true);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(rejectPressed, true);
    });

    testWidgets('admin role checking works correctly', (tester) async {
      // Test admin user
      final adminUser = User(
        id: 'admin1',
        email: 'admin@test.com',
        name: 'Test Admin',
        role: UserRole.administrator,
        title: 'Father John',
      );

      when(mockAuthProvider.user).thenReturn(adminUser);
      when(mockAuthProvider.isAdmin).thenReturn(true);
      when(mockAuthProvider.isAuthenticated).thenReturn(true);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          ],
          child: MaterialApp(
            home: Consumer<AuthProvider>(
              builder: (context, auth, child) {
                return Scaffold(
                  body: Center(
                    child: Text(auth.isAdmin ? 'Admin Access' : 'Regular User'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Admin Access'), findsOneWidget);

      // Test regular user
      final regularUser = User(
        id: 'user1',
        email: 'user@test.com',
        name: 'Test User',
        role: UserRole.member,
      );

      when(mockAuthProvider.user).thenReturn(regularUser);
      when(mockAuthProvider.isAdmin).thenReturn(false);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          ],
          child: MaterialApp(
            home: Consumer<AuthProvider>(
              builder: (context, auth, child) {
                return Scaffold(
                  body: Center(
                    child: Text(auth.isAdmin ? 'Admin Access' : 'Regular User'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Regular User'), findsOneWidget);
    });
  });
}
