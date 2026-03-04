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
        
        _view.isUserInteractionEnabled = true
        _ctaButton.isUserInteractionEnabled = true
        super.init()
        _ctaButton.backgroundColor = .clear
        _ctaButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        _view.addSubview(_ctaButton)
        _view.callToActionView = _ctaButton
        
        // Defer heavy ad binding to the next native frame to prevent scroll hitch
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Hide the auto-injected AdChoices icon to allow custom Flutter implementation
            // We use a small view at the back of the stack to avoid blocking clicks
            let adChoicesView = GADAdChoicesView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            adChoicesView.isHidden = true
            self._view.addSubview(adChoicesView)
            self._view.adChoicesView = adChoicesView

            self._view.nativeAd = nativeAd
            
            // Robust hiding loop to catch delayed SDK injections
            self.enforceHiding()
        }
    }

    private func enforceHiding(checks: Int = 0) {
        // Surgical sweep: hide anything that isn't our CTA overlay
        for subview in _view.subviews {
            if subview != _ctaButton {
                subview.isHidden = true
                subview.alpha = 0
            }
        }
        _view.adChoicesView?.isHidden = true
        _view.adChoicesView?.alpha = 0
        
        if checks < 6 { // Check 6 times over 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.enforceHiding(checks: checks + 1)
            }
        }
    }

    func view() -> UIView {
        return _view
    }
}
