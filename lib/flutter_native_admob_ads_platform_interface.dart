import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_native_admob_ads_method_channel.dart';
import 'native_ad_models.dart';

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

  Future<List<NativeAd>> loadNativeAd(NativeAdOptions options) {
    throw UnimplementedError('loadNativeAd() has not been implemented.');
  }

  Future<void> triggerNativeAd(String id) {
    throw UnimplementedError('triggerNativeAd() has not been implemented.');
  }

  Future<void> disposeNativeAd(String id) {
    throw UnimplementedError('disposeNativeAd() has not been implemented.');
  }
}
