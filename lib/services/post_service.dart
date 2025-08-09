import 'package:dio/dio.dart';
import '../models/post.dart';
import '../utils/constants.dart';
import 'api_service.dart';

/// Service for handling post-related API operations
class PostService {
  final ApiService _apiService;

  PostService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  /// Get approved posts with optional filtering and pagination
  Future<PostResponse> getPosts({
    PostType? type,
    int page = 1,
    int limit = AppConstants.defaultPageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'status': PostStatus.approved.name,
      };

      if (type != null) {
        queryParams['type'] = type.name;
      }

      final response = await _apiService.get(
        AppConstants.postsEndpoint,
        queryParameters: queryParams,
      );

      return PostResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get a specific post by ID
  Future<Post> getPost(String id) async {
    try {
      final response = await _apiService.get('${AppConstants.postsEndpoint}/$id');
      return Post.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create a new post
  Future<Post> createPost(Post post) async {
    try {
      final response = await _apiService.post(
        AppConstants.postsEndpoint,
        data: post.toJson(),
      );
      return Post.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update an existing post
  Future<Post> updatePost(String id, Post post) async {
    try {
      final response = await _apiService.put(
        '${AppConstants.postsEndpoint}/$id',
        data: post.toJson(),
      );
      return Post.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete a post
  Future<void> deletePost(String id) async {
    try {
      await _apiService.delete('${AppConstants.postsEndpoint}/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Search posts by query
  Future<PostResponse> searchPosts({
    required String query,
    PostType? type,
    int page = 1,
    int limit = AppConstants.defaultPageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'page': page,
        'limit': limit,
        'status': PostStatus.approved.name,
      };

      if (type != null) {
        queryParams['type'] = type.name;
      }

      final response = await _apiService.get(
        '${AppConstants.postsEndpoint}/search',
        queryParameters: queryParams,
      );

      return PostResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle API errors and convert to PostServiceException
  PostServiceException _handleError(DioException error) {
    final apiError = error.error;
    if (apiError is ApiError) {
      return PostServiceException(
        message: apiError.message,
        type: _mapErrorType(apiError.type),
        statusCode: apiError.statusCode,
      );
    }
    
    return PostServiceException(
      message: error.message ?? 'Unknown error occurred',
      type: PostServiceErrorType.unknown,
    );
  }

  /// Map API error types to post service error types
  PostServiceErrorType _mapErrorType(ApiErrorType apiErrorType) {
    switch (apiErrorType) {
      case ApiErrorType.network:
      case ApiErrorType.timeout:
        return PostServiceErrorType.network;
      case ApiErrorType.authentication:
        return PostServiceErrorType.authentication;
      case ApiErrorType.authorization:
        return PostServiceErrorType.authorization;
      case ApiErrorType.validation:
        return PostServiceErrorType.validation;
      case ApiErrorType.notFound:
        return PostServiceErrorType.notFound;
      case ApiErrorType.server:
        return PostServiceErrorType.server;
      default:
        return PostServiceErrorType.unknown;
    }
  }
}

/// Response wrapper for paginated post data
class PostResponse {
  final List<Post> posts;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PostResponse({
    required this.posts,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      posts: (json['data'] as List<dynamic>)
          .map((item) => Post.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      currentPage: json['currentPage'] as int,
      totalPages: json['totalPages'] as int,
      hasNextPage: json['hasNextPage'] as bool,
      hasPreviousPage: json['hasPreviousPage'] as bool,
    );
  }
}

/// Exception types for post service operations
enum PostServiceErrorType {
  network,
  authentication,
  authorization,
  validation,
  notFound,
  server,
  unknown,
}

/// Custom exception for post service errors
class PostServiceException implements Exception {
  final String message;
  final PostServiceErrorType type;
  final int? statusCode;

  const PostServiceException({
    required this.message,
    required this.type,
    this.statusCode,
  });

  @override
  String toString() {
    return 'PostServiceException(type: $type, message: $message, statusCode: $statusCode)';
  }

  /// Check if error is related to network connectivity
  bool get isNetworkError => type == PostServiceErrorType.network;

  /// Check if error is related to authentication
  bool get isAuthError => type == PostServiceErrorType.authentication;

  /// Check if error is a server error
  bool get isServerError => type == PostServiceErrorType.server;
}