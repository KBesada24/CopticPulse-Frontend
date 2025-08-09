/// Environment configuration for different deployment environments
enum Environment { development, staging, production }

/// Configuration class for managing environment-specific settings
class EnvironmentConfig {
  static const Environment _currentEnvironment = Environment.development;

  /// Get current environment
  static Environment get currentEnvironment => _currentEnvironment;

  /// Get API base URL based on current environment
  static String get apiBaseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'http://localhost:3000/api/v1'; // Your local backend
      case Environment.staging:
        return 'https://staging-api.copticpulse.com/api/v1'; // Staging server
      case Environment.production:
        return 'https://api.copticpulse.com/api/v1'; // Production server
    }
  }

  /// Get WebSocket URL based on current environment
  static String get websocketUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'ws://localhost:3000/ws';
      case Environment.staging:
        return 'wss://staging-api.copticpulse.com/ws';
      case Environment.production:
        return 'wss://api.copticpulse.com/ws';
    }
  }

  /// Get whether debug mode is enabled
  static bool get isDebugMode {
    return _currentEnvironment == Environment.development;
  }

  /// Get request timeout based on environment
  static Duration get requestTimeout {
    switch (_currentEnvironment) {
      case Environment.development:
        return const Duration(seconds: 60); // Longer timeout for development
      case Environment.staging:
      case Environment.production:
        return const Duration(seconds: 30);
    }
  }

  /// Get whether to enable API logging
  static bool get enableApiLogging {
    return _currentEnvironment == Environment.development;
  }

  /// Get cache expiration duration
  static Duration get cacheExpiration {
    switch (_currentEnvironment) {
      case Environment.development:
        return const Duration(minutes: 5); // Shorter cache for development
      case Environment.staging:
        return const Duration(minutes: 30);
      case Environment.production:
        return const Duration(hours: 1);
    }
  }

  /// Get sync interval for offline functionality
  static Duration get syncInterval {
    switch (_currentEnvironment) {
      case Environment.development:
        return const Duration(minutes: 2); // More frequent sync for testing
      case Environment.staging:
        return const Duration(minutes: 10);
      case Environment.production:
        return const Duration(minutes: 15);
    }
  }

  /// Get database name with environment suffix
  static String get databaseName {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'coptic_pulse_dev.db';
      case Environment.staging:
        return 'coptic_pulse_staging.db';
      case Environment.production:
        return 'coptic_pulse.db';
    }
  }

  /// Configuration for different backend types
  static BackendConfig get backendConfig {
    return BackendConfig(
      baseUrl: apiBaseUrl,
      timeout: requestTimeout,
      enableLogging: enableApiLogging,
      retryAttempts: _currentEnvironment == Environment.development ? 1 : 3,
    );
  }
}

/// Backend configuration class
class BackendConfig {
  final String baseUrl;
  final Duration timeout;
  final bool enableLogging;
  final int retryAttempts;

  const BackendConfig({
    required this.baseUrl,
    required this.timeout,
    required this.enableLogging,
    required this.retryAttempts,
  });

  @override
  String toString() {
    return 'BackendConfig(baseUrl: $baseUrl, timeout: $timeout, enableLogging: $enableLogging)';
  }
}

/// Network configuration for different connection types
class NetworkConfig {
  /// Check if running on mobile network
  static bool get isMobileNetwork {
    // This would typically check the actual network type
    // For now, return false (assuming WiFi)
    return false;
  }

  /// Get appropriate timeout based on network type
  static Duration get networkTimeout {
    return isMobileNetwork
        ? const Duration(seconds: 45) // Longer timeout for mobile
        : const Duration(seconds: 30); // Standard timeout for WiFi
  }

  /// Get appropriate retry count based on network type
  static int get retryCount {
    return isMobileNetwork ? 2 : 3;
  }
}
