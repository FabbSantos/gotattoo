/// AdMob configuration.
///
/// Defaults to Google's official **test** ad unit ids, so ads work in dev
/// without an AdMob account and never risk policy strikes. Pass the real ids at
/// build time with --dart-define for production:
///   --dart-define=ADMOB_BANNER_ID=ca-app-pub-XXXX/YYYY
/// (and replace the APPLICATION_ID test value in AndroidManifest.xml).
abstract class AdConfig {
  /// Google's test banner unit — always safe to show.
  static const String _testBanner = 'ca-app-pub-3940256099942544/6300978111';

  /// Google's test native-advanced unit — always safe to show.
  static const String _testNative = 'ca-app-pub-3940256099942544/2247696110';

  static const String bannerUnitId =
      String.fromEnvironment('ADMOB_BANNER_ID', defaultValue: _testBanner);

  static const String nativeUnitId =
      String.fromEnvironment('ADMOB_NATIVE_ID', defaultValue: _testNative);

  /// Factory id registered natively (see MainActivity / NativeAdFactoryImpl).
  static const String nativeFactoryId = 'tattooCard';

  /// True when running with the real (non-test) banner id.
  static bool get isProduction => bannerUnitId != _testBanner;
}
