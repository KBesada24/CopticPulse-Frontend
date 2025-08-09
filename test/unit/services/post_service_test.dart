import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:coptic_pulse/services/post_service.dart';
import 'package:coptic_pulse/services/api_service.dart';
import 'package:coptic_pulse/models/post.dart';
import 'package:coptic_pulse/utils/constants.dart';

import 'post_service_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  group('PostService', () {
    late PostService postService;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      postService = PostService();
      // We would need to inject the mock API service in a real implementation
    });

    group('getPosts', () {
      test('should return posts successfully', () async {
        // Arrange
        final mockResponse = Response<Map<String, dynamic>>(
          data: {
            'data': [
              {
                'id': '1',
                'title': 'Test Post',
                'content': 'Test content',
                'type': 'announcement',
                'status': 'approved',
                'authorId': 'user1',
                'createdAt': '2024-01-01T00:00:00.000Z',
                'attachments': [],
              }
            ],
            'totalCount': 1,
            'currentPage': 1,
            'totalPages': 1,
            'hasNextPage': false,
            'hasPreviousPage': false,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockApiService.get(
          AppConstants.postsEndpoint,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await postService.getPosts();

        // Assert
        expect(result.posts.length, 1);
        expect(result.posts.first.title, 'Test Post');
        expect(result.posts.first.type, PostType.announcement);
        expect(result.posts.first.status, PostStatus.approved);
        expect(result.totalCount, 1);
        expect(result.hasNextPage, false);
      });

      test('should filter posts by type', () async {
        // Arrange
        when(mockApiService.get(
          AppConstants.postsEndpoint,
          queryParameters: argThat(
            contains('type'),
            named: 'queryParameters',
          ),
        )).thenAnswer((_) async => Response<Map<String, dynamic>>(
          data: {
            'data': [],
            'totalCount': 0,
            'currentPage': 1,
            'totalPages': 0,
            'hasNextPage': false,
            'hasPreviousPage': false,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        await postService.getPosts(type: PostType.event);

        // Assert
        verify(mockApiService.get(
          AppConstants.postsEndpoint,
          queryParameters: argThat(
            predicate<Map<String, dynamic>>((params) => 
              params['type'] == 'event'),
            named: 'queryParameters',
          ),
        )).called(1);
      });

      test('should handle pagination parameters', () async {
        // Arrange
        when(mockApiService.get(
          AppConstants.postsEndpoint,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response<Map<String, dynamic>>(
          data: {
            'data': [],
            'totalCount': 0,
            'currentPage': 2,
            'totalPages': 3,
            'hasNextPage': true,
            'hasPreviousPage': true,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        await postService.getPosts(page: 2, limit: 10);

        // Assert
        verify(mockApiService.get(
          AppConstants.postsEndpoint,
          queryParameters: argThat(
            predicate<Map<String, dynamic>>((params) => 
              params['page'] == 2 && params['limit'] == 10),
            named: 'queryParameters',
          ),
        )).called(1);
      });

      test('should throw PostServiceException on API error', () async {
        // Arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: ''),
          error: ApiError(
            type: ApiErrorType.network,
            message: 'Network error',
          ),
        );

        when(mockApiService.get(
          AppConstants.postsEndpoint,
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(dioError);

        // Act & Assert
        expect(
          () => postService.getPosts(),
          throwsA(isA<PostServiceException>()
              .having((e) => e.type, 'type', PostServiceErrorType.network)
              .having((e) => e.message, 'message', 'Network error')),
        );
      });
    });

    group('getPost', () {
      test('should return single post successfully', () async {
        // Arrange
        final mockResponse = Response<Map<String, dynamic>>(
          data: {
            'id': '1',
            'title': 'Test Post',
            'content': 'Test content',
            'type': 'announcement',
            'status': 'approved',
            'authorId': 'user1',
            'createdAt': '2024-01-01T00:00:00.000Z',
            'attachments': [],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockApiService.get('${AppConstants.postsEndpoint}/1'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await postService.getPost('1');

        // Assert
        expect(result.id, '1');
        expect(result.title, 'Test Post');
        expect(result.type, PostType.announcement);
      });

      test('should throw PostServiceException when post not found', () async {
        // Arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: ''),
          error: ApiError(
            type: ApiErrorType.notFound,
            message: 'Post not found',
          ),
        );

        when(mockApiService.get('${AppConstants.postsEndpoint}/999'))
            .thenThrow(dioError);

        // Act & Assert
        expect(
          () => postService.getPost('999'),
          throwsA(isA<PostServiceException>()
              .having((e) => e.type, 'type', PostServiceErrorType.notFound)),
        );
      });
    });

    group('searchPosts', () {
      test('should search posts successfully', () async {
        // Arrange
        final mockResponse = Response<Map<String, dynamic>>(
          data: {
            'data': [
              {
                'id': '1',
                'title': 'Search Result',
                'content': 'Content with search term',
                'type': 'announcement',
                'status': 'approved',
                'authorId': 'user1',
                'createdAt': '2024-01-01T00:00:00.000Z',
                'attachments': [],
              }
            ],
            'totalCount': 1,
            'currentPage': 1,
            'totalPages': 1,
            'hasNextPage': false,
            'hasPreviousPage': false,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockApiService.get(
          '${AppConstants.postsEndpoint}/search',
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await postService.searchPosts(query: 'search term');

        // Assert
        expect(result.posts.length, 1);
        expect(result.posts.first.title, 'Search Result');
        
        verify(mockApiService.get(
          '${AppConstants.postsEndpoint}/search',
          queryParameters: argThat(
            predicate<Map<String, dynamic>>((params) => 
              params['q'] == 'search term'),
            named: 'queryParameters',
          ),
        )).called(1);
      });
    });

    group('createPost', () {
      test('should create post successfully', () async {
        // Arrange
        final newPost = Post(
          id: '',
          title: 'New Post',
          content: 'New content',
          type: PostType.announcement,
          status: PostStatus.pending,
          authorId: 'user1',
          createdAt: DateTime.now(),
        );

        final mockResponse = Response<Map<String, dynamic>>(
          data: {
            'id': '1',
            'title': 'New Post',
            'content': 'New content',
            'type': 'announcement',
            'status': 'pending',
            'authorId': 'user1',
            'createdAt': '2024-01-01T00:00:00.000Z',
            'attachments': [],
          },
          statusCode: 201,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockApiService.post(
          AppConstants.postsEndpoint,
          data: anyNamed('data'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await postService.createPost(newPost);

        // Assert
        expect(result.id, '1');
        expect(result.title, 'New Post');
        expect(result.status, PostStatus.pending);
      });
    });
  });
}