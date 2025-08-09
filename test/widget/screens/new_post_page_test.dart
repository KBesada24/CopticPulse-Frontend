import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:coptic_pulse/screens/new_post.dart';
import 'package:coptic_pulse/models/post.dart';
import 'package:coptic_pulse/models/user.dart';
import 'package:coptic_pulse/providers/auth_provider.dart';
import 'package:coptic_pulse/providers/post_provider.dart';
import 'package:coptic_pulse/services/file_upload_service.dart';

import 'new_post_page_test.mocks.dart';

@GenerateMocks([AuthProvider, PostProvider, FileUploadService])
void main() {
  group('NewPostPage Widget Tests', () {
    late MockAuthProvider mockAuthProvider;
    late MockPostProvider mockPostProvider;
    // ignore: unused_local_variable
    late MockFileUploadService mockFileUploadService;

    setUp(() {
      mockAuthProvider = MockAuthProvider();
      mockPostProvider = MockPostProvider();
      mockFileUploadService = MockFileUploadService();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<PostProvider>.value(value: mockPostProvider),
          ],
          child: const NewPostPage(),
        ),
      );
    }

    testWidgets('should display all required form fields', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockAuthProvider.isAuthenticated).thenReturn(true);
      when(mockAuthProvider.user).thenReturn(
        const User(
          id: '1',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.member,
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Create a New Post'), findsOneWidget);
      expect(find.text('Post Type'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<PostType>), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
      expect(find.text('Attachments'), findsOneWidget);
      expect(find.text('Add Photo'), findsOneWidget);
      expect(find.text('Add Video'), findsOneWidget);
      expect(find.text('Submit for Approval'), findsOneWidget);
    });

    testWidgets('should show validation errors for empty fields', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockAuthProvider.isAuthenticated).thenReturn(true);
      when(mockAuthProvider.user).thenReturn(
        const User(
          id: '1',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.member,
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Submit for Approval'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter a title'), findsOneWidget);
      expect(find.text('Please enter some content'), findsOneWidget);
    });

    testWidgets('should show validation error for short title', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockAuthProvider.isAuthenticated).thenReturn(true);
      when(mockAuthProvider.user).thenReturn(
        const User(
          id: '1',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.member,
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.enterText(find.byType(TextFormField).first, 'Hi');
      await tester.tap(find.text('Submit for Approval'));
      await tester.pump();

      // Assert
      expect(
        find.text('Title must be at least 3 characters long'),
        findsOneWidget,
      );
    });

    testWidgets('should show validation error for short content', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockAuthProvider.isAuthenticated).thenReturn(true);
      when(mockAuthProvider.user).thenReturn(
        const User(
          id: '1',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.member,
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.enterText(find.byType(TextFormField).at(1), 'Short');
      await tester.tap(find.text('Submit for Approval'));
      await tester.pump();

      // Assert
      expect(
        find.text('Content must be at least 10 characters long'),
        findsOneWidget,
      );
    });

    testWidgets('should change post type when dropdown selection changes', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockAuthProvider.isAuthenticated).thenReturn(true);
      when(mockAuthProvider.user).thenReturn(
        const User(
          id: '1',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.member,
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Tap dropdown to open it
      await tester.tap(find.byType(DropdownButtonFormField<PostType>));
      await tester.pumpAndSettle();

      // Select Event option
      await tester.tap(find.text('Event').last);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Event'), findsOneWidget);
    });

    testWidgets('should show loading state during submission', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockAuthProvider.isAuthenticated).thenReturn(true);
      when(mockAuthProvider.user).thenReturn(
        const User(
          id: '1',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.member,
        ),
      );

      // Make createPost hang to simulate loading
      when(mockPostProvider.createPost(any)).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return Post(
          id: '1',
          title: 'Test',
          content: 'Test content',
          type: PostType.announcement,
          status: PostStatus.pending,
          authorId: '1',
          createdAt: DateTime.now(),
        );
      });

      // Act
      await tester.pumpWidget(createTestWidget());

      // Fill in valid form data
      await tester.enterText(find.byType(TextFormField).first, 'Test Title');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'This is test content that is long enough',
      );

      // Submit form
      await tester.tap(find.text('Submit for Approval'));
      await tester.pump();

      // Assert
      expect(find.text('Submitting...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when not authenticated', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockAuthProvider.isAuthenticated).thenReturn(false);
      when(mockAuthProvider.user).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Fill in valid form data
      await tester.enterText(find.byType(TextFormField).first, 'Test Title');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'This is test content that is long enough',
      );

      // Submit form
      await tester.tap(find.text('Submit for Approval'));
      await tester.pump();

      // Assert
      expect(
        find.text('You must be logged in to create a post'),
        findsOneWidget,
      );
    });

    testWidgets('should successfully submit post with valid data', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockAuthProvider.isAuthenticated).thenReturn(true);
      when(mockAuthProvider.user).thenReturn(
        const User(
          id: '1',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.member,
        ),
      );
      when(mockPostProvider.createPost(any)).thenAnswer((_) async {
        return Post(
          id: '1',
          title: 'Test',
          content: 'Test content',
          type: PostType.announcement,
          status: PostStatus.pending,
          authorId: '1',
          createdAt: DateTime.now(),
        );
      });

      // Act
      await tester.pumpWidget(createTestWidget());

      // Fill in valid form data
      await tester.enterText(find.byType(TextFormField).first, 'Test Title');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'This is test content that is long enough',
      );

      // Submit form
      await tester.tap(find.text('Submit for Approval'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockPostProvider.createPost(any)).called(1);
      expect(find.text('Post submitted for approval!'), findsOneWidget);
    });

    testWidgets('should show error message when post creation fails', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockAuthProvider.isAuthenticated).thenReturn(true);
      when(mockAuthProvider.user).thenReturn(
        const User(
          id: '1',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.member,
        ),
      );
      when(
        mockPostProvider.createPost(any),
      ).thenThrow(Exception('Network error'));

      // Act
      await tester.pumpWidget(createTestWidget());

      // Fill in valid form data
      await tester.enterText(find.byType(TextFormField).first, 'Test Title');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'This is test content that is long enough',
      );

      // Submit form
      await tester.tap(find.text('Submit for Approval'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Failed to submit post'), findsOneWidget);
    });

    testWidgets('should display info message about approval process', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockAuthProvider.isAuthenticated).thenReturn(true);
      when(mockAuthProvider.user).thenReturn(
        const User(
          id: '1',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.member,
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(
        find.text(
          'Your post will be reviewed by administrators before being published to the community.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should show correct icons for different post types', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockAuthProvider.isAuthenticated).thenReturn(true);
      when(mockAuthProvider.user).thenReturn(
        const User(
          id: '1',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.member,
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<PostType>));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.campaign), findsOneWidget); // Announcement
      expect(find.byIcon(Icons.event), findsOneWidget); // Event
      expect(find.byIcon(Icons.favorite), findsOneWidget); // Prayer Request
    });
  });

  group('NewPostPage Integration Tests', () {
    late MockAuthProvider mockAuthProvider;
    late MockPostProvider mockPostProvider;

    setUp(() {
      mockAuthProvider = MockAuthProvider();
      mockPostProvider = MockPostProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<PostProvider>.value(value: mockPostProvider),
          ],
          child: const NewPostPage(),
        ),
      );
    }

    testWidgets('should create post with correct data structure', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testUser = User(
        id: 'user123',
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.member,
      );

      when(mockAuthProvider.isAuthenticated).thenReturn(true);
      when(mockAuthProvider.user).thenReturn(testUser);
      when(mockPostProvider.createPost(any)).thenAnswer((_) async {
        return Post(
          id: '1',
          title: 'Test',
          content: 'Test content',
          type: PostType.announcement,
          status: PostStatus.pending,
          authorId: '1',
          createdAt: DateTime.now(),
        );
      });

      // Act
      await tester.pumpWidget(createTestWidget());

      // Change post type to Event
      await tester.tap(find.byType(DropdownButtonFormField<PostType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Event').last);
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(find.byType(TextFormField).first, 'Church Event');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Join us for a special church event this Sunday',
      );

      // Submit
      await tester.tap(find.text('Submit for Approval'));
      await tester.pumpAndSettle();

      // Assert
      final captured = verify(mockPostProvider.createPost(captureAny)).captured;
      final post = captured.first as Post;

      expect(post.title, equals('Church Event'));
      expect(
        post.content,
        equals('Join us for a special church event this Sunday'),
      );
      expect(post.type, equals(PostType.event));
      expect(post.status, equals(PostStatus.pending));
      expect(post.authorId, equals('user123'));
      expect(post.attachments, isEmpty);
    });
  });
}
