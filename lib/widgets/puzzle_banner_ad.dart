import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class PuzzleBannerAd extends StatefulWidget {
  const PuzzleBannerAd({super.key});

  @override
  State<PuzzleBannerAd> createState() => _PuzzleBannerAdState();
}

class _PuzzleBannerAdState extends State<PuzzleBannerAd> {
  BannerAd? _banner;
  bool _loaded = false;

  // Google test banner ID for development.
  // Replace this single value with your LIVE banner ad unit ID before release.
  static const String bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    final banner = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _banner = ad as BannerAd;
            _loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) setState(() => _loaded = false);
        },
      ),
    );
    banner.load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _banner == null) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: SizedBox(
        width: _banner!.size.width.toDouble(),
        height: _banner!.size.height.toDouble(),
        child: AdWidget(ad: _banner!),
      ),
    );
  }
}
