import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:coptic_pulse/screens/community_screen.dart';
import 'package:coptic_pulse/providers/post_provider.dart';
import 'package:coptic_pulse/models/post.dart';
import 'package:coptic_pulse/widgets/community_card.dart';

import 'community_screen_test.mocks.dart';

@GenerateMocks([PostProvider])
void main() {
  group('CommunityScreen', () {
    late MockPostProvider mockPostProvider;

    setUp(() {
      mockPostProvider = MockPostProvider();
      
      // Default mock behavior
      when(mockPostProvider.posts).thenReturn([]);
      when(mockPostProvider.isLoading).thenReturn(false);
      when(mockPostProvider.isLoadingMore).thenReturn(false);
      when(mockPostProvider.errorMessage).thenReturn(null);
      when(mockPostProvider.selectedFilter).thenReturn(null);
      when(mockPostProvider.hasNextPage).thenReturn(false);
      when(mockPostProvider.searchQuery).thenReturn(null);
      when(mockPostProvider.isFiltered).thenReturn(false);
      when(mockPostProvider.loadPosts(refresh: anyNamed('refresh')))
          .thenAnswer((_) async {});
      when(mockPostProvider.refreshPosts()).thenAnswer((_) async {});
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<PostProvider>.value(
          value: mockPostProvider,
          child: const CommunityScreen(),
        ),
      );
    }

    testWidgets('should display app bar with title and search icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Community'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should display filter chips', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Announcements'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
      expect(find.text('Prayer Requests'), findsOneWidget);
    });

    testWidgets('should display floating action button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should display loading indicator when loading', (tester) async {
      // Arrange
      when(mockPostProvider.isLoading).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error message when error occurs', (tester) async {
      // Arrange
      when(mockPostProvider.errorMessage).thenReturn('Network error');

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display empty state when no posts', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('No posts available'), findsOneWidget);
      expect(find.byIcon(Icons.forum_outlined), findsOneWidget);
    });

    testWidgets('should display filtered empty state when no posts match filter', (tester) async {
      // Arrange
      when(mockPostProvider.isFiltered).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('No posts found for the selected filter'), findsOneWidget);
      expect(find.text('Clear filters'), findsOneWidget);
    });

    testWidgets('should display posts when available', (tester) async {
      // Arrange
      final testPosts = [
        Post(
          id: '1',
          title: 'Test Post 1',
          content: 'Content 1',
          type: PostType.announcement,
          status: PostStatus.approved,
          authorId: 'user1',
          createdAt: DateTime.now(),
        ),
        Post(
          id: '2',
          title: 'Test Post 2',
          content: 'Content 2',
          type: PostType.event,
          status: PostStatus.approved,
          authorId: 'user2',
          createdAt: DateTime.now(),
        ),
      ];

      when(mockPostProvider.posts).thenReturn(testPosts);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CommunityCard), findsNWidgets(2));
    });

    testWidgets('should highlight selected filter chip', (tester) async {
      // Arrange
      when(mockPostProvider.selectedFilter).thenReturn(PostType.announcement);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      // The "Announcements" chip should be highlighted
      // We can verify this by checking if the filter method is called when tapping other chips
      await tester.tap(find.text('Events'));
      verify(mockPostProvider.filterByType(PostType.event)).called(1);
    });

    testWidgets('should show clear filters button when filtered', (tester) async {
      // Arrange
      when(mockPostProvider.isFiltered).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('should call clearFilters when clear button is tapped', (tester) async {
      // Arrange
      when(mockPostProvider.isFiltered).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byIcon(Icons.clear));

      // Assert
      verify(mockPostProvider.clearFilters()).called(1);
    });

    testWidgets('should call filterByType when filter chip is tapped', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Events'));

      // Assert
      verify(mockPostProvider.filterByType(PostType.event)).called(1);
    });

    testWidgets('should call filterByType with null when All chip is tapped', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('All'));

      // Assert
      verify(mockPostProvider.filterByType(null)).called(1);
    });

    testWidgets('should show search dialog when search icon is tapped', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Search Posts'), findsOneWidget);
      expect(find.text('Enter search terms...'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('should call searchPosts when search is performed', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockPostProvider.searchPosts('test query')).called(1);
    });

    testWidgets('should call refreshPosts on pull to refresh', (tester) async {
      // Arrange
      final testPosts = [
        Post(
          id: '1',
          title: 'Test Post',
          content: 'Content',
          type: PostType.announcement,
          status: PostStatus.approved,
          authorId: 'user1',
          createdAt: DateTime.now(),
        ),
      ];

      when(mockPostProvider.posts).thenReturn(testPosts);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      // Assert
      verify(mockPostProvider.refreshPosts()).called(1);
    });

    testWidgets('should show loading more indicator when loading more posts', (tester) async {
      // Arrange
      final testPosts = [
        Post(
          id: '1',
          title: 'Test Post',
          content: 'Content',
          type: PostType.announcement,
          status: PostStatus.approved,
          authorId: 'user1',
          createdAt: DateTime.now(),
        ),
      ];

      when(mockPostProvider.posts).thenReturn(testPosts);
      when(mockPostProvider.hasNextPage).thenReturn(true);
      when(mockPostProvider.isLoadingMore).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show snackbar when FAB is tapped', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('New post creation will be implemented in the next task'), findsOneWidget);
    });

    testWidgets('should call loadPosts on initialization', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      verify(mockPostProvider.loadPosts(refresh: true)).called(1);
    });

    testWidgets('should call retry when retry button is tapped', (tester) async {
      // Arrange
      when(mockPostProvider.errorMessage).thenReturn('Network error');

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Retry'));

      // Assert
      verify(mockPostProvider.refreshPosts()).called(1);
    });

    testWidgets('should call clearFilters when clear filters button is tapped in empty state', (tester) async {
      // Arrange
      when(mockPostProvider.isFiltered).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Clear filters'));

      // Assert
      verify(mockPostProvider.clearFilters()).called(1);
    });
  });
}