class FlutterNativeAd {
  final String id;
  final String? headline;
  final String? body;
  final String? advertiser;
  final String? icon;
  final String? cover;
  final String? cta;
  final String? adChoicesUrl;

  FlutterNativeAd({
    required this.id,
    this.headline,
    this.body,
    this.advertiser,
    this.icon,
    this.cover,
    this.cta,
    this.adChoicesUrl,
  });

  factory FlutterNativeAd.fromMap(Map<String, dynamic> map) {
    return FlutterNativeAd(
      id: map['id'] as String,
      headline: map['headline'] as String?,
      body: map['body'] as String?,
      advertiser: map['advertiser'] as String?,
      icon: map['icon'] as String?,
      cover: map['cover'] as String?,
      cta: map['cta'] as String?,
      adChoicesUrl: map['adChoicesUrl'] as String?,
    );
  }
}

class FlutterNativeAdOptions {
  final String adId;
  final bool isTesting;
  final int adsCount;

  FlutterNativeAdOptions({required this.adId, this.isTesting = false, this.adsCount = 1})
    : assert(adsCount >= 1 && adsCount <= 5);

  Map<String, dynamic> toMap() {
    return {'adId': adId, 'isTesting': isTesting, 'adsCount': adsCount};
  }
}
