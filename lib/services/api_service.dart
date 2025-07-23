import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

/// Base API service class that handles HTTP communication with the backend
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Dio? _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Initialize the API service with Dio configuration
  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: Duration(seconds: AppConstants.requestTimeoutSeconds),
      receiveTimeout: Duration(seconds: AppConstants.requestTimeoutSeconds),
      sendTimeout: Duration(seconds: AppConstants.requestTimeoutSeconds),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio!.interceptors.add(_createAuthInterceptor());
    _dio!.interceptors.add(_createErrorInterceptor());
    _dio!.interceptors.add(_createLoggingInterceptor());
  }

  /// Get the configured Dio instance
  Dio get dio {
    if (_dio == null) {
      initialize();
    }
    return _dio!;
  }

  /// Create authentication interceptor for JWT token handling
  Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add authorization header if token exists
        final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle token refresh on 401 errors
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the original request with new token
            final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            
            try {
              final response = await dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            } catch (e) {
              // If retry fails, continue with original error
            }
          }
        }
        handler.next(error);
      },
    );
  }

  /// Create error interceptor for standardized error handling
  Interceptor _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        final apiError = _handleError(error);
        handler.next(DioException(
          requestOptions: error.requestOptions,
          error: apiError,
          type: error.type,
          response: error.response,
        ));
      },
    );
  }

  /// Create logging interceptor for development
  Interceptor _createLoggingInterceptor() {
    return LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
      logPrint: (object) {
        // Only log in debug mode
        assert(() {
          print('[API] $object');
          return true;
        }());
      },
    );
  }

  /// Handle and standardize API errors
  ApiError _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError(
          type: ApiErrorType.timeout,
          message: 'Request timeout. Please try again.',
          statusCode: null,
        );
      
      case DioExceptionType.connectionError:
        return ApiError(
          type: ApiErrorType.network,
          message: AppConstants.networkErrorMessage,
          statusCode: null,
        );
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _extractErrorMessage(error.response?.data);
        
        switch (statusCode) {
          case 400:
            return ApiError(
              type: ApiErrorType.validation,
              message: message ?? AppConstants.validationErrorMessage,
              statusCode: statusCode,
            );
          case 401:
            return ApiError(
              type: ApiErrorType.authentication,
              message: message ?? AppConstants.authErrorMessage,
              statusCode: statusCode,
            );
          case 403:
            return ApiError(
              type: ApiErrorType.authorization,
              message: message ?? 'Access denied.',
              statusCode: statusCode,
            );
          case 404:
            return ApiError(
              type: ApiErrorType.notFound,
              message: message ?? 'Resource not found.',
              statusCode: statusCode,
            );
          case 500:
          default:
            return ApiError(
              type: ApiErrorType.server,
              message: message ?? AppConstants.serverErrorMessage,
              statusCode: statusCode,
            );
        }
      
      case DioExceptionType.cancel:
        return ApiError(
          type: ApiErrorType.cancelled,
          message: 'Request was cancelled.',
          statusCode: null,
        );
      
      case DioExceptionType.unknown:
      default:
        return ApiError(
          type: ApiErrorType.unknown,
          message: AppConstants.unknownErrorMessage,
          statusCode: null,
        );
    }
  }

  /// Extract error message from response data
  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] ?? data['error'] ?? data['detail'];
    }
    return null;
  }

  /// Refresh the authentication token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: AppConstants.refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await dio.post(
        AppConstants.refreshTokenEndpoint,
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Authorization': null}, // Remove auth header for refresh
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _secureStorage.write(
          key: AppConstants.accessTokenKey,
          value: data['access_token'],
        );
        
        if (data['refresh_token'] != null) {
          await _secureStorage.write(
            key: AppConstants.refreshTokenKey,
            value: data['refresh_token'],
          );
        }
        
        return true;
      }
    } catch (e) {
      // Refresh failed, clear tokens
      await _clearTokens();
    }
    
    return false;
  }

  /// Clear stored authentication tokens
  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: AppConstants.accessTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }

  /// Perform GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Perform POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Perform PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Perform DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Upload file with progress tracking
  Future<Response<T>> uploadFile<T>(
    String path,
    File file, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(file.path),
      ...?data,
    });

    return await dio.post<T>(
      path,
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
      onSendProgress: onSendProgress,
    );
  }
}

/// API error types for categorizing different error scenarios
enum ApiErrorType {
  network,
  timeout,
  authentication,
  authorization,
  validation,
  notFound,
  server,
  cancelled,
  unknown,
}

/// Standardized API error class
class ApiError {
  final ApiErrorType type;
  final String message;
  final int? statusCode;
  final dynamic details;

  const ApiError({
    required this.type,
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    return 'ApiError(type: $type, message: $message, statusCode: $statusCode)';
  }

  /// Check if error is related to authentication
  bool get isAuthError => type == ApiErrorType.authentication;

  /// Check if error is related to network connectivity
  bool get isNetworkError => type == ApiErrorType.network || type == ApiErrorType.timeout;

  /// Check if error is a server error
  bool get isServerError => type == ApiErrorType.server;

  /// Check if error is a validation error
  bool get isValidationError => type == ApiErrorType.validation;
}