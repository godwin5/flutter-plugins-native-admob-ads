package com.g12.flutter_native_admob_ads

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.view.Gravity
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
    private val nativeAds = HashMap<String, NativeAd>()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_native_admob_ads")
        channel.setMethodCallHandler(this)
        
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "flutter_native_ad_view", 
            FlutterNativeAdViewFactory(nativeAds)
        )
        
        MobileAds.initialize(context!!) { }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "loadNativeAd" -> {
                loadNativeAd(call, result)
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

        synchronized(nativeAds) {
            nativeAds[id] = nativeAd
        }

        return map
    }


    private fun disposeNativeAd(call: MethodCall, result: Result) {
        val id = call.argument<String>("id")
        synchronized(nativeAds) {
            nativeAds.remove(id)
        }
        result.success(null)
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
