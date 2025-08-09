import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:coptic_pulse/services/approval_service.dart';
import 'package:coptic_pulse/services/api_service.dart';
import 'package:coptic_pulse/models/post.dart';

import 'approval_service_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  group('ApprovalService Tests', () {
    late ApprovalService approvalService;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      approvalService = ApprovalService(apiService: mockApiService);
    });

    group('getApprovalStats', () {
      test('should return approval statistics when API call succeeds', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'pendingCount': 5,
            'approvedToday': 3,
            'rejectedToday': 1,
            'totalProcessed': 25,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/approvals/stats'),
        );

        when(mockApiService.get(
          any,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await approvalService.getApprovalStats();

        // Assert
        expect(result.pendingCount, equals(5));
        expect(result.approvedToday, equals(3));
        expect(result.rejectedToday, equals(1));
        expect(result.totalProcessed, equals(25));
        verify(mockApiService.get(
          any,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).called(1);
      });

      test('should throw ApprovalServiceException when API call fails', () async {
        // Arrange
        when(mockApiService.get(
          any,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/approvals/stats'),
          message: 'Network error',
        ));

        // Act & Assert
        expect(
          () => approvalService.getApprovalStats(),
          throwsA(isA<ApprovalServiceException>()),
        );
      });
    });

    group('getPendingPosts', () {
      test('should return pending posts when API call succeeds', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'data': [
              {
                'id': '1',
                'title': 'Test Post',
                'content': 'Test content',
                'type': 'announcement',
                'status': 'pending',
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
          requestOptions: RequestOptions(path: '/approvals'),
        );

        when(mockApiService.get(
          any,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await approvalService.getPendingPosts();

        // Assert
        expect(result.posts.length, equals(1));
        expect(result.posts.first.title, equals('Test Post'));
        expect(result.posts.first.status, equals(PostStatus.pending));
        expect(result.totalCount, equals(1));
      });
    });

    group('approvePost', () {
      test('should return approved post when API call succeeds', () async {
        // Arrange
        const postId = 'post123';
        final mockResponse = Response(
          data: {
            'id': postId,
            'title': 'Test Post',
            'content': 'Test content',
            'type': 'announcement',
            'status': 'approved',
            'authorId': 'user1',
            'createdAt': '2024-01-01T00:00:00.000Z',
            'attachments': [],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/approvals/$postId/approve'),
        );

        when(mockApiService.post(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await approvalService.approvePost(postId);

        // Assert
        expect(result.id, equals(postId));
        expect(result.status, equals(PostStatus.approved));
        verify(mockApiService.post(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).called(1);
      });
    });

    group('rejectPost', () {
      test('should return rejected post when API call succeeds', () async {
        // Arrange
        const postId = 'post123';
        const reason = 'Inappropriate content';
        final mockResponse = Response(
          data: {
            'id': postId,
            'title': 'Test Post',
            'content': 'Test content',
            'type': 'announcement',
            'status': 'rejected',
            'authorId': 'user1',
            'createdAt': '2024-01-01T00:00:00.000Z',
            'attachments': [],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/approvals/$postId/reject'),
        );

        when(mockApiService.post(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await approvalService.rejectPost(postId, reason: reason);

        // Assert
        expect(result.id, equals(postId));
        expect(result.status, equals(PostStatus.rejected));
        verify(mockApiService.post(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).called(1);
      });

      test('should reject post without reason when reason is not provided', () async {
        // Arrange
        const postId = 'post123';
        final mockResponse = Response(
          data: {
            'id': postId,
            'title': 'Test Post',
            'content': 'Test content',
            'type': 'announcement',
            'status': 'rejected',
            'authorId': 'user1',
            'createdAt': '2024-01-01T00:00:00.000Z',
            'attachments': [],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/approvals/$postId/reject'),
        );

        when(mockApiService.post(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await approvalService.rejectPost(postId);

        // Assert
        expect(result.id, equals(postId));
        expect(result.status, equals(PostStatus.rejected));
        verify(mockApiService.post(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).called(1);
      });
    });

    group('requestRevision', () {
      test('should return post with revision request when API call succeeds', () async {
        // Arrange
        const postId = 'post123';
        const feedback = 'Please add more details';
        final mockResponse = Response(
          data: {
            'id': postId,
            'title': 'Test Post',
            'content': 'Test content',
            'type': 'announcement',
            'status': 'pending',
            'authorId': 'user1',
            'createdAt': '2024-01-01T00:00:00.000Z',
            'attachments': [],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/approvals/$postId/revision'),
        );

        when(mockApiService.post(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await approvalService.requestRevision(postId, feedback);

        // Assert
        expect(result.id, equals(postId));
        verify(mockApiService.post(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).called(1);
      });
    });
  });

  group('ApprovalStats Tests', () {
    test('should create ApprovalStats from JSON correctly', () {
      // Arrange
      final json = {
        'pendingCount': 10,
        'approvedToday': 5,
        'rejectedToday': 2,
        'totalProcessed': 50,
      };

      // Act
      final stats = ApprovalStats.fromJson(json);

      // Assert
      expect(stats.pendingCount, equals(10));
      expect(stats.approvedToday, equals(5));
      expect(stats.rejectedToday, equals(2));
      expect(stats.totalProcessed, equals(50));
    });
  });

  group('ApprovalServiceException Tests', () {
    test('should identify network errors correctly', () {
      // Arrange
      const exception = ApprovalServiceException(
        message: 'Network error',
        type: ApprovalServiceErrorType.network,
      );

      // Assert
      expect(exception.isNetworkError, isTrue);
      expect(exception.isAuthError, isFalse);
      expect(exception.isAuthorizationError, isFalse);
      expect(exception.isServerError, isFalse);
    });

    test('should identify auth errors correctly', () {
      // Arrange
      const exception = ApprovalServiceException(
        message: 'Authentication failed',
        type: ApprovalServiceErrorType.authentication,
      );

      // Assert
      expect(exception.isAuthError, isTrue);
      expect(exception.isNetworkError, isFalse);
      expect(exception.isAuthorizationError, isFalse);
      expect(exception.isServerError, isFalse);
    });

    test('should identify authorization errors correctly', () {
      // Arrange
      const exception = ApprovalServiceException(
        message: 'Access denied',
        type: ApprovalServiceErrorType.authorization,
      );

      // Assert
      expect(exception.isAuthorizationError, isTrue);
      expect(exception.isAuthError, isFalse);
      expect(exception.isNetworkError, isFalse);
      expect(exception.isServerError, isFalse);
    });

    test('should identify server errors correctly', () {
      // Arrange
      const exception = ApprovalServiceException(
        message: 'Internal server error',
        type: ApprovalServiceErrorType.server,
      );

      // Assert
      expect(exception.isServerError, isTrue);
      expect(exception.isAuthError, isFalse);
      expect(exception.isNetworkError, isFalse);
      expect(exception.isAuthorizationError, isFalse);
    });

    test('should format toString correctly', () {
      // Arrange
      const exception = ApprovalServiceException(
        message: 'Test error',
        type: ApprovalServiceErrorType.network,
        statusCode: 500,
      );

      // Act
      final result = exception.toString();

      // Assert
      expect(result, contains('ApprovalServiceException'));
      expect(result, contains('network'));
      expect(result, contains('Test error'));
      expect(result, contains('500'));
    });
  });
}