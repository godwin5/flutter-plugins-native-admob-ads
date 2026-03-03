import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'flutter_native_admob_ads_platform_interface.dart';
import 'native_ad_models.dart';

/// Main entry point for the Flutter Native AdMob Ads plugin.
///
/// Use this class to load, trigger, and dispose of native ads.
class FlutterNativeAdmobAds {
  /// Default constructor for [FlutterNativeAdmobAds].
  FlutterNativeAdmobAds();

  /// Loads one or more Native Ads from AdMob.
  ///
  /// [adId] is your AdMob Native Ad unit ID.
  /// [isTesting] if true, uses the Google test ad unit ID.
  /// [adsCount] the number of ads to request (max 5).
  Future<List<FlutterNativeAd>> loadNativeAd({
    required String adId,
    bool isTesting = false,
    int adsCount = 1,
  }) {
    return FlutterNativeAdmobAdsPlatform.instance.loadNativeAd(
      adId: adId,
      isTesting: isTesting,
      adsCount: adsCount,
    );
  }

  /// Disposes of the Ad with the given [id] and removes it from memory.
  ///
  /// Call this when you no longer need to display the ad to free up resources.
  Future<void> disposeNativeAd(String id) {
    return FlutterNativeAdmobAdsPlatform.instance.disposeNativeAd(id);
  }
}

/// A widget that handles the native click tracking for a [FlutterNativeAd].
///
/// Wrap your custom Flutter ad UI with this widget to ensure that clicks
/// are correctly registered by the AdMob SDK.
class FlutterNativeAdView extends StatelessWidget {
  /// The loaded native ad model.
  final FlutterNativeAd ad;

  /// Your custom Flutter UI for the ad.
  ///
  /// Widgets within [child] will trigger the ad redirect when tapped.
  final Widget child;

  /// An optional overlay widget that stays on top of the ad click area.
  ///
  /// Use this for elements that should NOT trigger the ad redirect,
  /// such as a custom AdChoices icon or a close button.
  final Widget? overlay;

  /// Creates a [FlutterNativeAdView].
  const FlutterNativeAdView({super.key, required this.ad, required this.child, this.overlay});

  @override
  Widget build(BuildContext context) {
    const String viewType = 'flutter_native_ad_view';
    final Map<String, dynamic> creationParams = <String, dynamic>{'id': ad.id};

    return Stack(
      children: [
        // Layer 1: Flutter UI (Covered by click overlay)
        child,

        // Layer 2: Native Click Overlay
        Positioned.fill(
          child: _PlatformView(viewType: viewType, creationParams: creationParams),
        ),

        // Layer 3: Interactive elements (Not blocked)
        ?overlay,
      ],
    );
  }
}

class _PlatformView extends StatelessWidget {
  final String viewType;
  final Map<String, dynamic> creationParams;

  const _PlatformView({required this.viewType, required this.creationParams});

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return const SizedBox.shrink();
  }
}
