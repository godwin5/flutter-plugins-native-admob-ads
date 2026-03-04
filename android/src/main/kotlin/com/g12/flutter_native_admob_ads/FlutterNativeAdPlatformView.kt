package com.g12.flutter_native_admob_ads

import android.content.Context
import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
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
    private val ctaView: View = View(context)

    init {
        // Overlay for clicks - Using View instead of Button to be less aggressive with gestures
        ctaView.setBackgroundColor(Color.TRANSPARENT)
        ctaView.isClickable = true
        ctaView.isFocusable = true
        ctaView.layoutParams = FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        
        // Listen for internal views being added (like AdChoices) and hide them immediately
        adView.setOnHierarchyChangeListener(object : ViewGroup.OnHierarchyChangeListener {
            override fun onChildViewAdded(parent: View?, child: View?) {
                if (child != ctaView) {
                    child?.visibility = View.GONE
                    child?.alpha = 0f
                }
            }
            override fun onChildViewRemoved(parent: View?, child: View?) {}
        })

        adView.requestLayout()

        // Defer heavy ad binding to the next native frame to prevent scroll hitch
        adView.post {
            adView.setNativeAd(nativeAd)
            
            // Add AdChoices first so it's behind the CTA layer if needed
            nativeAd.adChoicesInfo?.let {
                val adChoicesView = AdChoicesView(context)
                adChoicesView.visibility = View.INVISIBLE
                adChoicesView.layoutParams = FrameLayout.LayoutParams(1, 1).apply {
                    gravity = Gravity.TOP or Gravity.START
                }
                adView.addView(adChoicesView)
                adView.adChoicesView = adChoicesView
            }

            adView.addView(ctaView)
            adView.callToActionView = ctaView
            
            // Ensure the view is laid out properly to register click areas
            adView.requestLayout()
            
            // Start the robust hiding loop
            enforceHiding()
        }
    }

    private fun enforceHiding() {
        val handler = Handler(Looper.getMainLooper())
        val hideTask = object : Runnable {
            var checks = 0
            override fun run() {
                // Surgical sweep: hide anything that isn't our CTA overlay
                for (i in 0 until adView.childCount) {
                    val child = adView.getChildAt(i)
                    if (child != ctaView) {
                        child.alpha = 0f
                        child.visibility = View.GONE
                    }
                }
                // Specifically target the AdChoices view if registered
                adView.adChoicesView?.let {
                    it.alpha = 0f
                    it.visibility = View.GONE
                }
                
                checks++
                if (checks < 6) { // Check 6 times over 3 seconds
                    handler.postDelayed(this, 500)
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
