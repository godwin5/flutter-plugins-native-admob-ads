import Flutter
import UIKit
import GoogleMobileAds

public class FlutterNativeAdmobAdsPlugin: NSObject, FlutterPlugin, GADAdLoaderDelegate, GADNativeAdLoaderDelegate {
  private var adLoader: GADAdLoader?
  internal var nativeAds = [String: GADNativeAd]()
  private var loadResults = [String: (loaded: [[String: Any?]], failed: Int, total: Int, result: FlutterResult)]()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_native_admob_ads", binaryMessenger: registrar.messenger())
    let instance = FlutterNativeAdmobAdsPlugin()
    instance.channelInstance = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    registrar.register(
      FlutterNativeAdPlatformViewFactory(plugin: instance),
      withId: "flutter_native_ad_view"
    )
    
    GADMobileAds.sharedInstance().start(completionHandler: nil)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "loadNativeAd":
      loadNativeAd(call, result: result)
    case "disposeNativeAd":
      disposeNativeAd(call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func loadNativeAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(code: "INVALID_ARGS", message: "Arguments must be a dictionary", detail: nil))
      return
    }

    let isTesting = args["isTesting"] as? Bool ?? false
    let adId = isTesting ? "ca-app-pub-3940256099942544/3986624511" : args["adId"] as? String

    guard let finalAdId = adId else {
      result(FlutterError(code: "MISSING_AD_ID", message: "Ad ID is required", detail: nil))
      return
    }

    let adsCount = args["adsCount"] as? Int ?? 1
    let requestId = UUID().uuidString
    loadResults[requestId] = (loaded: [], failed: 0, total: adsCount, result: result)

    let multipleAdsOptions = GADMultipleAdsOptions()
    multipleAdsOptions.numberOfAds = adsCount

    let window = UIApplication.shared.connectedScenes
      .filter { $0.activationState == .foregroundActive }
      .map { $0 as? UIWindowScene }
      .compactMap { $0 }
      .first?.windows
      .filter { $0.isKeyWindow }.first

    adLoader = GADAdLoader(
      adUnitID: finalAdId,
      rootViewController: window?.rootViewController,
      adTypes: [.native],
      options: [multipleAdsOptions]
    )
    adLoader?.delegate = self
    adLoader?.load(GADRequest())
  }

  public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
    let adId = UUID().uuidString
    var adMap = [String: Any?]()
    
    adMap["id"] = adId
    adMap["headline"] = nativeAd.headline
    adMap["body"] = nativeAd.body
    adMap["advertiser"] = nativeAd.advertiser
    adMap["cta"] = nativeAd.callToAction
    adMap["starRating"] = nativeAd.starRating
    adMap["store"] = nativeAd.store
    adMap["price"] = nativeAd.price
    
    // Icon
    if let adIcon = nativeAd.icon {
        var iconMap = [String: Any?]()
        iconMap["url"] = adIcon.imageURL?.absoluteString
        if let img = adIcon.image {
            iconMap["width"] = Double(img.size.width)
            iconMap["height"] = Double(img.size.height)
        }
        iconMap["scale"] = Double(adIcon.scale)
        adMap["icon"] = iconMap
    }
    
    // Images
    if let images = nativeAd.images, !images.isEmpty {
        let imageListData = images.map { adImage -> [String: Any?] in
            var imageMap = [String: Any?]()
            imageMap["url"] = adImage.imageURL?.absoluteString
            if let img = adImage.image {
                imageMap["width"] = Double(img.size.width)
                imageMap["height"] = Double(img.size.height)
            }
            imageMap["scale"] = Double(adImage.scale)
            return imageMap
        }
        adMap["images"] = imageListData
        adMap["cover"] = imageListData.first?["url"] as? String
    } else {
        adMap["images"] = nil
        adMap["cover"] = nil
    }
    
    // Media Content (Aspect Ratio)
    adMap["aspectRatio"] = Double(nativeAd.mediaContent.aspectRatio)
    
    adMap["adChoicesUrl"] = "https://adssettings.google.com/whythisad"
    adMap["adChoicesText"] = nativeAd.adChoicesInfo?.text

    self.nativeAds[adId] = nativeAd
    nativeAd.delegate = self

    finalizeRequest(adLoader, adMap: adMap)
  }

  public func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
      if let adId = findAdId(for: nativeAd) {
          invokeOnMain("onAdImpression", arguments: adId)
      }
  }

  public func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
      if let adId = findAdId(for: nativeAd) {
          invokeOnMain("onAdClicked", arguments: adId)
      }
  }

  public func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
      if let adId = findAdId(for: nativeAd) {
          invokeOnMain("onAdOpened", arguments: adId)
      }
  }

  public func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
      if let adId = findAdId(for: nativeAd) {
          invokeOnMain("onAdClosed", arguments: adId)
      }
  }

  private func findAdId(for nativeAd: GADNativeAd) -> String? {
      return nativeAds.first(where: { $0.value === nativeAd })?.key
  }

  private var channelInstance: FlutterMethodChannel?

  private func invokeOnMain(_ method: String, arguments: Any?) {
      DispatchQueue.main.async {
          self.channelInstance?.invokeMethod(method, arguments: arguments)
      }
  }

  private func finalizeRequest(_ adLoader: GADAdLoader, adMap: [String: Any?]?) {
      for (key, var val) in loadResults {
          if let map = adMap {
              val.loaded.append(map)
              loadResults[key] = val
          }
          if val.loaded.count + val.failed == val.total {
              val.result(val.loaded)
              loadResults.removeValue(forKey: key)
          }
      }
  }

  public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
    for (key, var val) in loadResults {
        val.failed += 1
        loadResults[key] = val
        if val.loaded.count + val.failed == val.total {
            if val.loaded.isEmpty {
                val.result(FlutterError(code: "LOAD_FAILED", message: error.localizedDescription, detail: nil))
            } else {
                val.result(val.loaded)
            }
            loadResults.removeValue(forKey: key)
        }
    }
  }


  private func disposeNativeAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let id = args["id"] as? String else {
      result(nil)
      return
    }

    self.nativeAds.removeValue(forKey: id)
    result(nil)
  }
}
