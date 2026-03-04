import 'dart:async';

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
  /// [onImpression] called when an impression is recorded.
  /// [onClicked] called when the ad is clicked.
  /// [onOpened] called when the ad opens a full-screen content.
  /// [onClosed] called when the ad is closed.
  Future<List<FlutterNativeAd>> loadNativeAd({
    required String adId,
    bool isTesting = false,
    int adsCount = 1,
    void Function(String adId)? onImpression,
    void Function(String adId)? onClicked,
    void Function(String adId)? onOpened,
    void Function(String adId)? onClosed,
  }) {
    return FlutterNativeAdmobAdsPlatform.instance.loadNativeAd(
      adId: adId,
      isTesting: isTesting,
      adsCount: adsCount,
      onImpression: onImpression,
      onClicked: onClicked,
      onOpened: onOpened,
      onClosed: onClosed,
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
          child: _PlatformView(key: ValueKey(ad.id), viewType: viewType, creationParams: creationParams),
        ),

        // Layer 3: Interactive elements (Not blocked)
        ?overlay,
      ],
    );
  }
}

class _PlatformView extends StatefulWidget {
  final String viewType;
  final Map<String, dynamic> creationParams;

  const _PlatformView({super.key, required this.viewType, required this.creationParams});

  @override
  State<_PlatformView> createState() => _PlatformViewState();
}

class _PlatformViewState extends State<_PlatformView> {
  bool _initialized = false;
  double _opacity = 0.0;
  Timer? _debounceTimer;
  ScrollPosition? _scrollPosition;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _setupScrollListener();
    }
  }

  void _setupScrollListener() {
    // Stop listening to previous position if any
    _scrollPosition?.removeListener(_onScrollChanged);

    // Find the nearest scrollable ancestor
    _scrollPosition = Scrollable.maybeOf(context)?.position;

    if (_scrollPosition != null) {
      _scrollPosition!.addListener(_onScrollChanged);
      // Start initial timer in case we're already stationary
      _onScrollChanged();
    } else {
      // Not in a scroll view, use simple delay
      _startInitTimer();
    }
  }

  void _onScrollChanged() {
    if (_initialized) return;

    // Reset timer whenever scrolling happens
    _debounceTimer?.cancel();
    _startInitTimer();
  }

  void _startInitTimer() {
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted && !_initialized) {
        setState(() {
          _initialized = true;
        });
        // Small delay before fading in to ensure native view is ready
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            setState(() {
              _opacity = 1.0;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollPosition?.removeListener(_onScrollChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const SizedBox.shrink();
    }

    Widget platformView;
    if (defaultTargetPlatform == TargetPlatform.android) {
      platformView = AndroidView(
        viewType: widget.viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: widget.creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      platformView = UiKitView(
        viewType: widget.viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: widget.creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return const SizedBox.shrink();
    }

    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 200),
      child: platformView,
    );
  }
}
