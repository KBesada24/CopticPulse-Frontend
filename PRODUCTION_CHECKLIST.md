# 🚀 Production Readiness Checklist

Use this checklist before every production release to ensure no dev code leaks into production.

## ✅ Pre-Build Verification

### Code Review
- [ ] No hardcoded `enableDevAuth = true` in `DevConfig`
- [ ] No hardcoded dev credentials in any file
- [ ] All `print()` statements replaced with `debugPrint()` or removed
- [ ] No `TODO` or `FIXME` comments in critical paths
- [ ] All dev-only imports are conditionally imported

### Configuration Check
- [ ] `DevConfig.enableDevAuth` uses `kDebugMode` and environment variables
- [ ] API endpoints point to production servers
- [ ] No localhost URLs in production code
- [ ] SSL certificate pinning enabled (if applicable)

### Security Review
- [ ] No sensitive data in logs
- [ ] No debug information exposed in UI
- [ ] Authentication uses production service only
- [ ] API keys are properly secured

## 🔨 Build Process

### Use Production Build Script
- [ ] Run `scripts/build_production.bat` (Windows) or `scripts/build_production.sh` (Linux/Mac)
- [ ] Verify build completes without warnings
- [ ] Check APK/AAB size is reasonable

### Manual Verification (if not using scripts)
```bash
flutter build apk --release \
  --dart-define=ENABLE_DEV_AUTH=false \
  --dart-define=SHOW_DEV_INFO=false \
  --dart-define=MOCK_API=false \
  --obfuscate \
  --split-debug-info=build/debug-info
```

## 🧪 Testing

### Functional Testing
- [ ] App launches successfully
- [ ] Authentication works with real backend
- [ ] All main features work correctly
- [ ] No dev UI elements visible
- [ ] No dev credentials accepted

### Performance Testing
- [ ] App startup time is acceptable
- [ ] Memory usage is within limits
- [ ] Network requests are optimized
- [ ] No debug logging impacting performance

## 📱 App Store Preparation

### Android (Google Play)
- [ ] Build AAB format: `flutter build appbundle --release`
- [ ] Version code incremented
- [ ] Signing configured correctly
- [ ] Permissions are minimal and justified

### iOS (App Store)
- [ ] Build for iOS: `flutter build ios --release`
- [ ] Provisioning profiles updated
- [ ] App Store Connect metadata updated
- [ ] Privacy policy updated if needed

## 🔍 Final Verification

### Code Analysis
- [ ] `flutter analyze` passes with no errors
- [ ] All tests pass: `flutter test`
- [ ] No dev dependencies in production build

### Runtime Verification
- [ ] Install production APK on clean device
- [ ] Test without development tools
- [ ] Verify no dev features accessible
- [ ] Check app behavior with poor network

## 🚨 Emergency Rollback Plan

If dev code is discovered in production:

1. **Immediate Actions**
   - [ ] Remove app from store (if possible)
   - [ ] Disable dev endpoints on backend
   - [ ] Monitor for security issues

2. **Fix and Redeploy**
   - [ ] Identify how dev code got through
   - [ ] Fix the issue
   - [ ] Re-run full checklist
   - [ ] Deploy fixed version

## 📋 Sign-off

- [ ] **Developer**: Code reviewed and tested
- [ ] **QA**: Functional testing complete
- [ ] **Security**: Security review passed
- [ ] **Release Manager**: Production build verified

**Release Date**: ___________
**Version**: ___________
**Signed by**: ___________

---

## 🛡️ Automated Protections

The following protections are built into the codebase:

1. **Build-time checks**: DevAuthService throws errors in release builds
2. **Environment variables**: Dev features controlled by build flags
3. **CI/CD verification**: GitHub Actions verify production builds
4. **Code obfuscation**: Release builds are obfuscated
5. **Debug print protection**: debugPrint() only works in debug builds

Remember: **When in doubt, rebuild with production scripts!**