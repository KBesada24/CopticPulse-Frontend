# 🔒 Dev/Production Code Separation Guide

This document explains how Coptic Pulse prevents dev code from appearing in production builds.

## 🛡️ Protection Mechanisms

### 1. Build Mode Detection
```dart
// DevConfig automatically detects build mode
static const bool enableDevAuth = kDebugMode && bool.fromEnvironment('ENABLE_DEV_AUTH', defaultValue: false);
```

- **Debug builds**: Dev features can be enabled via environment variables
- **Release builds**: Dev features are automatically disabled regardless of environment variables

### 2. Runtime Safety Checks
```dart
// DevAuthService prevents instantiation in release builds
factory DevAuthService() {
  if (kReleaseMode) {
    throw StateError('DevAuthService cannot be used in release builds!');
  }
  return _instance;
}
```

### 3. Environment Variable Control
Dev features are controlled by build-time environment variables:
- `ENABLE_DEV_AUTH=false` (default)
- `SHOW_DEV_INFO=false` (default)  
- `MOCK_API=false` (default)

### 4. Safe Logging
```dart
// Uses debugPrint instead of print
static void printTestCredentials() {
  if (kReleaseMode || !DevConfig.isDevelopment) {
    return; // Never prints in release
  }
  debugPrint('Dev credentials...');
}
```

## 🚀 Production Build Process

### Automated (Recommended)
```bash
# Windows
scripts\build_production.bat

# Linux/Mac  
./scripts/build_production.sh
```

### Manual
```bash
flutter build apk --release \
  --dart-define=ENABLE_DEV_AUTH=false \
  --dart-define=SHOW_DEV_INFO=false \
  --dart-define=MOCK_API=false \
  --obfuscate \
  --split-debug-info=build/debug-info
```

## 🧪 Development Build Process

```bash
# Windows
scripts\build_dev.bat

# Manual
flutter build apk --debug \
  --dart-define=ENABLE_DEV_AUTH=true \
  --dart-define=SHOW_DEV_INFO=true \
  --dart-define=MOCK_API=true
```

## ✅ Verification Methods

### 1. Automated CI/CD
- GitHub Actions verify production builds
- Checks for hardcoded dev values
- Ensures builds complete successfully

### 2. Code Analysis
```bash
flutter analyze  # Must pass with no errors
```

### 3. Runtime Testing
- Install production APK on clean device
- Verify dev features are inaccessible
- Test with real backend only

## 🚨 What Happens If Dev Code Leaks?

### Current Protections Prevent:
1. **DevAuthService in production**: Throws runtime error
2. **Dev credentials printing**: Silent no-op in release
3. **Mock API usage**: Disabled by default
4. **Debug UI elements**: Hidden in release builds

### If Something Gets Through:
1. Follow emergency rollback plan in `PRODUCTION_CHECKLIST.md`
2. Investigate how protection was bypassed
3. Add additional safeguards
4. Re-deploy fixed version

## 📋 Developer Guidelines

### ✅ DO:
- Use environment variables for dev features
- Wrap dev code in `if (kDebugMode)` checks
- Use `debugPrint()` instead of `print()`
- Test production builds regularly
- Use provided build scripts

### ❌ DON'T:
- Hardcode `enableDevAuth = true`
- Commit dev credentials to code
- Use `print()` for logging
- Skip production build testing
- Manually build for production

## 🔧 Configuration Files

### Key Files:
- `lib/utils/dev_config.dart` - Main dev configuration
- `lib/services/dev_auth_service.dart` - Dev authentication
- `scripts/build_production.*` - Production build scripts
- `PRODUCTION_CHECKLIST.md` - Pre-release checklist

### Environment Variables:
All dev features are controlled by build-time environment variables with safe defaults (false).

## 🎯 Summary

The current setup provides **multiple layers of protection**:

1. **Compile-time**: Environment variables with safe defaults
2. **Build-time**: Automated scripts with verification
3. **Runtime**: Safety checks that throw errors
4. **CI/CD**: Automated verification in GitHub Actions

**Result**: It's now virtually impossible for dev code to accidentally reach production! 🎉