import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../core/config/ad_config.dart';

/// A native ad rendered (via the native `tattooCard` factory) to look like a
/// tattoo product card, so it can sit as a single cell inside the home grid.
/// Renders an empty slot until the ad loads; never crashes the grid.
class NativeAdCard extends StatefulWidget {
  const NativeAdCard({super.key});

  @override
  State<NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends State<NativeAdCard> {
  NativeAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    try {
      final ad = NativeAd(
        adUnitId: AdConfig.nativeUnitId,
        factoryId: AdConfig.nativeFactoryId,
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (_) {
            if (mounted) setState(() => _loaded = true);
          },
          onAdFailedToLoad: (ad, error) => ad.dispose(),
        ),
      );
      ad.load();
      _ad = ad;
    } catch (_) {
      // Ads are best-effort; never block the grid.
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _ad == null) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AdWidget(ad: _ad!),
    );
  }
}
