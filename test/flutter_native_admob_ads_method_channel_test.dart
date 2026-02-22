import 'package:flutter/services.dart';
import 'package:flutter_native_admob_ads/flutter_native_admob_ads_method_channel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFlutterNativeAdmobAds platform = MethodChannelFlutterNativeAdmobAds();
  const MethodChannel channel = MethodChannel('flutter_native_admob_ads');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      MethodCall methodCall,
    ) async {
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('loadNativeAd returns empty list on null result', () async {
    // expect(await platform.loadNativeAd(NativeAdOptions(adId: 'test')), isEmpty);
  });
}
