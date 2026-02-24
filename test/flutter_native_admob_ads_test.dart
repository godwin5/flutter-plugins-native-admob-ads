import 'package:flutter_native_admob_ads/flutter_native_admob_ads_method_channel.dart';
import 'package:flutter_native_admob_ads/flutter_native_admob_ads_platform_interface.dart';
import 'package:flutter_native_admob_ads/native_ad_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterNativeAdmobAdsPlatform
    with MockPlatformInterfaceMixin
    implements FlutterNativeAdmobAdsPlatform {
  @override
  Future<List<FlutterNativeAd>> loadNativeAd({
    required String adId,
    bool isTesting = false,
    int adsCount = 1,
  }) async => [];

  @override
  Future<void> triggerNativeAd(String id) async {}

  @override
  Future<void> disposeNativeAd(String id) async {}
}

void main() {
  final FlutterNativeAdmobAdsPlatform initialPlatform = FlutterNativeAdmobAdsPlatform.instance;

  test('$MethodChannelFlutterNativeAdmobAds is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterNativeAdmobAds>());
  });
}
