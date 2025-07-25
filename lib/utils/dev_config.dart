import 'package:flutter/foundation.dart';

/// Development configuration for the Coptic Pulse app
class DevConfig {
  /// Enable developer authentication mode (bypasses real API)
  /// Only enabled in debug mode, never in release builds
  static const bool enableDevAuth = kDebugMode && bool.fromEnvironment('ENABLE_DEV_AUTH', defaultValue: false);
  
  /// Enable debug logging - only in debug mode
  static const bool enableDebugLogging = kDebugMode;
  
  /// Show developer info in UI - only in debug mode
  static const bool showDevInfo = kDebugMode && bool.fromEnvironment('SHOW_DEV_INFO', defaultValue: false);
  
  /// Mock API responses instead of making real network calls - only in debug mode
  static const bool mockApiResponses = kDebugMode && bool.fromEnvironment('MOCK_API', defaultValue: false);
  
  /// Development server URL (if not using mock mode)
  static const String devServerUrl = String.fromEnvironment('DEV_SERVER_URL', defaultValue: 'http://localhost:3000');
  
  /// Print configuration info - only in debug mode
  static void printConfig() {
    if (!kDebugMode || !enableDevAuth) return;
    
    // Use debugPrint instead of print for better Flutter integration
    debugPrint('\n=== COPTIC PULSE DEV CONFIG ===');
    debugPrint('Dev Auth Enabled: $enableDevAuth');
    debugPrint('Debug Logging: $enableDebugLogging');
    debugPrint('Show Dev Info: $showDevInfo');
    debugPrint('Mock API: $mockApiResponses');
    debugPrint('Dev Server: $devServerUrl');
    debugPrint('Build Mode: ${kDebugMode ? "DEBUG" : "RELEASE"}');
    debugPrint('===============================\n');
  }
  
  /// Check if we're running in production mode
  static bool get isProduction => kReleaseMode;
  
  /// Check if we're running in development mode
  static bool get isDevelopment => kDebugMode;
}