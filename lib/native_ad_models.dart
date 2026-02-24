class FlutterNativeAd {
  final String id;
  final String? headline;
  final String? body;
  final String? advertiser;
  final String? icon;
  final List<String> images;
  String? get cover => images.isNotEmpty ? images.first : null;
  final String? cta;
  final double? starRating;
  final String? store;
  final String? price;
  final String? adChoicesUrl;
  final String? adChoicesText;

  FlutterNativeAd({
    required this.id,
    this.headline,
    this.body,
    this.advertiser,
    this.icon,
    this.images = const [],
    this.cta,
    this.starRating,
    this.store,
    this.price,
    this.adChoicesUrl,
    this.adChoicesText,
  });

  factory FlutterNativeAd.fromMap(Map<String, dynamic> map) {
    // Parse images from comma-separated string
    final imagesRaw = map['images'] as String? ?? "";
    final imagesList = imagesRaw.isNotEmpty ? imagesRaw.split(',') : <String>[];

    // Add cover if not already in images
    final cover = map['cover'] as String?;
    if (cover != null && cover.isNotEmpty && !imagesList.contains(cover)) {
      imagesList.insert(0, cover);
    }

    return FlutterNativeAd(
      id: map['id'] as String,
      headline: map['headline'] as String?,
      body: map['body'] as String?,
      advertiser: map['advertiser'] as String?,
      icon: map['icon'] as String?,
      images: imagesList,
      cta: map['cta'] as String?,
      starRating: double.tryParse(map['starRating'] as String? ?? ""),
      store: map['store'] as String?,
      price: map['price'] as String?,
      adChoicesUrl: map['adChoicesUrl'] as String?,
      adChoicesText: map['adChoicesText'] as String?,
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
