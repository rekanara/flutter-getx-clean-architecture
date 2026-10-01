# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- CI Actions workflow (`.github/workflows/ci.yml`) for `format`, `analyze`, and `test`.
- `.editorconfig` for consistent indentation across editors.
- Project status badges in `README.md`.
- `CHANGELOG.md` file.

### Changed
- Translated entire codebase to English for open-source.
- Raised macOS deployment target to 12.0.
- Cleaned up unused dependencies.

## [1.0.0] - 2026-01-01

### Added
- Initial Clean Architecture boilerplate release.
- **Presentation**: `BaseController`, `BaseBuilderController`, `BasePaginationController`.
- **Domain**: `UseCase` structure, Dartz `Either<Failure, T>`.
- **Infrastructure**: Dio client (Auth/NoAuth), GetStorage, FlutterSecureStorage.
- **Routing**: GetX Navigation bindings.
- **State**: Reactive (`.obs`), Builder (`update`), Pagination.
- **Environment**: Runtime environment switching (`dev`, `staging`, `prod`) via `.env`.
- **Components**: `CustomButton`, `CustomText`, `CustomCachedImage`, `PaginationListView`.
- **Global**: `GlobalErrorHandler`, `DioWrapper` (Talker), `ApiResponse`.
- **Helpers**: Logger, Dialog, Snackbar, JsonParser, Responsive.
- Basic Auth flow (login, refresh token).