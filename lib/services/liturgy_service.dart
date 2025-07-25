import 'package:dio/dio.dart';
import '../models/liturgy_event.dart';
import '../utils/constants.dart';
import 'api_service.dart';

/// Service class for liturgy-related API operations
class LiturgyService {
  final ApiService _apiService = ApiService();

  /// Fetch all liturgy events
  Future<List<LiturgyEvent>> getLiturgyEvents({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.liturgyEventsEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> eventsData = response.data!['data'] ?? response.data!['events'] ?? [];
        return eventsData.map((json) => LiturgyEvent.fromJson(json)).toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleApiError(e);
    } catch (e) {
      throw LiturgyServiceException('Failed to fetch liturgy events: $e');
    }
  }

  /// Fetch liturgy events for a specific date
  Future<List<LiturgyEvent>> getLiturgyEventsForDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      return await getLiturgyEvents(
        startDate: startOfDay,
        endDate: endOfDay,
      );
    } catch (e) {
      throw LiturgyServiceException('Failed to fetch liturgy events for date: $e');
    }
  }

  /// Fetch upcoming liturgy events (next 30 days)
  Future<List<LiturgyEvent>> getUpcomingLiturgyEvents() async {
    try {
      final now = DateTime.now();
      final thirtyDaysFromNow = now.add(const Duration(days: 30));

      return await getLiturgyEvents(
        startDate: now,
        endDate: thirtyDaysFromNow,
      );
    } catch (e) {
      throw LiturgyServiceException('Failed to fetch upcoming liturgy events: $e');
    }
  }

  /// Fetch liturgy events for a specific month
  Future<List<LiturgyEvent>> getLiturgyEventsForMonth(DateTime month) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      return await getLiturgyEvents(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );
    } catch (e) {
      throw LiturgyServiceException('Failed to fetch liturgy events for month: $e');
    }
  }

  /// Fetch a specific liturgy event by ID
  Future<LiturgyEvent?> getLiturgyEvent(String id) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${AppConstants.liturgyEventsEndpoint}/$id',
      );

      if (response.statusCode == 200 && response.data != null) {
        return LiturgyEvent.fromJson(response.data!);
      }

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _handleApiError(e);
    } catch (e) {
      throw LiturgyServiceException('Failed to fetch liturgy event: $e');
    }
  }

  /// Handle API errors and convert to service-specific exceptions
  LiturgyServiceException _handleApiError(DioException error) {
    final apiError = error.error;
    if (apiError is ApiError) {
      switch (apiError.type) {
        case ApiErrorType.network:
          return LiturgyServiceException(
            'Network error: Please check your internet connection.',
            type: LiturgyServiceErrorType.network,
          );
        case ApiErrorType.authentication:
          return LiturgyServiceException(
            'Authentication error: Please login again.',
            type: LiturgyServiceErrorType.authentication,
          );
        case ApiErrorType.server:
          return LiturgyServiceException(
            'Server error: Please try again later.',
            type: LiturgyServiceErrorType.server,
          );
        default:
          return LiturgyServiceException(
            apiError.message,
            type: LiturgyServiceErrorType.unknown,
          );
      }
    }
    
    return LiturgyServiceException(
      'Failed to communicate with server.',
      type: LiturgyServiceErrorType.unknown,
    );
  }
}

/// Exception types for liturgy service errors
enum LiturgyServiceErrorType {
  network,
  authentication,
  server,
  validation,
  unknown,
}

/// Custom exception class for liturgy service errors
class LiturgyServiceException implements Exception {
  final String message;
  final LiturgyServiceErrorType type;

  const LiturgyServiceException(
    this.message, {
    this.type = LiturgyServiceErrorType.unknown,
  });

  @override
  String toString() => 'LiturgyServiceException: $message';

  /// Check if error is network-related
  bool get isNetworkError => type == LiturgyServiceErrorType.network;

  /// Check if error is authentication-related
  bool get isAuthError => type == LiturgyServiceErrorType.authentication;

  /// Check if error is server-related
  bool get isServerError => type == LiturgyServiceErrorType.server;
}