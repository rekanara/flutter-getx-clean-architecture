import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'environments.dart';

// ─── Path Segments ──────────────────────────────────────────

/// Konstanta path segment, menghindari typo pada string path.
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

/// AppCast URLs (tidak tergantung environment).
class AppCastUrl {
  static String get android => dotenv.env['URL_APPCAST_ANDROID']!;
  static String get ios => dotenv.env['URL_APPCAST_IOS']!;
}

// ─── Domain Builder ─────────────────────────────────────────

/// Membangun base URL dari [EnvironmentConfig] + path segments.
///
/// Akses langsung via typed property, tidak ada string key.
/// Contoh: `Domain.sso` → `https://sso.dev.example.com/api/v1`
class Domain {
  static EnvironmentConfig get _cfg => ConfigEnvironments.config;

  // ── Backend Services (API v1) ──
  static String get sso => '${_cfg.sso}${PathSegment.api}${PathSegment.v1}';
  static String get billing =>
      '${_cfg.billing}${PathSegment.api}${PathSegment.v1}';
  static String get odp => '${_cfg.odp}${PathSegment.api}${PathSegment.v1}';
  static String get homepass =>
      '${_cfg.homepass}${PathSegment.api}${PathSegment.v1}';
  static String get transaction =>
      '${_cfg.transaction}${PathSegment.api}${PathSegment.v1}';
  static String get nextune =>
      '${_cfg.nextune}${PathSegment.api}${PathSegment.v1}';
  static String get nexadmin =>
      '${_cfg.nexadmin}${PathSegment.api}${PathSegment.v1}';
  static String get nexads =>
      '${_cfg.nexads}${PathSegment.api}${PathSegment.v1}';
  static String get nexpayment =>
      '${_cfg.nexpayment}${PathSegment.api}${PathSegment.v1}';
  static String get nexreward =>
      '${_cfg.nexreward}${PathSegment.api}${PathSegment.v1}';

  // ── CDN ──
  static String get cdnNexBillPackages =>
      '${_cfg.cdn}${PathSegment.nexbill}/packages';
  static String get cdnNexAds => '${_cfg.cdn}${PathSegment.nexads}';

  // ── FZ ──
  static String get fzAdmin =>
      '${_cfg.fzAdmin}${PathSegment.api}${PathSegment.v2}';
  static String get fzContent =>
      '${_cfg.fzContent}${PathSegment.v1}${PathSegment.public}${PathSegment.api}';
  static String get fzCdn => _cfg.fzCdn;

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

/// Semua endpoint API yang digunakan di seluruh aplikasi.
///
/// Tambahkan endpoint baru di sini untuk menghindari
/// string endpoint tersebar di banyak file.
///
/// ```dart
/// final url = Endpoint.sso.login; // "https://sso.../auth/login"
/// ```
class Endpoint {
  Endpoint._();

  // ── SSO ──
  static final sso = _SsoEndpoints();

  // ── Nexadmin ──
  static final nexadmin = _NexadminEndpoints();

  // ── Billing ──
  static final billing = _BillingEndpoints();
}

class _SsoEndpoints {
  String get login => '${Domain.sso}/auth/login';
  String get refresh => '${Domain.sso}/auth/refresh';
}

class _NexadminEndpoints {
  String get banners => '${Domain.nexadmin}/banners/active';
}

class _BillingEndpoints {
  String get customerDetail => '${Domain.billing}/customer-details/me';
}
