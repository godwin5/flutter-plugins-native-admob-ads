import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_native_admob_ads_platform_interface.dart';
import 'native_ad_models.dart';

/// An implementation of [FlutterNativeAdmobAdsPlatform] that uses method channels.
class MethodChannelFlutterNativeAdmobAds extends FlutterNativeAdmobAdsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_native_admob_ads');

  final Map<String, List<Function(String)>> _adCallbacks = {};

  MethodChannelFlutterNativeAdmobAds() {
    methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    final String? adId = call.arguments as String?;
    if (adId == null) return;

    final callbacks = _adCallbacks[adId];
    if (callbacks == null) return;

    switch (call.method) {
      case 'onAdImpression':
        callbacks[0](adId);
        break;
      case 'onAdClicked':
        callbacks[1](adId);
        break;
      case 'onAdOpened':
        callbacks[2](adId);
        break;
      case 'onAdClosed':
        callbacks[3](adId);
        break;
    }
  }

  @override
  Future<List<FlutterNativeAd>> loadNativeAd({
    required String adId,
    bool isTesting = false,
    int adsCount = 1,
    AdRequest? adRequest,
    void Function(String adId)? onImpression,
    void Function(String adId)? onClicked,
    void Function(String adId)? onOpened,
    void Function(String adId)? onClosed,
  }) async {
    final Map<String, dynamic> arguments = {
      'adId': adId,
      'isTesting': isTesting,
      'adsCount': adsCount,
      'adRequest': adRequest?.toMap(),
    };

    final List<dynamic>? result = await methodChannel.invokeMethod<List<dynamic>>('loadNativeAd', arguments);

    if (result == null) return [];

    final ads = result.map((e) => FlutterNativeAd.fromMap(Map<String, dynamic>.from(e as Map))).toList();

    for (var ad in ads) {
      _adCallbacks[ad.id] = [
        onImpression ?? (_) {},
        onClicked ?? (_) {},
        onOpened ?? (_) {},
        onClosed ?? (_) {},
      ];
    }

    return ads;
  }

  @override
  Future<void> disposeNativeAd(String id) async {
    _adCallbacks.remove(id);
    await methodChannel.invokeMethod('disposeNativeAd', {'id': id});
  }
}
