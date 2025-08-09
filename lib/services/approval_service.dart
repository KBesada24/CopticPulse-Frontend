import 'package:dio/dio.dart';
import '../models/post.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'post_service.dart';

/// Service for handling post approval operations (admin only)
class ApprovalService {
  final ApiService _apiService;

  ApprovalService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  /// Get pending posts awaiting approval
  Future<PostResponse> getPendingPosts({
    int page = 1,
    int limit = AppConstants.defaultPageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'status': PostStatus.pending.name,
      };

      final response = await _apiService.get(
        AppConstants.approvalsEndpoint,
        queryParameters: queryParams,
      );

      return PostResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Approve a pending post
  Future<Post> approvePost(String postId) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.approvalsEndpoint}/$postId/approve',
      );
      return Post.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Reject a pending post
  Future<Post> rejectPost(String postId, {String? reason}) async {
    try {
      final data = <String, dynamic>{};
      if (reason != null && reason.isNotEmpty) {
        data['reason'] = reason;
      }

      final response = await _apiService.post(
        '${AppConstants.approvalsEndpoint}/$postId/reject',
        data: data,
      );
      return Post.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Request revision for a pending post
  Future<Post> requestRevision(String postId, String feedback) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.approvalsEndpoint}/$postId/revision',
        data: {'feedback': feedback},
      );
      return Post.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get approval statistics for admin dashboard
  Future<ApprovalStats> getApprovalStats() async {
    try {
      final response = await _apiService.get(
        '${AppConstants.approvalsEndpoint}/stats',
      );
      return ApprovalStats.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle API errors and convert to ApprovalServiceException
  ApprovalServiceException _handleError(DioException error) {
    final apiError = error.error;
    if (apiError is ApiError) {
      return ApprovalServiceException(
        message: apiError.message,
        type: _mapErrorType(apiError.type),
        statusCode: apiError.statusCode,
      );
    }
    
    return ApprovalServiceException(
      message: error.message ?? 'Unknown error occurred',
      type: ApprovalServiceErrorType.unknown,
    );
  }

  /// Map API error types to approval service error types
  ApprovalServiceErrorType _mapErrorType(ApiErrorType apiErrorType) {
    switch (apiErrorType) {
      case ApiErrorType.network:
      case ApiErrorType.timeout:
        return ApprovalServiceErrorType.network;
      case ApiErrorType.authentication:
        return ApprovalServiceErrorType.authentication;
      case ApiErrorType.authorization:
        return ApprovalServiceErrorType.authorization;
      case ApiErrorType.validation:
        return ApprovalServiceErrorType.validation;
      case ApiErrorType.notFound:
        return ApprovalServiceErrorType.notFound;
      case ApiErrorType.server:
        return ApprovalServiceErrorType.server;
      default:
        return ApprovalServiceErrorType.unknown;
    }
  }
}

/// Statistics for approval dashboard
class ApprovalStats {
  final int pendingCount;
  final int approvedToday;
  final int rejectedToday;
  final int totalProcessed;

  const ApprovalStats({
    required this.pendingCount,
    required this.approvedToday,
    required this.rejectedToday,
    required this.totalProcessed,
  });

  factory ApprovalStats.fromJson(Map<String, dynamic> json) {
    return ApprovalStats(
      pendingCount: json['pendingCount'] as int,
      approvedToday: json['approvedToday'] as int,
      rejectedToday: json['rejectedToday'] as int,
      totalProcessed: json['totalProcessed'] as int,
    );
  }
}

/// Exception types for approval service operations
enum ApprovalServiceErrorType {
  network,
  authentication,
  authorization,
  validation,
  notFound,
  server,
  unknown,
}

/// Custom exception for approval service errors
class ApprovalServiceException implements Exception {
  final String message;
  final ApprovalServiceErrorType type;
  final int? statusCode;

  const ApprovalServiceException({
    required this.message,
    required this.type,
    this.statusCode,
  });

  @override
  String toString() {
    return 'ApprovalServiceException(type: $type, message: $message, statusCode: $statusCode)';
  }

  /// Check if error is related to network connectivity
  bool get isNetworkError => type == ApprovalServiceErrorType.network;

  /// Check if error is related to authentication
  bool get isAuthError => type == ApprovalServiceErrorType.authentication;

  /// Check if error is related to authorization (admin access required)
  bool get isAuthorizationError => type == ApprovalServiceErrorType.authorization;

  /// Check if error is a server error
  bool get isServerError => type == ApprovalServiceErrorType.server;
}