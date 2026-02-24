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

  /// Triggers a click on the Ad with the given [id].
  Future<void> triggerNativeAd(String id) {
    return FlutterNativeAdmobAdsPlatform.instance.triggerNativeAd(id);
  }

  /// Disposes of the Ad with the given [id] and removes it from memory.
  ///
  /// Call this when you no longer need to display the ad to free up resources.
  Future<void> disposeNativeAd(String id) {
    return FlutterNativeAdmobAdsPlatform.instance.disposeNativeAd(id);
  }
}
