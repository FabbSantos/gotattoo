import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../core/config/ad_config.dart';

/// A single, unobtrusive AdMob banner. Renders nothing until an ad loads (and
/// nothing at all if loading fails), so it never breaks the layout.
class FeedBannerAd extends StatefulWidget {
  /// Use [AdSize.mediumRectangle] for a card-like ad inside a feed.
  final AdSize size;

  const FeedBannerAd({super.key, this.size = AdSize.banner});

  @override
  State<FeedBannerAd> createState() => _FeedBannerAdState();
}

class _FeedBannerAdState extends State<FeedBannerAd> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    try {
      final ad = BannerAd(
        adUnitId: AdConfig.bannerUnitId,
        size: widget.size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            if (mounted) setState(() => _loaded = true);
          },
          onAdFailedToLoad: (ad, _) => ad.dispose(),
        ),
      );
      ad.load();
      _ad = ad;
    } catch (_) {
      // Ads unavailable (e.g. unsupported platform) — stay invisible.
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
    return SafeArea(
      top: false,
      child: SizedBox(
        height: _ad!.size.height.toDouble(),
        width: double.infinity,
        child: AdWidget(ad: _ad!),
      ),
    );
  }
}
