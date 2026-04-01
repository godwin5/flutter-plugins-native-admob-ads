## 1.7.0

- **AdRequest Targeting**: Added support for advanced targeting parameters in `AdRequest`.
  - Keywords, Content URL, Neighboring Content URLs, etc.
- **Mediation Extras**: Added full support for specialized mediation extras matching the official `google_mobile_ads` API.
  - New `MediationExtras` and `GenericMediationExtras` classes.
- **Non-Personalized Ads**: Easy toggle for requesting non-personalized ads.

## 1.6.0

- **Ad Event Listeners**: Added support for tracking ad lifecycle events directly in Flutter.
  - New callbacks in `loadNativeAd`: `onImpression`, `onClicked`, `onOpened`, `onClosed`.
- **Android Stability**: Implemented sequential ad loading to ensure each ad receives its own dedicated lifecycle events.
- **iOS Sync**: Implemented `GADNativeAdDelegate` to capture and forward identical events on iOS.

## 1.5.3

- **Buttery Smooth Scrolling**: Implemented "Async Native Binding" to fix those tiny freezes when scrolling past ads. The heavy work now happens in the background, making list scrolling much smoother.
- **Performance**: Optimized the native view creation process to be as lightweight as possible.

## 1.5.2

- **Scroll Fixed**: Restored standard scrolling behavior by removing the aggressive gesture recognizer. Use the ad's non-interactive areas to scroll.
- **Click Fixed**: Changed the background of the click overlay to be transparent instead of invisible. This ensures it catches clicks more reliably even before a scroll happens.
- **Improved Hiding**: Added a robust cleanup loop to catch and hide AdChoices icons that pop up after the ad loads.
- **Stability**: Added a unique `ValueKey` to the native click overlay to prevent "ghosting" when scrolling through lists of ads.

## 1.5.1

- **Final AdChoices Fix**: Blocked the native AdChoices icon from overlapping your custom Flutter UI.
- **Better Docs**: Polished the README with clearer examples for the new layout features.

## 1.5.0

- **Big Architectural Shift**: Moved to a native overlay for click handling. This finally kills the "Invalid click coordinates" and "size too small" warnings.
- **Asset Metadata**: You now get `width`, `height`, and `scale` for all images and icons.
- **Pixel Perfect Layouts**: Added `ad.aspectRatio`. Use it with the Flutter `AspectRatio` widget to make your ads look great on any screen.
- **Cleaner API**: Removed the manual `triggerNativeAd` method and swapped empty strings for proper `null` values for missing properties.

## 1.4.2

- **iOS Sync**: Made the iOS proxy view match the Android settings for better consistency.

## 1.4.1

- **Click Fix**: Centered the proxy view on Android to make clicks even more reliable.

## 1.4.0

- **License Update**: Switched the project to the standard MIT license.

## 1.3.2

- **Visual Fix**: Fixed a tiny visible "dot" that sometimes appeared on Android.

## 1.3.1

- **Documentation**: Added policy warnings to the README and improved the pub.dev search score.

## 1.3.0

- **Cleaner Loading**: Switched `loadNativeAd` to named parameters for a better dev experience.
- **Better Docs**: Added detailed comments to all ad properties.
- **iOS Metadata**: Fixed the podspec to show the correct project links.

## 1.2.0

- **Full Metadata Support**: Added support for star ratings, store names, prices, and multiple images.
- **Compatibility**: Kept the `cover` property as a shortcut for the first image in the list.

## 1.1.0

- **Naming**: Renamed the core classes to `FlutterNativeAd` for better clarity.

## 1.0.0

- **Initial Release**: The first official version of the plugin with full custom UI support and cross-platform compatibility.
