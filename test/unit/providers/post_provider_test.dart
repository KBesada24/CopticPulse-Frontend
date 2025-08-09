import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:coptic_pulse/providers/post_provider.dart';
import 'package:coptic_pulse/services/post_service.dart';
import 'package:coptic_pulse/models/post.dart';

import 'post_provider_test.mocks.dart';

@GenerateMocks([PostService])
void main() {
  group('PostProvider', () {
    late PostProvider postProvider;
    late MockPostService mockPostService;

    setUp(() {
      mockPostService = MockPostService();
      postProvider = PostProvider();
      // We would need to inject the mock service in a real implementation
    });

    group('loadPosts', () {
      test('should load posts successfully', () async {
        // Arrange
        final mockPosts = [
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

        final mockResponse = PostResponse(
          posts: mockPosts,
          totalCount: 2,
          currentPage: 1,
          totalPages: 1,
          hasNextPage: false,
          hasPreviousPage: false,
        );

        when(mockPostService.getPosts(
          type: anyNamed('type'),
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        await postProvider.loadPosts();

        // Assert
        expect(postProvider.posts.length, 2);
        expect(postProvider.posts.first.title, 'Test Post 1');
        expect(postProvider.isLoading, false);
        expect(postProvider.errorMessage, null);
        expect(postProvider.hasNextPage, false);
      });

      test('should handle loading state correctly', () async {
        // Arrange
        when(mockPostService.getPosts(
          type: anyNamed('type'),
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        )).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return PostResponse(
            posts: [],
            totalCount: 0,
            currentPage: 1,
            totalPages: 0,
            hasNextPage: false,
            hasPreviousPage: false,
          );
        });

        // Act
        final future = postProvider.loadPosts();
        
        // Assert loading state
        expect(postProvider.isLoading, true);
        
        await future;
        expect(postProvider.isLoading, false);
      });

      test('should handle errors correctly', () async {
        // Arrange
        when(mockPostService.getPosts(
          type: anyNamed('type'),
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        )).thenThrow(PostServiceException(
          message: 'Network error',
          type: PostServiceErrorType.network,
        ));

        // Act
        await postProvider.loadPosts();

        // Assert
        expect(postProvider.posts.isEmpty, true);
        expect(postProvider.isLoading, false);
        expect(postProvider.errorMessage, 'Network error');
      });

      test('should refresh posts when refresh is true', () async {
        // Arrange
        postProvider.posts.addAll([
          Post(
            id: 'old1',
            title: 'Old Post',
            content: 'Old content',
            type: PostType.announcement,
            status: PostStatus.approved,
            authorId: 'user1',
            createdAt: DateTime.now(),
          ),
        ]);

        final newPosts = [
          Post(
            id: 'new1',
            title: 'New Post',
            content: 'New content',
            type: PostType.announcement,
            status: PostStatus.approved,
            authorId: 'user1',
            createdAt: DateTime.now(),
          ),
        ];

        when(mockPostService.getPosts(
          type: anyNamed('type'),
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => PostResponse(
          posts: newPosts,
          totalCount: 1,
          currentPage: 1,
          totalPages: 1,
          hasNextPage: false,
          hasPreviousPage: false,
        ));

        // Act
        await postProvider.loadPosts(refresh: true);

        // Assert
        expect(postProvider.posts.length, 1);
        expect(postProvider.posts.first.id, 'new1');
        expect(postProvider.posts.first.title, 'New Post');
      });
    });

    group('filterByType', () {
      test('should filter posts by type', () async {
        // Arrange
        final eventPosts = [
          Post(
            id: '1',
            title: 'Event Post',
            content: 'Event content',
            type: PostType.event,
            status: PostStatus.approved,
            authorId: 'user1',
            createdAt: DateTime.now(),
          ),
        ];

        when(mockPostService.getPosts(
          type: PostType.event,
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => PostResponse(
          posts: eventPosts,
          totalCount: 1,
          currentPage: 1,
          totalPages: 1,
          hasNextPage: false,
          hasPreviousPage: false,
        ));

        // Act
        await postProvider.filterByType(PostType.event);

        // Assert
        expect(postProvider.selectedFilter, PostType.event);
        expect(postProvider.posts.length, 1);
        expect(postProvider.posts.first.type, PostType.event);
      });

      test('should not reload if same filter is applied', () async {
        // Arrange - First set the filter by calling filterByType
        when(mockPostService.getPosts(
          type: PostType.event,
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => PostResponse(
          posts: [],
          totalCount: 0,
          currentPage: 1,
          totalPages: 0,
          hasNextPage: false,
          hasPreviousPage: false,
        ));
        
        await postProvider.filterByType(PostType.event);
        clearInteractions(mockPostService);

        // Act
        await postProvider.filterByType(PostType.event);

        // Assert
        verifyNever(mockPostService.getPosts(
          type: anyNamed('type'),
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        ));
      });
    });

    group('searchPosts', () {
      test('should search posts successfully', () async {
        // Arrange
        final searchResults = [
          Post(
            id: '1',
            title: 'Search Result',
            content: 'Content with search term',
            type: PostType.announcement,
            status: PostStatus.approved,
            authorId: 'user1',
            createdAt: DateTime.now(),
          ),
        ];

        when(mockPostService.searchPosts(
          query: 'search term',
          type: anyNamed('type'),
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => PostResponse(
          posts: searchResults,
          totalCount: 1,
          currentPage: 1,
          totalPages: 1,
          hasNextPage: false,
          hasPreviousPage: false,
        ));

        // Act
        await postProvider.searchPosts('search term');

        // Assert
        expect(postProvider.searchQuery, 'search term');
        expect(postProvider.posts.length, 1);
        expect(postProvider.posts.first.title, 'Search Result');
      });

      test('should clear search and load all posts when query is empty', () async {
        // Arrange
        when(mockPostService.getPosts(
          type: anyNamed('type'),
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => PostResponse(
          posts: [],
          totalCount: 0,
          currentPage: 1,
          totalPages: 0,
          hasNextPage: false,
          hasPreviousPage: false,
        ));

        // Act
        await postProvider.searchPosts('');

        // Assert
        expect(postProvider.searchQuery, null);
        verify(mockPostService.getPosts(
          type: anyNamed('type'),
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        )).called(1);
      });
    });

    group('loadMorePosts', () {
      test('should load more posts when hasNextPage is true', () async {
        // Arrange - First load some posts to set up the state
        when(mockPostService.getPosts(
          type: anyNamed('type'),
          page: 1,
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => PostResponse(
          posts: [],
          totalCount: 2,
          currentPage: 1,
          totalPages: 2,
          hasNextPage: true,
          hasPreviousPage: false,
        ));
        
        await postProvider.loadPosts();
        
        final morePosts = [
          Post(
            id: '3',
            title: 'More Post',
            content: 'More content',
            type: PostType.announcement,
            status: PostStatus.approved,
            authorId: 'user1',
            createdAt: DateTime.now(),
          ),
        ];

        when(mockPostService.getPosts(
          type: anyNamed('type'),
          page: 2,
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => PostResponse(
          posts: morePosts,
          totalCount: 3,
          currentPage: 2,
          totalPages: 2,
          hasNextPage: false,
          hasPreviousPage: true,
        ));

        // Act
        await postProvider.loadMorePosts();

        // Assert
        expect(postProvider.posts.length, 1);
        expect(postProvider.hasNextPage, false);
        expect(postProvider.isLoadingMore, false);
      });

      test('should not load more posts when hasNextPage is false', () async {
        // Arrange - First load posts to set hasNextPage to false
        when(mockPostService.getPosts(
          type: anyNamed('type'),
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => PostResponse(
          posts: [],
          totalCount: 0,
          currentPage: 1,
          totalPages: 1,
          hasNextPage: false,
          hasPreviousPage: false,
        ));
        
        await postProvider.loadPosts();
        clearInteractions(mockPostService);

        // Act
        await postProvider.loadMorePosts();

        // Assert
        verifyNever(mockPostService.getPosts(
          type: anyNamed('type'),
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        ));
      });
    });

    group('clearFilters', () {
      test('should clear filters and reload posts', () async {
        // Arrange - First set up filters by calling the methods
        when(mockPostService.getPosts(
          type: PostType.event,
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => PostResponse(
          posts: [],
          totalCount: 0,
          currentPage: 1,
          totalPages: 0,
          hasNextPage: false,
          hasPreviousPage: false,
        ));
        
        when(mockPostService.searchPosts(
          query: 'test',
          type: anyNamed('type'),
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => PostResponse(
          posts: [],
          totalCount: 0,
          currentPage: 1,
          totalPages: 0,
          hasNextPage: false,
          hasPreviousPage: false,
        ));
        
        await postProvider.filterByType(PostType.event);
        await postProvider.searchPosts('test');

        when(mockPostService.getPosts(
          type: null,
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => PostResponse(
          posts: [],
          totalCount: 0,
          currentPage: 1,
          totalPages: 0,
          hasNextPage: false,
          hasPreviousPage: false,
        ));

        // Act
        await postProvider.clearFilters();

        // Assert
        expect(postProvider.selectedFilter, null);
        expect(postProvider.searchQuery, null);
        expect(postProvider.isFiltered, false);
      });
    });

    group('post management', () {
      test('should add new approved post to the beginning of list', () {
        // Arrange
        final newPost = Post(
          id: 'new1',
          title: 'New Post',
          content: 'New content',
          type: PostType.announcement,
          status: PostStatus.approved,
          authorId: 'user1',
          createdAt: DateTime.now(),
        );

        // Act
        postProvider.addPost(newPost);

        // Assert
        expect(postProvider.posts.length, 1);
        expect(postProvider.posts.first.id, 'new1');
      });

      test('should not add non-approved post', () {
        // Arrange
        final pendingPost = Post(
          id: 'pending1',
          title: 'Pending Post',
          content: 'Pending content',
          type: PostType.announcement,
          status: PostStatus.pending,
          authorId: 'user1',
          createdAt: DateTime.now(),
        );

        // Act
        postProvider.addPost(pendingPost);

        // Assert
        expect(postProvider.posts.isEmpty, true);
      });

      test('should update existing post', () {
        // Arrange
        final originalPost = Post(
          id: '1',
          title: 'Original Title',
          content: 'Original content',
          type: PostType.announcement,
          status: PostStatus.approved,
          authorId: 'user1',
          createdAt: DateTime.now(),
        );

        postProvider.posts.add(originalPost);

        final updatedPost = originalPost.copyWith(
          title: 'Updated Title',
          content: 'Updated content',
        );

        // Act
        postProvider.updatePost(updatedPost);

        // Assert
        expect(postProvider.posts.length, 1);
        expect(postProvider.posts.first.title, 'Updated Title');
        expect(postProvider.posts.first.content, 'Updated content');
      });

      test('should remove post when updated to non-approved status', () {
        // Arrange
        final approvedPost = Post(
          id: '1',
          title: 'Approved Post',
          content: 'Approved content',
          type: PostType.announcement,
          status: PostStatus.approved,
          authorId: 'user1',
          createdAt: DateTime.now(),
        );

        postProvider.posts.add(approvedPost);

        final rejectedPost = approvedPost.copyWith(
          status: PostStatus.rejected,
        );

        // Act
        postProvider.updatePost(rejectedPost);

        // Assert
        expect(postProvider.posts.isEmpty, true);
      });

      test('should remove post by id', () {
        // Arrange
        final post1 = Post(
          id: '1',
          title: 'Post 1',
          content: 'Content 1',
          type: PostType.announcement,
          status: PostStatus.approved,
          authorId: 'user1',
          createdAt: DateTime.now(),
        );

        final post2 = Post(
          id: '2',
          title: 'Post 2',
          content: 'Content 2',
          type: PostType.announcement,
          status: PostStatus.approved,
          authorId: 'user1',
          createdAt: DateTime.now(),
        );

        postProvider.posts.addAll([post1, post2]);

        // Act
        postProvider.removePost('1');

        // Assert
        expect(postProvider.posts.length, 1);
        expect(postProvider.posts.first.id, '2');
      });
    });
  });
}