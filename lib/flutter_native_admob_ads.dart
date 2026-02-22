import 'flutter_native_admob_ads_platform_interface.dart';
import 'native_ad_models.dart';

class FlutterNativeAdmobAds {
  Future<List<FlutterNativeAd>> loadNativeAd(FlutterNativeAdOptions options) {
    return FlutterNativeAdmobAdsPlatform.instance.loadNativeAd(options);
  }

  Future<void> triggerNativeAd(String id) {
    return FlutterNativeAdmobAdsPlatform.instance.triggerNativeAd(id);
  }

  Future<void> disposeNativeAd(String id) {
    return FlutterNativeAdmobAdsPlatform.instance.disposeNativeAd(id);
  }
}
