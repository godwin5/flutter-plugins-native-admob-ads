import 'package:flutter/material.dart';
import 'package:flutter_native_admob_ads/flutter_native_admob_ads.dart';
import 'package:flutter_native_admob_ads/native_ad_models.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AdMob Native Ads Demo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const NativeAdDemo(),
    );
  }
}

class NativeAdDemo extends StatefulWidget {
  const NativeAdDemo({super.key});

  @override
  State<NativeAdDemo> createState() => _NativeAdDemoState();
}

class _NativeAdDemoState extends State<NativeAdDemo> {
  final _admobPlugin = FlutterNativeAdmobAds();
  FlutterNativeAd? _loadedAd;
  bool _isLoading = false;
  String? _errorMessage;

  /// Loads a native ad from the plugin
  Future<void> _loadAd() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _loadedAd = null;
    });

    try {
      final ads = await _admobPlugin.loadNativeAd(
        adId: 'ca-app-pub-3940256099942544/2247696110', // Test ID
        isTesting: true,
        adsCount: 1,
      );

      if (ads.isNotEmpty) {
        setState(() {
          _loadedAd = ads.first;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "No ads returned from SDK";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Programmatically disposes of the current ad
  Future<void> _disposeAd() async {
    if (_loadedAd != null) {
      final adId = _loadedAd!.id;
      setState(() {
        _loadedAd = null;
      });
      await _admobPlugin.disposeNativeAd(adId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ad disposed')));
    }
  }

  @override
  void dispose() {
    // CRITICAL: Always dispose of the native ad to prevent memory leaks
    if (_loadedAd != null) {
      _admobPlugin.disposeNativeAd(_loadedAd!.id);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Native Ad Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _loadAd,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Load Native Ad'),
                ),
                if (_loadedAd != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _disposeAd,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Dispose Ad'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red))
            else if (_loadedAd != null)
              _buildNativeAdCard(_loadedAd!)
            else
              const Text('Tap the button above to load an ad.'),
          ],
        ),
      ),
    );
  }

  /// Builds a 100% custom Flutter UI for the native ad data
  Widget _buildNativeAdCard(FlutterNativeAd ad) {
    return FlutterNativeAdView(
      ad: ad,
      overlay: ad.adChoicesUrl == null
          ? null
          : Positioned(
              top: 4,
              right: 8,
              child: GestureDetector(
                onTap: () => launchUrl(Uri.parse(ad.adChoicesUrl!)),
                child: const Icon(Icons.info_outline, size: 14, color: Colors.black),
              ),
            ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ad attribution row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Colors.amber,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'AD',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),

            // Cover Image
            if (ad.cover != null)
              Image.network(
                ad.cover!,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox(height: 180, child: Icon(Icons.image)),
              ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Icon
                  if (ad.icon != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(ad.icon!, width: 48, height: 48),
                    ),
                  const SizedBox(width: 12),

                  // Headline, Star Rating, Body
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                ad.headline ?? 'No Headline',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (ad.starRating != null)
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 14, color: Colors.orange),
                                  Text(
                                    ad.starRating!.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        if (ad.advertiser != null || ad.store != null || ad.price != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              [
                                ad.advertiser,
                                ad.store,
                                ad.price,
                              ].whereType<String>().where((s) => s.isNotEmpty).join(' • '),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          ad.body ?? '',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // CTA Button
            // Note: Clicks on this button (and the entire card) are now handled
            // by the native platform view overlay provided by FlutterNativeAdView.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ElevatedButton(
                onPressed: () {}, // Handled by FlutterNativeAdView overlay
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(ad.cta ?? 'Learn More'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
