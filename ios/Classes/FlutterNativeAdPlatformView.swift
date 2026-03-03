import Flutter
import UIKit
import GoogleMobileAds

class FlutterNativeAdPlatformView: NSObject, FlutterPlatformView {
    private let _view: GADNativeAdView
    private let _ctaButton: UIButton

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        nativeAd: GADNativeAd
    ) {
        _view = GADNativeAdView(frame: frame)
        _ctaButton = UIButton(frame: frame)
        
        super.init()
        
        // Transparent CTA button that fills the view
        _ctaButton.backgroundColor = .clear
        _ctaButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        _view.addSubview(_ctaButton)
        _view.callToActionView = _ctaButton
        _view.nativeAd = nativeAd
    }

    func view() -> UIView {
        return _view
    }
}
