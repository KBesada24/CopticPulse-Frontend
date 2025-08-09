import 'dart:io';
import 'package:dio/dio.dart';
import '../config/environment.dart';
import 'api_service.dart';

/// Service for testing and managing backend connections
class ConnectionService {
  final ApiService _apiService;
  
  ConnectionService({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  /// Test connection to the backend server
  Future<ConnectionResult> testConnection() async {
    try {
      // Test basic internet connectivity first
      final hasInternet = await _hasInternetConnection();
      if (!hasInternet) {
        return ConnectionResult(
          isConnected: false,
          message: 'No internet connection available',
          type: ConnectionType.noInternet,
        );
      }

      // Test backend server connectivity
      final response = await _apiService.get('/health');
      
      if (response.statusCode == 200) {
        return ConnectionResult(
          isConnected: true,
          message: 'Successfully connected to backend server',
          type: ConnectionType.connected,
          serverInfo: _extractServerInfo(response.data),
        );
      } else {
        return ConnectionResult(
          isConnected: false,
          message: 'Backend server returned status: ${response.statusCode}',
          type: ConnectionType.serverError,
        );
      }
    } on DioException catch (e) {
      return _handleConnectionError(e);
    } catch (e) {
      return ConnectionResult(
        isConnected: false,
        message: 'Unexpected error: $e',
        type: ConnectionType.unknown,
      );
    }
  }

  /// Check if device has internet connectivity
  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Handle connection errors and categorize them
  ConnectionResult _handleConnectionError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ConnectionResult(
          isConnected: false,
          message: 'Connection timeout - backend server may be unreachable',
          type: ConnectionType.timeout,
        );
      
      case DioExceptionType.connectionError:
        return ConnectionResult(
          isConnected: false,
          message: 'Cannot connect to backend server at ${EnvironmentConfig.apiBaseUrl}',
          type: ConnectionType.connectionError,
        );
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return ConnectionResult(
          isConnected: false,
          message: 'Backend server error (HTTP $statusCode)',
          type: ConnectionType.serverError,
        );
      
      default:
        return ConnectionResult(
          isConnected: false,
          message: 'Connection failed: ${error.message}',
          type: ConnectionType.unknown,
        );
    }
  }

  /// Extract server information from health check response
  ServerInfo? _extractServerInfo(dynamic data) {
    if (data is Map<String, dynamic>) {
      return ServerInfo(
        version: data['version'] as String?,
        environment: data['environment'] as String?,
        timestamp: data['timestamp'] != null 
            ? DateTime.tryParse(data['timestamp'] as String)
            : null,
        database: data['database'] as String?,
      );
    }
    return null;
  }

  /// Get current backend configuration
  BackendConnectionInfo getBackendInfo() {
    return BackendConnectionInfo(
      baseUrl: EnvironmentConfig.apiBaseUrl,
      environment: EnvironmentConfig.currentEnvironment.name,
      timeout: EnvironmentConfig.requestTimeout,
      isDebugMode: EnvironmentConfig.isDebugMode,
    );
  }

  /// Test specific endpoint
  Future<bool> testEndpoint(String endpoint) async {
    try {
      final response = await _apiService.get(endpoint);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get network latency to backend
  Future<Duration?> getNetworkLatency() async {
    try {
      final stopwatch = Stopwatch()..start();
      await _apiService.get('/health');
      stopwatch.stop();
      return stopwatch.elapsed;
    } catch (e) {
      return null;
    }
  }
}

/// Result of connection test
class ConnectionResult {
  final bool isConnected;
  final String message;
  final ConnectionType type;
  final ServerInfo? serverInfo;

  const ConnectionResult({
    required this.isConnected,
    required this.message,
    required this.type,
    this.serverInfo,
  });

  @override
  String toString() {
    return 'ConnectionResult(isConnected: $isConnected, message: $message, type: $type)';
  }
}

/// Types of connection results
enum ConnectionType {
  connected,
  noInternet,
  connectionError,
  timeout,
  serverError,
  unknown,
}

/// Server information from health check
class ServerInfo {
  final String? version;
  final String? environment;
  final DateTime? timestamp;
  final String? database;

  const ServerInfo({
    this.version,
    this.environment,
    this.timestamp,
    this.database,
  });

  @override
  String toString() {
    return 'ServerInfo(version: $version, environment: $environment, database: $database)';
  }
}

/// Backend connection information
class BackendConnectionInfo {
  final String baseUrl;
  final String environment;
  final Duration timeout;
  final bool isDebugMode;

  const BackendConnectionInfo({
    required this.baseUrl,
    required this.environment,
    required this.timeout,
    required this.isDebugMode,
  });

  @override
  String toString() {
    return 'BackendConnectionInfo(baseUrl: $baseUrl, environment: $environment, timeout: $timeout)';
  }
}