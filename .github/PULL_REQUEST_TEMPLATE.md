## Description

<!-- Describe your changes in detail -->
<!-- Reference any related issues, e.g., "Fixes #123" -->

## Type of Change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## CI Check Checklist

<!-- Before opening this PR, ensure you have run these commands locally and they pass. -->
<!-- These are the exact gates checked by GitHub Actions. -->

- [ ] `dart format --output=none --set-exit-if-changed .` passes (no format diff)
- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] Secret Guard: No `.env`, `google-services.json`, `GoogleService-Info.plist`, or `key.properties` are tracked in git

## Additional Notes

<!-- Any specific notes, things you want reviewers to look at, or potential edge cases -->