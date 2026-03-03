import Flutter
import UIKit
import GoogleMobileAds

class FlutterNativeAdPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
    private var plugin: FlutterNativeAdmobAdsPlugin

    init(plugin: FlutterNativeAdmobAdsPlugin) {
        self.plugin = plugin
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        let creationParams = args as? [String: Any]
        let adId = creationParams?["id"] as? String ?? ""
        
        guard let nativeAd = plugin.nativeAds[adId] else {
            fatalError("Native Ad not found for ID: \(adId)")
        }
        
        return FlutterNativeAdPlatformView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            nativeAd: nativeAd
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
