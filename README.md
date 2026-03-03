# flutter_native_admob_ads

A specialized Flutter plugin for **AdMob Native Ads** that gives you 100% control over the UI. Build your ads using standard Flutter widgets while maintaining native tracking and perfect click handling via a transparent native overlay.

## Why this plugin?

Standard AdMob plugins often force you to use rigid "Native Templates." This plugin gives you full control:

1.  **Total UI Freedom**: Build your entire ad layout using standard Flutter widgets (Text, Image, Container, etc.).
2.  **Reliable Click Handling**: Uses a native `PlatformView` overlay to ensure AdMob correctly registers clicks and impressions with precise coordinates.
3.  **Automatic Compliance**: The plugin handles the heavy lifting of mapping native ad assets to Flutter-friendly objects, including image metadata and aspect ratios.

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_native_admob_ads: ^1.5.0
```

## Platform Setup

### Android

Add your AdMob App ID to `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy"/>
```

### iOS

Add your AdMob App ID to `ios/Runner/Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy</string>
```

## Usage

### 1. Load an Ad

```dart
import 'package:flutter_native_admob_ads/flutter_native_admob_ads.dart';
import 'package:flutter_native_admob_ads/native_ad_models.dart';

final _plugin = FlutterNativeAdmobAds();

final ads = await _plugin.loadNativeAd(
  adId: 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy',
  isTesting: true,
  adsCount: 1,
);

if (ads.isNotEmpty) {
  final ad = ads.first;
}
```

### 2. Display the Ad

Wrap your custom UI with the `FlutterNativeAdView` widget. This widget places a transparent native layer over your content to capture clicks.

```dart
FlutterNativeAdView(
  ad: ad,
  // Add an overlay for interactive elements like the AdChoices button
  overlay: Positioned(
    top: 0,
    right: 0,
    child: AdChoicesWidget(ad: ad),
  ),
  child: Container(
    padding: EdgeInsets.all(12),
    child: Column(
      children: [
        if (ad.aspectRatio != null)
           AspectRatio(
             aspectRatio: ad.aspectRatio!,
             child: Image.network(ad.cover!),
           ),
        Text(ad.headline ?? ""),
        Text(ad.body ?? ""),
      ],
    ),
  ),
)
```

### 3. Image Metadata & Aspect Ratio

The plugin returns structured metadata for images to help you build better layouts:

- **`ad.aspectRatio`**: The aspect ratio (width/height) of the primary media content.
- **`ad.icon` / `ad.images`**: Now return objects containing:
  - `url`: The image URL.
  - `width` / `height`: Dimensions in pixels.
  - `scale`: Scaling factor.

### 4. Cleanup

To prevent memory leaks, always dispose of the ad when the widget is destroyed:

```dart
@override
void dispose() {
  _plugin.disposeNativeAd(ad.id);
  super.dispose();
}
```

## Policy Compliance

Since you are building the UI, you are responsible for:

1.  **"Ad" Attribution**: Clearly marking the content as an advertisement.
2.  **AdChoices Icon**: Using the provided `adChoicesUrl` and `adChoicesText` to display an AdChoices icon. **Note**: The native AdChoices icon is automatically hidden by the plugin to allow your custom Flutter implementation to work without overlap.
3.  **Interaction**: Use the `overlay` parameter of `FlutterNativeAdView` for any widgets that need to capture their own touches (like the AdChoices icon) to ensure they aren't blocked by the native click layer.

## Limitations

- **No Native Video**: This plugin currently focus on static assets (images and text).
- **Manual Compliance**: You must ensure your custom UI follows AdMob's [Native Ad Policies](https://support.google.com/admob/answer/6128543).

## License

MIT License
