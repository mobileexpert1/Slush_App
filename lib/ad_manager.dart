import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
const String bannerAdUnitIdAndroid = "ca-app-pub-3940256099942544/9214589741";
const String bannerAdUnitIos = "ca-app-pub-8921975243322271/9125625793";
const String interstitialAdUnitIdAndroid = "ca-app-pub-3940256099942544/1033173712";
const String interstitialAdUnitIdIos = "ca-app-pub-3940256099942544/1033173712";
const String appOpenAdUnitIdAndroid = "ca-app-pub-8921975243322271/3268979675";
const String appOpenAdUnitIdIos = "ca-app-pub-3940256099942544/5662855259";
class AdManager {
  static Future<BannerAd> loadBannerAd(BannerAdListener listener) async {
    final bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: Platform.isAndroid ? bannerAdUnitIdAndroid : bannerAdUnitIos,
      listener: listener,
      request: const AdRequest(),
    );
    bannerAd.load();
    return bannerAd;
  }
  static void loadInterstitialAd(Function() onAdClosed) async {
    InterstitialAd.load(
      adUnitId: Platform.isAndroid ? interstitialAdUnitIdAndroid : interstitialAdUnitIdIos,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              onAdClosed();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error.');
        },
      ),
    );
  }
  static AppOpenAd? _appOpenAd;
  static bool _isShowingAd = false;
}
