import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_native_admob_ads_method_channel.dart';
import 'native_ad_models.dart';

/// The platform interface that all implementations of flutter_native_admob_ads must extend.
abstract class FlutterNativeAdmobAdsPlatform extends PlatformInterface {
  /// Constructs a FlutterNativeAdmobAdsPlatform.
  FlutterNativeAdmobAdsPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterNativeAdmobAdsPlatform _instance = MethodChannelFlutterNativeAdmobAds();

  /// The default instance of [FlutterNativeAdmobAdsPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterNativeAdmobAds].
  static FlutterNativeAdmobAdsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterNativeAdmobAdsPlatform] when
  /// they register themselves.
  static set instance(FlutterNativeAdmobAdsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Loads one or more native ads with the specified options.
  Future<List<FlutterNativeAd>> loadNativeAd({
    required String adId,
    bool isTesting = false,
    int adsCount = 1,
  }) {
    throw UnimplementedError('loadNativeAd() has not been implemented.');
  }

  /// Triggers a click on the specified ad.
  Future<void> triggerNativeAd(String id) {
    throw UnimplementedError('triggerNativeAd() has not been implemented.');
  }

  /// Disposes of the specified ad.
  Future<void> disposeNativeAd(String id) {
    throw UnimplementedError('disposeNativeAd() has not been implemented.');
  }
}
