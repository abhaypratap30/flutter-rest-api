# Changelog

All notable changes to `flutter-rest-api` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-08-05

### Added
- Initial production-ready release of `flutter-rest-api`.
- Clean Architecture layered structure (`core/` & `features/`).
- Generic `ApiClient` supporting GET, POST, PUT, PATCH, DELETE, Multipart Upload, and File Download.
- Complete Interceptor Stack: Logging, Authorization, Token Refresh with Request Queueing, Retry with Exponential Backoff, and Domain Error Interceptors.
- JWT Authentication flow with login, token storage, auto-refresh, and logout.
- In-memory response cache manager with TTL expiration strategy.
- Pagination demo supporting Page-Number and Cursor-Based pagination strategies.
- Full Material 3 UI design system with Light/Dark mode toggling and Shimmer loading skeletons.
- Comprehensive Unit Tests suite for API Exceptions and Repositories.
