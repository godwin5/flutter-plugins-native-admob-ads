import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_native_admob_ads_platform_interface.dart';
import 'native_ad_models.dart';

/// An implementation of [FlutterNativeAdmobAdsPlatform] that uses method channels.
class MethodChannelFlutterNativeAdmobAds extends FlutterNativeAdmobAdsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_native_admob_ads');

  @override
  Future<List<FlutterNativeAd>> loadNativeAd(FlutterNativeAdOptions options) async {
    final List<dynamic>? result = await methodChannel.invokeMethod<List<dynamic>>(
      'loadNativeAd',
      options.toMap(),
    );

    if (result == null) return [];

    return result.map((e) => FlutterNativeAd.fromMap(Map<String, dynamic>.from(e as Map))).toList();
  }

  @override
  Future<void> triggerNativeAd(String id) async {
    await methodChannel.invokeMethod('triggerNativeAd', {'id': id});
  }

  @override
  Future<void> disposeNativeAd(String id) async {
    await methodChannel.invokeMethod('disposeNativeAd', {'id': id});
  }
}
