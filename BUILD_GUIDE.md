# Coptic Pulse Build Guide

This guide explains how to build Coptic Pulse for different environments while ensuring dev code doesn't leak into production.

## 🚀 Production Builds

### Automated Production Build (Recommended)
```bash
# Windows
scripts\build_production.bat

# Linux/Mac
chmod +x scripts/build_production.sh
./scripts/build_production.sh
```

### Manual Production Build
```bash
flutter build apk --release \
  --dart-define=ENABLE_DEV_AUTH=false \
  --dart-define=SHOW_DEV_INFO=false \
  --dart-define=MOCK_API=false \
  --obfuscate \
  --split-debug-info=build/debug-info
```

## 🛠️ Development Builds

### Automated Development Build
```bash
# Windows
scripts\build_dev.bat
```

### Manual Development Build
```bash
flutter build apk --debug \
  --dart-define=ENABLE_DEV_AUTH=true \
  --dart-define=SHOW_DEV_INFO=true \
  --dart-define=MOCK_API=true
```

## 🔒 Security Features

### Build Mode Protection
- Dev features are automatically disabled in release builds using `kDebugMode`
- Environment variables control dev feature activation
- Production builds use code obfuscation

### Environment Variables
- `ENABLE_DEV_AUTH`: Enable dev authentication (default: false)
- `SHOW_DEV_INFO`: Show dev info in UI (default: false)
- `MOCK_API`: Use mock API responses (default: false)
- `DEV_SERVER_URL`: Development server URL (default: localhost:3000)

### Verification
Production builds automatically verify that no dev code is included.

## 📋 Pre-Release Checklist

Before releasing to production:

- [ ] Use production build script
- [ ] Verify `DevConfig.enableDevAuth` is false in release
- [ ] Test with real API endpoints
- [ ] Remove any hardcoded dev credentials
- [ ] Verify no debug prints in release build
- [ ] Test authentication flow with real backend

## 🚨 Common Mistakes to Avoid

1. **Never hardcode `enableDevAuth = true`** - Always use environment variables
2. **Don't commit dev credentials** - Use environment variables or gitignored files
3. **Always use build scripts** - Manual builds are error-prone
4. **Test production builds** - Don't assume they work the same as debug builds

## 🔍 Troubleshooting

### Dev Features Not Working in Debug
- Ensure you're using the dev build script
- Check that environment variables are set correctly
- Verify `kDebugMode` is true

### Dev Features Appearing in Release
- This should be impossible with the current setup
- If it happens, check for hardcoded values in DevConfig
- Verify you're using the production build script

## 📱 App Store Builds

For app store releases, use additional flags:

```bash
# Android Play Store
flutter build appbundle --release \
  --dart-define=ENABLE_DEV_AUTH=false \
  --obfuscate \
  --split-debug-info=build/debug-info

# iOS App Store  
flutter build ios --release \
  --dart-define=ENABLE_DEV_AUTH=false \
  --obfuscate \
  --split-debug-info=build/debug-info
```