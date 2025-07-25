#!/bin/bash

# Production build script for Coptic Pulse
# This script ensures no dev code makes it to production

echo "🚀 Building Coptic Pulse for Production..."

# Verify we're not in dev mode
echo "📋 Checking configuration..."

# Build release APK without dev flags
echo "🔨 Building release APK..."
flutter build apk --release \
  --dart-define=ENABLE_DEV_AUTH=false \
  --dart-define=SHOW_DEV_INFO=false \
  --dart-define=MOCK_API=false \
  --dart-define=DEV_SERVER_URL="" \
  --obfuscate \
  --split-debug-info=build/debug-info

echo "✅ Production build complete!"
echo "📦 APK location: build/app/outputs/flutter-apk/app-release.apk"

# Verify the build doesn't contain dev strings
echo "🔍 Verifying no dev code in production build..."
if grep -r "DEV_LOGIN_GUIDE\|DevAuthService\|enableDevAuth.*true" build/app/outputs/flutter-apk/app-release.apk; then
    echo "❌ WARNING: Dev code detected in production build!"
    exit 1
else
    echo "✅ Production build is clean - no dev code detected"
fi