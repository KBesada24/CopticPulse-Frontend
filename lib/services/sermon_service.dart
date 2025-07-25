import 'package:dio/dio.dart';
import '../models/sermon.dart';
import '../utils/constants.dart';
import 'api_service.dart';

/// Service for managing sermon data and API communication
class SermonService {
  static final SermonService _instance = SermonService._internal();
  factory SermonService() => _instance;
  SermonService._internal();

  final ApiService _apiService = ApiService();

  /// Fetch all sermons with optional pagination and filtering
  Future<List<Sermon>> getSermons({
    int page = 1,
    int limit = AppConstants.defaultPageSize,
    String? search,
    List<String>? tags,
    String? speaker,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      if (tags != null && tags.isNotEmpty) {
        queryParameters['tags'] = tags.join(',');
      }

      if (speaker != null && speaker.isNotEmpty) {
        queryParameters['speaker'] = speaker;
      }

      final response = await _apiService.get(
        AppConstants.sermonsEndpoint,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final sermonsData = data['sermons'] as List<dynamic>;
        
        return sermonsData
            .map((sermonJson) => Sermon.fromJson(sermonJson as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch sermons: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error while fetching sermons: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while fetching sermons: $e');
    }
  }

  /// Fetch a single sermon by ID
  Future<Sermon> getSermonById(String id) async {
    try {
      final response = await _apiService.get('${AppConstants.sermonsEndpoint}/$id');

      if (response.statusCode == 200) {
        return Sermon.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch sermon: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error while fetching sermon: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while fetching sermon: $e');
    }
  }

  /// Get available sermon tags for filtering
  Future<List<String>> getSermonTags() async {
    try {
      final response = await _apiService.get('${AppConstants.sermonsEndpoint}/tags');

      if (response.statusCode == 200) {
        final data = response.data;
        return (data['tags'] as List<dynamic>)
            .map((tag) => tag as String)
            .toList();
      } else {
        throw Exception('Failed to fetch sermon tags: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error while fetching sermon tags: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while fetching sermon tags: $e');
    }
  }

  /// Get available speakers for filtering
  Future<List<String>> getSpeakers() async {
    try {
      final response = await _apiService.get('${AppConstants.sermonsEndpoint}/speakers');

      if (response.statusCode == 200) {
        final data = response.data;
        return (data['speakers'] as List<dynamic>)
            .map((speaker) => speaker as String)
            .toList();
      } else {
        throw Exception('Failed to fetch speakers: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error while fetching speakers: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while fetching speakers: $e');
    }
  }

  /// Search sermons by query
  Future<List<Sermon>> searchSermons(String query, {
    int page = 1,
    int limit = AppConstants.defaultPageSize,
  }) async {
    return getSermons(
      page: page,
      limit: limit,
      search: query,
    );
  }

  /// Filter sermons by tags
  Future<List<Sermon>> filterSermonsByTags(List<String> tags, {
    int page = 1,
    int limit = AppConstants.defaultPageSize,
  }) async {
    return getSermons(
      page: page,
      limit: limit,
      tags: tags,
    );
  }

  /// Filter sermons by speaker
  Future<List<Sermon>> filterSermonsBySpeaker(String speaker, {
    int page = 1,
    int limit = AppConstants.defaultPageSize,
  }) async {
    return getSermons(
      page: page,
      limit: limit,
      speaker: speaker,
    );
  }

  /// Get recent sermons (published within last 30 days)
  Future<List<Sermon>> getRecentSermons({
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.sermonsEndpoint}/recent',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final sermonsData = data['sermons'] as List<dynamic>;
        
        return sermonsData
            .map((sermonJson) => Sermon.fromJson(sermonJson as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch recent sermons: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error while fetching recent sermons: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while fetching recent sermons: $e');
    }
  }
}