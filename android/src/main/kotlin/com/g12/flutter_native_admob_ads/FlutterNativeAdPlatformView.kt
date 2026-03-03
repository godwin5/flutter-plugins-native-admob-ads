package com.g12.flutter_native_admob_ads

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.FrameLayout
import com.google.android.gms.ads.nativead.AdChoicesView
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
        
        // Aggressively hide the AdChoices icon by providing a full-size invisible view
        nativeAd.adChoicesInfo?.let {
            val adChoicesView = AdChoicesView(context)
            adChoicesView.alpha = 0.0f
            adChoicesView.layoutParams = FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            adView.addView(adChoicesView)
            adView.adChoicesView = adChoicesView
        }
        
        adView.setNativeAd(nativeAd)

        // Enforce hiding after a delay to catch the SDK's "delayed" injection
        enforceHiding()
    }

    private fun enforceHiding() {
        val handler = Handler(Looper.getMainLooper())
        val hideTask = object : Runnable {
            var checks = 0
            override fun run() {
                for (i in 0 until adView.childCount) {
                    val child = adView.getChildAt(i)
                    if (child != ctaView) {
                        child.alpha = 0f
                        child.visibility = View.GONE
                    }
                }
                adView.adChoicesView?.alpha = 0f
                adView.adChoicesView?.visibility = View.GONE
                
                checks++
                if (checks < 5) { // Check a few times over 3 seconds
                    handler.postDelayed(this, 600)
                }
            }
        }
        handler.post(hideTask)
    }

    override fun getView(): View {
        return adView
    }

    override fun dispose() {
        adView.destroy()
    }
}
