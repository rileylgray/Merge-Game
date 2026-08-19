import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../services/ads_service.dart';

/// Anchored adaptive banner pinned above the navigation bar.
///
/// Occupies zero height until an ad actually loads, so a failed fill or a
/// consent refusal never leaves a grey rectangle in the layout.
class BannerAdSlot extends StatefulWidget {
  const BannerAdSlot({super.key});

  @override
  State<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends State<BannerAdSlot> {
  BannerAd? _ad;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) return;
    _requested = true;
    _load();
  }

  Future<void> _load() async {
    final AdsService ads = context.read<AdsService>();
    final int width = MediaQuery.sizeOf(context).width.truncate();
    final BannerAd? ad = await ads.createBanner(width);
    if (!mounted) {
      ad?.dispose();
      return;
    }
    setState(() => _ad = ad);
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BannerAd? ad = _ad;
    if (ad == null) return const SizedBox.shrink();
    return Container(
      alignment: Alignment.center,
      color: Colors.white,
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
