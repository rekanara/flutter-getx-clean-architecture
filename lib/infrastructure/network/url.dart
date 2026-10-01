import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'environments.dart';

// ─── Path Segments ──────────────────────────────────────────

/// Path segment constants, avoids typos in string paths.
class PathSegment {
  static const String banner = '/assets/banner/';
  static const String v1 = '/v1';
  static const String v2 = '/v2';
  static const String api = '/api';
  static const String nexbill = '/nexbill';
  static const String nexads = '/nexads';
  static const String public = '/public';
}

// ─── App Cast URLs ──────────────────────────────────────────

/// AppCast URLs (independent of environment).
class AppCastUrl {
  static String get android => dotenv.env['URL_APPCAST_ANDROID']!;
  static String get ios => dotenv.env['URL_APPCAST_IOS']!;
}

// ─── Domain Builder ─────────────────────────────────────────

/// Builds base URL from [EnvironmentConfig] + path segments.
///
/// Direct access via typed properties, no string keys.
/// Example: `Domain.sso` → `https://sso.dev.example.com/api/v1`
class Domain {
  static EnvironmentConfig get _cfg => ConfigEnvironments.config;

  // ── Backend Services (API v1) ──
  static String get be => '${_cfg.be}${PathSegment.api}${PathSegment.v1}';
  // ── CDN ──
  static String get cdnNexBillPackages =>
      '${_cfg.cdn}${PathSegment.nexbill}/packages';
  static String get cdnNexAds => '${_cfg.cdn}${PathSegment.nexads}';

  // ── Firebase ──
  static String get firebaseAndroidApiKey => _cfg.firebaseAndroidApiKey;
  static String get firebaseAndroidAppId => _cfg.firebaseAndroidAppId;
  static String get firebaseMessagingSenderId => _cfg.firebaseMessagingSenderId;
  static String get firebaseProjectId => _cfg.firebaseProjectId;
  static String get firebaseStorageBucket => _cfg.firebaseStorageBucket;
  static String get firebaseIosApiKey => _cfg.firebaseIosApiKey;
  static String get firebaseIosAppId => _cfg.firebaseIosAppId;
  static String get firebaseBundleId => _cfg.firebaseBundleId;
}

// ─── URL Endpoints ──────────────────────────────────────────

/// All API endpoints used throughout the application.
///
/// Add new endpoints here to avoid
/// string endpoints scattered across many files.
///
/// ```dart
/// final url = Endpoint.be.login; // "https://api.../v1/auth/login"
/// ```
class Endpoint {
  Endpoint._();

  // ── BE ──
  static final be = _BeEndpoints();
}

class _BeEndpoints {
  String get login => '${Domain.be}/auth/login';
  String get refresh => '${Domain.be}/auth/refresh';
  String get banners => '${Domain.be}/banners/active';
  String get customerDetail => '${Domain.be}/customer-details/me';
}
