# flutter_native_admob_ads

A specialized Flutter plugin for **AdMob Native Ads** that gives you 100% control over the UI. Build your ads using standard Flutter widgets while maintaining native tracking and click handling.

## Why this plugin?

Standard AdMob plugins often force you to use rigid "Native Templates." This plugin gives you full control:

1. **Total UI Freedom**: You build the entire ad layout using standard Flutter widgets (Text, Image, etc.).
2. **Native Tracking**: The plugin manages a hidden native view to ensure AdMob correctly registers impressions.
3. **Manual Trigger**: You decide exactly which interaction triggers the ad click by calling a simple method.

### Use Cases

- **High-Fidelity Branding**: Match your ad's style perfectly with your app's design system.
- **Complex Layouts**: Build ad layouts that are difficult or impossible to achieve with standard native templates.
- **Performance**: Avoid the overhead of multiple heavy PlatformViews for small list-item ads.

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_native_admob_ads: ^1.1.0
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
  adId: 'ca-app-pub-3940256099942544/2247696110', // Test ID
  isTesting: true,
  adsCount: 1,
);

if (ads.isNotEmpty) {
  final ad = ads.first;
  // Use ad.headline, ad.body, ad.icon, ad.cover, etc.
}
```

### 2. Trigger a Click

When the user taps your custom CTA button in Flutter:

```dart
onTap: () async {
  await _plugin.triggerNativeAd(ad.id);
}
```

### 3. Handle AdChoices

To comply with AdMob policies, you should always include an AdChoices icon that links to the `adChoicesUrl`:

```dart
if (ad.adChoicesUrl != null)
  GestureDetector(
    onTap: () => launchUrl(Uri.parse(ad.adChoicesUrl!)),
    child: const Icon(Icons.info_outline, size: 14),
  );
```

### 4. Cleanup

To prevent memory leaks, always dispose of the ad when the widget is destroyed:

```dart
@override
void dispose() {
  _plugin.disposeNativeAd(ad.id);
  super.dispose();
}
```

## Limitations

- **Only Static Native Ads**: This plugin currently only supports static assets (images and text). **Native Video ads are not supported** yet.
- **Only Native Ads**: This plugin does not support Banners, Interstitials, or Rewarded ads.
- **Manual Compliance**: Since you are building the UI, you are responsible for including the "Ad" attribution and "AdChoices" icon to comply with AdMob policies.

## License

MIT
