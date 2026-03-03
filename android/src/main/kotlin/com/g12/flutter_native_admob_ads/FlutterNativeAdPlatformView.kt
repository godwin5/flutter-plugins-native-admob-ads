package com.g12.flutter_native_admob_ads

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.FrameLayout
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugin.platform.PlatformView

class FlutterNativeAdPlatformView(
    context: Context,
    nativeAd: NativeAd
) : PlatformView {

    private val adView: NativeAdView = NativeAdView(context)
    private val ctaView: Button = Button(context)

    init {
        // Transparent CTA button that fills the view
        ctaView.alpha = 0.0f
        ctaView.layoutParams = FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        
        adView.addView(ctaView)
        adView.callToActionView = ctaView
        adView.setNativeAd(nativeAd)
    }

    override fun getView(): View {
        return adView
    }

    override fun dispose() {
        adView.destroy()
    }
}
