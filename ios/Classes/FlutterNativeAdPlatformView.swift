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
        
        // Aggressively hide the AdChoices icon by providing a full-size invisible view
        let adChoicesView = GADAdChoicesView(frame: _view.bounds)
        adChoicesView.alpha = 0
        adChoicesView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _view.addSubview(adChoicesView)
        _view.adChoicesView = adChoicesView
        
        // Enforce hiding after a delay to catch the SDK's "delayed" injection
        enforceHiding()
    }

    private func enforceHiding(checks: Int = 0) {
        let view = self._view
        let cta = self._ctaButton
        
        // Hide all subviews except the CTA
        for subview in view.subviews {
            if subview != cta {
                subview.alpha = 0
                subview.isHidden = true
            }
        }
        view.adChoicesView?.alpha = 0
        view.adChoicesView?.isHidden = true
        
        if checks < 5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                self?.enforceHiding(checks: checks + 1)
            }
        }
    }

    func view() -> UIView {
        return _view
    }
}
