import 'package:flutter/foundation.dart' show kReleaseMode;

/// AdMob configuration.
///
/// Uses the REAL ad units in release builds and Google's official **test**
/// units in debug/profile — so development never risks policy strikes, and
/// production ships real ads automatically (no build flags to remember).
/// A `--dart-define=ADMOB_BANNER_ID=...` / `ADMOB_NATIVE_ID=...` still overrides
/// either, if ever needed.
abstract class AdConfig {
  // Google's official test units — always safe to show.
  static const String _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testNative = 'ca-app-pub-3940256099942544/2247696110';

  // Real GoTattoo units (AdMob app ca-app-pub-3671028401334746).
  static const String _realBanner = 'ca-app-pub-3671028401334746/7865664687';
  static const String _realNative = 'ca-app-pub-3671028401334746/8201119295';

  static const String _envBanner =
      String.fromEnvironment('ADMOB_BANNER_ID');
  static const String _envNative =
      String.fromEnvironment('ADMOB_NATIVE_ID');

  /// Banner unit (shown in the feed/mural).
  static String get bannerUnitId => _envBanner.isNotEmpty
      ? _envBanner
      : (kReleaseMode ? _realBanner : _testBanner);

  /// Native-advanced unit (shown in the home grid).
  static String get nativeUnitId => _envNative.isNotEmpty
      ? _envNative
      : (kReleaseMode ? _realNative : _testNative);

  /// Factory id registered natively (see MainActivity / NativeAdFactoryImpl).
  static const String nativeFactoryId = 'tattooCard';

  /// True when showing real (non-test) ads.
  static bool get isProduction => bannerUnitId != _testBanner;
}
