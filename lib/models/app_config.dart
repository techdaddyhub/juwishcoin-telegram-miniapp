import 'package:flutter/foundation.dart';

/// Global Admin Configuration for JuwishCoin (JWC) Telegram Mini App
class AppConfig extends ChangeNotifier {
  static final AppConfig instance = AppConfig._internal();
  AppConfig._internal();

  // Mining Parameters
  double tapYield = 10.0;
  int maxEnergy = 1000;
  double baseHashrateGhs = 142.8;
  double passiveYieldPerHour = 34.5;

  // Trading & Market Parameters
  double jwcPriceUsdt = 3.0000;
  double priceChange24h = 18.42;
  double stakingApy = 32.5;
  double referralCommissionPct = 10.0;

  // Global Announcement Banner (Broadcast from Admin)
  bool isBannerActive = true;
  String broadcastMessage = '🔥 VIP STAKING BONUS: PancakeSwap V3 0% fee deposit active!';

  // Admin Security
  String adminPin = '7777';

  void updateMiningSettings({
    double? newTapYield,
    int? newMaxEnergy,
    double? newHashrate,
    double? newPassiveYield,
  }) {
    if (newTapYield != null) tapYield = newTapYield;
    if (newMaxEnergy != null) maxEnergy = newMaxEnergy;
    if (newHashrate != null) baseHashrateGhs = newHashrate;
    if (newPassiveYield != null) passiveYieldPerHour = newPassiveYield;
    notifyListeners();
  }

  void updateMarketSettings({
    double? newPrice,
    double? newPriceChange,
    double? newStakingApy,
    double? newReferralPct,
  }) {
    if (newPrice != null) jwcPriceUsdt = newPrice;
    if (newPriceChange != null) priceChange24h = newPriceChange;
    if (newStakingApy != null) stakingApy = newStakingApy;
    if (newReferralPct != null) referralCommissionPct = newReferralPct;
    notifyListeners();
  }

  void updateBroadcast({required bool active, required String message}) {
    isBannerActive = active;
    broadcastMessage = message;
    notifyListeners();
  }
}

