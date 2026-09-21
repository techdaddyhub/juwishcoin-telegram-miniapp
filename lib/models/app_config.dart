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

  // Mining Activation Gate (Requires 5 JWC deposit/purchase to start mining)
  bool isMiningActivationRequired = true;
  double activationThresholdJwc = 5.0;
  bool isMiningUnlocked = false;
  double userDepositedJwc = 0.0;

  bool get canUserMine => !isMiningActivationRequired || isMiningUnlocked;

  void recordDepositOrPurchase(double amountJwc) {
    userDepositedJwc += amountJwc;
    if (userDepositedJwc >= activationThresholdJwc) {
      isMiningUnlocked = true;
    }
    notifyListeners();
  }

  void unlockMiningDirectly() {
    isMiningUnlocked = true;
    if (userDepositedJwc < activationThresholdJwc) {
      userDepositedJwc = activationThresholdJwc;
    }
    notifyListeners();
  }

  void updateMiningGateSettings({
    bool? required,
    double? threshold,
    bool? unlocked,
  }) {
    if (required != null) isMiningActivationRequired = required;
    if (threshold != null) activationThresholdJwc = threshold;
    if (unlocked != null) isMiningUnlocked = unlocked;
    notifyListeners();
  }

  // Trading & Market Parameters
  double jwcPriceUsdt = 3.0000;
  double priceChange24h = 18.42;
  double stakingApy = 32.5;
  double referralCommissionPct = 10.0;

  // Official BEP-20 Smart Contract on BNB Smart Chain
  String contractAddress = '0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99';
  String get shortContractAddress =>
      '${contractAddress.substring(0, 6)}...${contractAddress.substring(contractAddress.length - 4)}';
  String get bscScanUrl => 'https://bscscan.com/token/$contractAddress';
  String get pancakeSwapBuyUrl =>
      'https://pancakeswap.finance/swap?outputCurrency=$contractAddress&inputCurrency=0x55d398326f99059fF775485246999027B3197955';
  String get pancakeSwapSellUrl =>
      'https://pancakeswap.finance/swap?inputCurrency=$contractAddress&outputCurrency=0x55d398326f99059fF775485246999027B3197955';
  String get dexScreenerUrl => 'https://dexscreener.com/bsc/$contractAddress';

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

