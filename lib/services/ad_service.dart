import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Ad Unit IDs
  static const String _bannerAdUnitId = 'ca-app-pub-8612078867148332/6175540426';
  static const String _rewardedAdUnitId = 'ca-app-pub-8612078867148332/5078081170';
  static const String _interstitialAdUnitId = 'ca-app-pub-8612078867148332/4862458755';

  BannerAd? _bannerAd;
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  
  bool _isBannerAdLoaded = false;
  bool _isRewardedAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  
  int _levelsSinceLastAd = 0;
  
  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;
  BannerAd? get bannerAd => _bannerAd;

  /// Initialize Mobile Ads SDK
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    debugPrint("AdMob SDK Initialized");
    
    // Preload ads
    loadBannerAd();
    loadRewardedAd();
    loadInterstitialAd();
  }

  /// Load Banner Ad
  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdLoaded = true;
          debugPrint("Banner Ad Loaded");
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdLoaded = false;
          ad.dispose();
          debugPrint("Banner Ad Failed: ${error.message}");
        },
      ),
    );
    _bannerAd!.load();
  }

  /// Load Rewarded Ad (for extra moves)
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          debugPrint("Rewarded Ad Loaded");
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoaded = false;
          debugPrint("Rewarded Ad Failed: ${error.message}");
        },
      ),
    );
  }

  /// Load Interstitial Ad (between levels)
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          debugPrint("Interstitial Ad Loaded");
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoaded = false;
          debugPrint("Interstitial Ad Failed: ${error.message}");
        },
      ),
    );
  }

  /// Show Rewarded Ad and call onRewarded when user finishes watching
  Future<bool> showRewardedAd({required Function(int reward) onRewarded}) async {
    if (!_isRewardedAdLoaded || _rewardedAd == null) {
      debugPrint("Rewarded ad not ready");
      return false;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isRewardedAdLoaded = false;
        loadRewardedAd(); // Reload for next time
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isRewardedAdLoaded = false;
        loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded(reward.amount.toInt());
      },
    );
    
    return true;
  }

  /// Show Interstitial Ad (call after level completion)
  Future<void> showInterstitialAd() async {
    _levelsSinceLastAd++;
    
    // Only show every 3 levels to not annoy users
    if (_levelsSinceLastAd < 3) {
      debugPrint("Skipping interstitial (levels since last: $_levelsSinceLastAd)");
      return;
    }
    
    if (!_isInterstitialAdLoaded || _interstitialAd == null) {
      debugPrint("Interstitial ad not ready");
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isInterstitialAdLoaded = false;
        _levelsSinceLastAd = 0; // Reset counter
        loadInterstitialAd(); // Reload for next time
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isInterstitialAdLoaded = false;
        loadInterstitialAd();
      },
    );

    await _interstitialAd!.show();
  }

  /// Dispose all ads
  void dispose() {
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
  }
}

final adServiceProvider = Provider<AdService>((ref) => AdService());
