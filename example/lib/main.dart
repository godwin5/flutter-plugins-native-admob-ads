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
        FlutterNativeAdOptions(
          adId: 'ca-app-pub-3940256099942544/2247696110', // Android Test ID
          isTesting: true,
          adsCount: 1,
        ),
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

  /// Triggers a programmatic click on the native ad
  Future<void> _handleAdClick() async {
    if (_loadedAd != null) {
      await _admobPlugin.triggerNativeAd(_loadedAd!.id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ad click triggered!')));
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
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _loadAd,
              icon: const Icon(Icons.refresh),
              label: const Text('Load Native Ad'),
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
    return Card(
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
                if (ad.adChoicesUrl != null)
                  GestureDetector(
                    onTap: () => launchUrl(Uri.parse(ad.adChoicesUrl!)),
                    child: const Icon(Icons.info_outline, size: 14, color: Colors.black),
                  ),
              ],
            ),
          ),

          // Cover Image
          if (ad.cover != null)
            Image.network(
              ad.cover!,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(height: 180, child: Icon(Icons.image)),
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

                // Headline & Body
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad.headline ?? 'No Headline',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton(
              onPressed: _handleAdClick,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(ad.cta ?? 'Learn More'),
            ),
          ),
        ],
      ),
    );
  }
}
