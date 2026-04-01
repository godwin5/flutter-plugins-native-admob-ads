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
import android.os.Bundle
import com.google.ads.mediation.admob.AdMobAdapter
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
        val adRequestMap = call.argument<Map<String, Any?>>("adRequest")
        val adsToReturn = Collections.synchronizedList(mutableListOf<Map<String, Any?>>())
        
        loadAdsSequentially(adId, adsCount, adsToReturn, adRequestMap, result)
    }

    private fun loadAdsSequentially(
        adId: String, 
        remainingCount: Int, 
        loadedAds: MutableList<Map<String, Any?>>, 
        adRequestMap: Map<String, Any?>?,
        result: Result
    ) {
        if (remainingCount <= 0) {
            activity?.runOnUiThread {
                if (loadedAds.isNotEmpty()) {
                    result.success(loadedAds)
                } else {
                    result.error("LOAD_FAILED", "No ads loaded", null)
                }
            }
            return
        }

        val adLoader = AdLoader.Builder(context!!, adId)
            .forNativeAd { nativeAd ->
                val adMap = mapNativeAd(nativeAd)
                loadedAds.add(adMap)
                
                // Trigger next load
                loadAdsSequentially(adId, remainingCount - 1, loadedAds, adRequestMap, result)
            }
            .withAdListener(object : AdListener() {
                var currentAdId: String? = null

                private fun ensureAdId(): String? {
                    if (currentAdId == null && loadedAds.isNotEmpty()) {
                        currentAdId = loadedAds.last()["id"] as String?
                    }
                    return currentAdId
                }

                override fun onAdFailedToLoad(adError: LoadAdError) {
                    loadAdsSequentially(adId, remainingCount - 1, loadedAds, adRequestMap, result)
                }

                override fun onAdOpened() {
                    ensureAdId()?.let { id ->
                        channel.invokeMethod("onAdOpened", id)
                    }
                }

                override fun onAdClicked() {
                    ensureAdId()?.let { id ->
                        channel.invokeMethod("onAdClicked", id)
                    }
                }

                override fun onAdClosed() {
                    ensureAdId()?.let { id ->
                        channel.invokeMethod("onAdClosed", id)
                    }
                }

                override fun onAdImpression() {
                    ensureAdId()?.let { id ->
                        channel.invokeMethod("onAdImpression", id)
                    }
                }
            })
            .withNativeAdOptions(NativeAdOptions.Builder().build())
            .build()

        val adRequest = buildAdRequest(adRequestMap)
        adLoader.loadAd(adRequest)
    }

    private fun buildAdRequest(map: Map<String, Any?>?): AdRequest {
        val builder = AdRequest.Builder()
        if (map == null) return builder.build()

        val keywords = map["keywords"] as? List<String>
        keywords?.forEach { builder.addKeyword(it) }

        val contentUrl = map["contentUrl"] as? String
        contentUrl?.let { builder.setContentUrl(it) }

        val neighboringContentUrls = map["neighboringContentUrls"] as? List<String>
        neighboringContentUrls?.let { builder.setNeighboringContentUrls(it) }

        val httpTimeoutMillis = map["httpTimeoutMillis"] as? Int
        httpTimeoutMillis?.let { builder.setHttpTimeoutMillis(it) }

        // mediationExtrasIdentifier is not supported by AdRequest.Builder

        // Extras and Non-personalized ads
        val extras = Bundle()
        val customExtras = map["extras"] as? Map<String, String>
        customExtras?.forEach { (key, value) -> extras.putString(key, value) }

        val nonPersonalizedAds = map["nonPersonalizedAds"] as? Boolean
        if (nonPersonalizedAds == true) {
            extras.putString("npa", "1")
        }

        if (!extras.isEmpty) {
            builder.addNetworkExtrasBundle(AdMobAdapter::class.java, extras)
        }

        // Other Mediation Extras
        val mediationExtrasList = map["mediationExtras"] as? List<Map<String, Any?>>
        mediationExtrasList?.forEach { extraMap ->
            val adapterClassName = extraMap["androidClassName"] as? String
            val innerExtras = extraMap["extras"] as? Map<String, Any?>
            if (adapterClassName != null && innerExtras != null) {
                try {
                    // Use addNetworkExtrasBundle(Class<? extends MediationExtrasReceiver>, Bundle)
                    val bundle = Bundle()
                    innerExtras.forEach { (k, v) ->
                        when (v) {
                            is String -> bundle.putString(k, v)
                            is Int -> bundle.putInt(k, v)
                            is Boolean -> bundle.putBoolean(k, v)
                            is Double -> bundle.putDouble(k, v)
                        }
                    }
                    val receiverClass = Class.forName(adapterClassName) as Class<out com.google.android.gms.ads.mediation.MediationExtrasReceiver>
                    builder.addNetworkExtrasBundle(receiverClass, bundle)
                } catch (e: Exception) {
                    // Ignore or log error
                }
            }
        }

        return builder.build()
    }

    private fun mapNativeAd(nativeAd: NativeAd): Map<String, Any?> {
        val id = UUID.randomUUID().toString()
        val map = HashMap<String, Any?>()
        
        map["id"] = id
        map["headline"] = nativeAd.headline
        map["body"] = nativeAd.body
        map["advertiser"] = nativeAd.advertiser
        map["cta"] = nativeAd.callToAction
        map["starRating"] = nativeAd.starRating
        map["store"] = nativeAd.store
        map["price"] = nativeAd.price
        
        // Icon
        nativeAd.icon?.let { adIcon ->
            val iconMap = HashMap<String, Any?>()
            iconMap["url"] = adIcon.uri?.toString()
            adIcon.drawable?.let {
                iconMap["width"] = it.intrinsicWidth.toDouble()
                iconMap["height"] = it.intrinsicHeight.toDouble()
            }
            iconMap["scale"] = adIcon.scale
            map["icon"] = iconMap
        }
        
        // Images
        val images = nativeAd.images
        if (images.isNotEmpty()) {
            val imageListData = images.map { adImage ->
                val imageMap = HashMap<String, Any?>()
                imageMap["url"] = adImage.uri?.toString()
                adImage.drawable?.let {
                    imageMap["width"] = it.intrinsicWidth.toDouble()
                    imageMap["height"] = it.intrinsicHeight.toDouble()
                }
                imageMap["scale"] = adImage.scale
                imageMap
            }
            map["images"] = imageListData
            map["cover"] = imageListData.firstOrNull()?.get("url")
        } else {
            map["images"] = null
            map["cover"] = null
        }
        
        // Media Content (Aspect Ratio)
        nativeAd.mediaContent?.let { media ->
            map["aspectRatio"] = media.aspectRatio.toDouble()
        }
        
        val adChoices = nativeAd.adChoicesInfo
        map["adChoicesUrl"] = "https://adssettings.google.com/whythisad"
        map["adChoicesText"] = adChoices?.text?.toString()

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
