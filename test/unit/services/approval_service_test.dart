import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:coptic_pulse/services/approval_service.dart';
import 'package:coptic_pulse/services/api_service.dart';
import 'package:coptic_pulse/models/post.dart';
import 'package:coptic_pulse/utils/constants.dart';

import 'approval_service_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  group('ApprovalService', () {
    late ApprovalService approvalService;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      approvalService = ApprovalService(apiService: mockApiService);
    });

    group('getPendingPosts', () {
      test('should return pending posts successfully', () async {
        // Arrange
        final mockResponse = Response(
          requestOptions: RequestOptions(path: ''),
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
        );

        when(mockApiService.get(
          AppConstants.approvalsEndpoint,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await approvalService.getPendingPosts();

        // Assert
        expect(result.posts.length, 1);
        expect(result.posts.first.id, '1');
        expect(result.posts.first.title, 'Test Post');
        expect(result.posts.first.status, PostStatus.pending);
        expect(result.totalCount, 1);
        expect(result.hasNextPage, false);

        verify(mockApiService.get(
          AppConstants.approvalsEndpoint,
          queryParameters: {
            'page': 1,
            'limit': AppConstants.defaultPageSize,
            'status': 'pending',
          },
        )).called(1);
      });

      test('should handle pagination parameters correctly', () async {
        // Arrange
        final mockResponse = Response(
          requestOptions: RequestOptions(path: ''),
          data: {
            'data': [],
            'totalCount': 0,
            'currentPage': 2,
            'totalPages': 3,
            'hasNextPage': true,
            'hasPreviousPage': true,
          },
        );

        when(mockApiService.get(
          AppConstants.approvalsEndpoint,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        await approvalService.getPendingPosts(page: 2, limit: 10);

        // Assert
        verify(mockApiService.get(
          AppConstants.approvalsEndpoint,
          queryParameters: {
            'page': 2,
            'limit': 10,
            'status': 'pending',
          },
        )).called(1);
      });

      test('should throw ApprovalServiceException on API error', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: ''),
          error: const ApiError(
            type: ApiErrorType.server,
            message: 'Server error',
            statusCode: 500,
          ),
        );

        when(mockApiService.get(
          AppConstants.approvalsEndpoint,
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => approvalService.getPendingPosts(),
          throwsA(isA<ApprovalServiceException>()
              .having((e) => e.type, 'type', ApprovalServiceErrorType.server)
              .having((e) => e.message, 'message', 'Server error')),
        );
      });
    });

    group('approvePost', () {
      test('should approve post successfully', () async {
        // Arrange
        const postId = 'post123';
        final mockResponse = Response(
          requestOptions: RequestOptions(path: ''),
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
        );

        when(mockApiService.post('${AppConstants.approvalsEndpoint}/$postId/approve'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await approvalService.approvePost(postId);

        // Assert
        expect(result.id, postId);
        expect(result.status, PostStatus.approved);

        verify(mockApiService.post('${AppConstants.approvalsEndpoint}/$postId/approve'))
            .called(1);
      });

      test('should throw ApprovalServiceException on API error', () async {
        // Arrange
        const postId = 'post123';
        final dioException = DioException(
          requestOptions: RequestOptions(path: ''),
          error: const ApiError(
            type: ApiErrorType.authorization,
            message: 'Access denied',
            statusCode: 403,
          ),
        );

        when(mockApiService.post('${AppConstants.approvalsEndpoint}/$postId/approve'))
            .thenThrow(dioException);

        // Act & Assert
        expect(
          () => approvalService.approvePost(postId),
          throwsA(isA<ApprovalServiceException>()
              .having((e) => e.type, 'type', ApprovalServiceErrorType.authorization)
              .having((e) => e.message, 'message', 'Access denied')),
        );
      });
    });

    group('rejectPost', () {
      test('should reject post successfully without reason', () async {
        // Arrange
        const postId = 'post123';
        final mockResponse = Response(
          requestOptions: RequestOptions(path: ''),
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
        );

        when(mockApiService.post(
          '${AppConstants.approvalsEndpoint}/$postId/reject',
          data: anyNamed('data'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await approvalService.rejectPost(postId);

        // Assert
        expect(result.id, postId);
        expect(result.status, PostStatus.rejected);

        verify(mockApiService.post(
          '${AppConstants.approvalsEndpoint}/$postId/reject',
          data: {},
        )).called(1);
      });

      test('should reject post successfully with reason', () async {
        // Arrange
        const postId = 'post123';
        const reason = 'Inappropriate content';
        final mockResponse = Response(
          requestOptions: RequestOptions(path: ''),
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
        );

        when(mockApiService.post(
          '${AppConstants.approvalsEndpoint}/$postId/reject',
          data: anyNamed('data'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await approvalService.rejectPost(postId, reason: reason);

        // Assert
        expect(result.id, postId);
        expect(result.status, PostStatus.rejected);

        verify(mockApiService.post(
          '${AppConstants.approvalsEndpoint}/$postId/reject',
          data: {'reason': reason},
        )).called(1);
      });
    });

    group('requestRevision', () {
      test('should request revision successfully', () async {
        // Arrange
        const postId = 'post123';
        const feedback = 'Please add more details';
        final mockResponse = Response(
          requestOptions: RequestOptions(path: ''),
          data: {
            'id': postId,
            'title': 'Test Post',
            'content': 'Test content',
            'type': 'announcement',
            'status': 'draft',
            'authorId': 'user1',
            'createdAt': '2024-01-01T00:00:00.000Z',
            'attachments': [],
          },
        );

        when(mockApiService.post(
          '${AppConstants.approvalsEndpoint}/$postId/revision',
          data: anyNamed('data'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await approvalService.requestRevision(postId, feedback);

        // Assert
        expect(result.id, postId);
        expect(result.status, PostStatus.draft);

        verify(mockApiService.post(
          '${AppConstants.approvalsEndpoint}/$postId/revision',
          data: {'feedback': feedback},
        )).called(1);
      });

      test('should throw ApprovalServiceException on API error', () async {
        // Arrange
        const postId = 'post123';
        const feedback = 'Please add more details';
        final dioException = DioException(
          requestOptions: RequestOptions(path: ''),
          error: const ApiError(
            type: ApiErrorType.notFound,
            message: 'Post not found',
            statusCode: 404,
          ),
        );

        when(mockApiService.post(
          '${AppConstants.approvalsEndpoint}/$postId/revision',
          data: anyNamed('data'),
        )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => approvalService.requestRevision(postId, feedback),
          throwsA(isA<ApprovalServiceException>()
              .having((e) => e.type, 'type', ApprovalServiceErrorType.notFound)
              .having((e) => e.message, 'message', 'Post not found')),
        );
      });
    });

    group('getApprovalStats', () {
      test('should return approval statistics successfully', () async {
        // Arrange
        final mockResponse = Response(
          requestOptions: RequestOptions(path: ''),
          data: {
            'pendingCount': 5,
            'approvedToday': 3,
            'rejectedToday': 1,
            'totalProcessed': 25,
          },
        );

        when(mockApiService.get('${AppConstants.approvalsEndpoint}/stats'))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await approvalService.getApprovalStats();

        // Assert
        expect(result.pendingCount, 5);
        expect(result.approvedToday, 3);
        expect(result.rejectedToday, 1);
        expect(result.totalProcessed, 25);

        verify(mockApiService.get('${AppConstants.approvalsEndpoint}/stats'))
            .called(1);
      });

      test('should throw ApprovalServiceException on API error', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: ''),
          error: const ApiError(
            type: ApiErrorType.network,
            message: 'Network error',
          ),
        );

        when(mockApiService.get('${AppConstants.approvalsEndpoint}/stats'))
            .thenThrow(dioException);

        // Act & Assert
        expect(
          () => approvalService.getApprovalStats(),
          throwsA(isA<ApprovalServiceException>()
              .having((e) => e.type, 'type', ApprovalServiceErrorType.network)
              .having((e) => e.message, 'message', 'Network error')),
        );
      });
    });

    group('error handling', () {
      test('should map API error types correctly', () async {
        // Test different error type mappings
        final testCases = [
          (ApiErrorType.network, ApprovalServiceErrorType.network),
          (ApiErrorType.timeout, ApprovalServiceErrorType.network),
          (ApiErrorType.authentication, ApprovalServiceErrorType.authentication),
          (ApiErrorType.authorization, ApprovalServiceErrorType.authorization),
          (ApiErrorType.validation, ApprovalServiceErrorType.validation),
          (ApiErrorType.notFound, ApprovalServiceErrorType.notFound),
          (ApiErrorType.server, ApprovalServiceErrorType.server),
          (ApiErrorType.unknown, ApprovalServiceErrorType.unknown),
        ];

        for (final (apiErrorType, expectedServiceErrorType) in testCases) {
          // Arrange
          final dioException = DioException(
            requestOptions: RequestOptions(path: ''),
            error: ApiError(
              type: apiErrorType,
              message: 'Test error',
            ),
          );

          when(mockApiService.get(
            AppConstants.approvalsEndpoint,
            queryParameters: anyNamed('queryParameters'),
          )).thenThrow(dioException);

          // Act & Assert
          expect(
            () => approvalService.getPendingPosts(),
            throwsA(isA<ApprovalServiceException>()
                .having((e) => e.type, 'type', expectedServiceErrorType)),
          );

          reset(mockApiService);
        }
      });

      test('should handle unknown DioException correctly', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Unknown error',
        );

        when(mockApiService.get(
          AppConstants.approvalsEndpoint,
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(dioException);

        // Act & Assert
        expect(
          () => approvalService.getPendingPosts(),
          throwsA(isA<ApprovalServiceException>()
              .having((e) => e.type, 'type', ApprovalServiceErrorType.unknown)
              .having((e) => e.message, 'message', 'Unknown error')),
        );
      });
    });

    group('ApprovalServiceException', () {
      test('should have correct properties', () {
        const exception = ApprovalServiceException(
          message: 'Test error',
          type: ApprovalServiceErrorType.network,
          statusCode: 500,
        );

        expect(exception.message, 'Test error');
        expect(exception.type, ApprovalServiceErrorType.network);
        expect(exception.statusCode, 500);
        expect(exception.isNetworkError, true);
        expect(exception.isAuthError, false);
        expect(exception.isAuthorizationError, false);
        expect(exception.isServerError, false);
      });

      test('should identify error types correctly', () {
        const networkException = ApprovalServiceException(
          message: 'Network error',
          type: ApprovalServiceErrorType.network,
        );
        expect(networkException.isNetworkError, true);

        const authException = ApprovalServiceException(
          message: 'Auth error',
          type: ApprovalServiceErrorType.authentication,
        );
        expect(authException.isAuthError, true);

        const authorizationException = ApprovalServiceException(
          message: 'Authorization error',
          type: ApprovalServiceErrorType.authorization,
        );
        expect(authorizationException.isAuthorizationError, true);

        const serverException = ApprovalServiceException(
          message: 'Server error',
          type: ApprovalServiceErrorType.server,
        );
        expect(serverException.isServerError, true);
      });

      test('should have correct toString representation', () {
        const exception = ApprovalServiceException(
          message: 'Test error',
          type: ApprovalServiceErrorType.validation,
          statusCode: 400,
        );

        expect(
          exception.toString(),
          'ApprovalServiceException(type: ApprovalServiceErrorType.validation, message: Test error, statusCode: 400)',
        );
      });
    });
  });
}