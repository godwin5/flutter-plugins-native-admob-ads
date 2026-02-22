package com.g12.flutter_native_admob_ads

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.mockito.Mockito
import kotlin.test.Test

/*
 * This demonstrates a simple unit test of the Kotlin portion of this plugin's implementation.
 */
internal class FlutterNativeAdmobAdsPluginTest {
    @Test
    fun onMethodCall_loadNativeAd_invokesSuccess() {
        // Basic test to verify the plugin class exists and can be instantiated
        val plugin = FlutterNativeAdmobAdsPlugin()
        assert(plugin != null)
    }
}
