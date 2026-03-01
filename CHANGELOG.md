## 1.4.2

- **Optimization**: Synchronized iOS proxy view settings with Android (centered, 1x1 size, 0.0 alpha).

## 1.4.1

- **Fix**: Improved ad click reliability on Android by centering the proxy native view.

## 1.4.0

- **License Update**: Switched to standard MIT license.

## 1.3.2

- **Fix**: Resolved an issue where a visible "dot" appeared on Android by reducing the native proxy view's alpha.

## 1.3.1

- Added policy compliance warning regarding manual ad clicks to README.
- Synced documentation and license fixes for better pub.dev score recognition.

## 1.3.0

- Refactored `loadNativeAd`: Changed from `FlutterNativeAdOptions` class to named parameters for a cleaner API.
- Added descriptive documentation comments to all properties in `FlutterNativeAd`.
- Fixed iOS podspec metadata (homepage and license information).

## 1.2.0

- **Exhaustive NativeAd Support**: Added support for all standard AdMob NativeAd fields:
  - Star Rating (`double? starRating`)
  - Store (`String? store`)
  - Price (`String? price`)
  - Multiple Images (`List<String> images`)
  - AdChoices Text (`String? adChoicesText`)
- **Example Update**: Enhanced example app UI to demonstrate new metadata fields.
- **Backward Compatibility**: Kept `cover` as a getter for `images.firstOrNull`.

## 1.1.0

- **Breaking Change**: Renamed `NativeAd` to `FlutterNativeAd` and `NativeAdOptions` to `FlutterNativeAdOptions`.

## 1.0.2

- **Critical Fix (Android)**: Resolved `Unresolved reference 'contentUrl'` compilation error.
- **iOS Fixes**: Modernized root view controller access and standardized AdChoices handling for consistency.

## 1.0.1

- **AdChoices Update**: Improved AdChoices URL handling for Android and iOS.
- **Example Fix**: Resolved missing `url_launcher` import in the example app.

## 1.0.0

- **Initial release**: First official release of `flutter_native_admob_ads`.
- **AdChoices Support**: Standardized AdChoices URL handling for Android and iOS.
- **Custom UI Support**: Build 100% custom Flutter UIs for AdMob Native Ads.
- **Cross-Platform**: Full support for Android and iOS.
