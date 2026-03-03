package com.g12.flutter_native_admob_ads

import android.content.Context
import com.google.android.gms.ads.nativead.NativeAd
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class FlutterNativeAdViewFactory(
    private val nativeAds: Map<String, NativeAd>
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String?, Any?>?
        val adId = creationParams?.get("id") as String? ?: ""
        val nativeAd = nativeAds[adId] ?: throw IllegalArgumentException("Native Ad not found for ID: $adId")
        return FlutterNativeAdPlatformView(context, nativeAd)
    }
}
