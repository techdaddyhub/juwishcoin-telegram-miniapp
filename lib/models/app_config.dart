import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

/// Global Admin Configuration for JuwishCoin (JWC) Telegram Mini App
class AppConfig extends ChangeNotifier {
  static final AppConfig instance = AppConfig._internal();

  AppConfig._internal() {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    adminDepositWalletAddress = StorageService.instance.loadAdminDepositWallet() ?? '0x7F2b4A2E65dEa8f90c819A0f3c5D285b0185c819';
    jwcPriceUsdt = StorageService.instance.loadJwcPrice() ?? 3.0000;
    wbnbPriceUsdt = StorageService.instance.loadWbnbPrice() ?? 600.00;
    isMiningUnlocked = StorageService.instance.loadMiningUnlocked();
    userDepositedJwc = StorageService.instance.loadUserDepositedJwc();
    stakedPositions = StorageService.instance.loadStakedPositions();
    tapYield = StorageService.instance.loadTapYield() ?? 0.0001;
    passiveYieldPerHour = StorageService.instance.loadPassiveYieldPerHour() ?? 0.0030;
    dailyMiningCapJwc = StorageService.instance.loadDailyMiningCap() ?? 0.15;
  }

  // Sustainable Mining Parameters (Engineered to protect project treasury & liquidity)
  // Activation Fee: 5.0 JWC ($15.00 USDT).
  // Target daily ROI: ~2% (0.10 JWC/day). Daily safety ceiling: 0.15 JWC/day.
  double tapYield = 0.0001;              // 0.0001 JWC per tap (~0.05 JWC per full 500-tap energy bar)
  int maxEnergy = 1000;                  // 1000 max energy
  double baseHashrateGhs = 142.8;
  double passiveYieldPerHour = 0.0030;   // 0.0030 JWC / hour (~0.072 JWC / 24 hours passive)
  double dailyMiningCapJwc = 0.15;       // Hard daily ceiling: max 0.15 JWC (~$0.45 USDT / 24h)
  double minClaimThreshold = 0.05;       // Minimum claimable yield: 0.05 JWC (~$0.15 USDT)

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
    StorageService.instance.saveUserDepositedJwc(userDepositedJwc);
    StorageService.instance.saveMiningUnlocked(isMiningUnlocked);
    notifyListeners();
  }

  void unlockMiningDirectly() {
    isMiningUnlocked = true;
    if (userDepositedJwc < activationThresholdJwc) {
      userDepositedJwc = activationThresholdJwc;
    }
    StorageService.instance.saveUserDepositedJwc(userDepositedJwc);
    StorageService.instance.saveMiningUnlocked(true);
    notifyListeners();
  }

  void updateMiningGateSettings({
    bool? required,
    double? threshold,
    bool? unlocked,
  }) {
    if (required != null) isMiningActivationRequired = required;
    if (threshold != null) activationThresholdJwc = threshold;
    if (unlocked != null) {
      isMiningUnlocked = unlocked;
      StorageService.instance.saveMiningUnlocked(unlocked);
    }
    notifyListeners();
  }

  // Staking Parameters (5 JWC min, 500 JWC max, 7+ days duration)
  double minStakeAmountJwc = 5.0;
  double maxStakeAmountJwc = 500.0;
  int minLockDays = 7;

  // Sustainable Tier APYs (Carefully calculated so platform preserves treasury while rewarding stakers)
  final Map<int, double> stakingTiersApy = {
    7: 12.0,   // 7 Days Lock:  12.0% APY (~0.230% ROI)
    14: 15.0,  // 14 Days Lock: 15.0% APY (~0.575% ROI)
    30: 18.5,  // 30 Days Lock: 18.5% APY (~1.521% ROI)
    60: 22.0,  // 60 Days Lock: 22.0% APY (~3.616% ROI)
    90: 28.0,  // 90 Days Lock: 28.0% APY (~6.904% ROI)
  };

  List<StakedPosition> stakedPositions = [];

  double get totalStakedJwc =>
      stakedPositions.where((p) => !p.isClaimed).fold(0.0, (acc, p) => acc + p.amount);

  double get totalEstimatedStakingYield =>
      stakedPositions.where((p) => !p.isClaimed).fold(0.0, (acc, p) => acc + p.expectedYield);

  double calculateStakingYield(double amount, int lockDays) {
    final apy = stakingTiersApy[lockDays] ?? 12.0;
    return amount * (apy / 100.0) * (lockDays / 365.0);
  }

  StakedPosition? createStake(double amount, int lockDays) {
    if (amount < minStakeAmountJwc || amount > maxStakeAmountJwc) return null;
    if (lockDays < minLockDays) return null;

    final apy = stakingTiersApy[lockDays] ?? 12.0;
    final expectedYield = calculateStakingYield(amount, lockDays);
    final now = DateTime.now();

    final position = StakedPosition(
      id: 'stake_${now.millisecondsSinceEpoch}',
      amount: amount,
      lockDays: lockDays,
      apy: apy,
      expectedYield: expectedYield,
      startDate: now,
      unlockDate: now.add(Duration(days: lockDays)),
    );

    stakedPositions.insert(0, position);
    StorageService.instance.saveStakedPositions(stakedPositions);
    notifyListeners();
    return position;
  }

  bool harvestStake(String id) {
    final index = stakedPositions.indexWhere((p) => p.id == id);
    if (index == -1) return false;
    final pos = stakedPositions[index];
    if (pos.isClaimed) return false;
    pos.isClaimed = true;
    StorageService.instance.saveStakedPositions(stakedPositions);
    notifyListeners();
    return true;
  }

  // Trading & Market Parameters
  double jwcPriceUsdt = 3.0000;
  double wbnbPriceUsdt = 600.00;
  double priceChange24h = 18.42;
  double stakingApy = 18.5; // Average baseline staking APY
  double referralCommissionPct = 10.0;

  // Admin Official Receiving Wallet on BNB Smart Chain (BEP-20)
  String adminDepositWalletAddress = '0x7F2b4A2E65dEa8f90c819A0f3c5D285b0185c819';
  String get shortAdminDepositWallet =>
      '${adminDepositWalletAddress.substring(0, 6)}...${adminDepositWalletAddress.substring(adminDepositWalletAddress.length - 4)}';

  void updateAdminDepositWallet(String newAddress) {
    adminDepositWalletAddress = newAddress.trim();
    StorageService.instance.saveAdminDepositWallet(adminDepositWalletAddress);
    notifyListeners();
  }

  // Official BEP-20 Smart Contract on BNB Smart Chain
  String contractAddress = '0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99';
  String get shortContractAddress =>
      '${contractAddress.substring(0, 6)}...${contractAddress.substring(contractAddress.length - 4)}';
  String get bscScanUrl => 'https://bscscan.com/token/$contractAddress';
  String get pancakeSwapBuyUrl =>
      'https://pancakeswap.finance/swap?chain=bsc&outputCurrency=$contractAddress&inputCurrency=0x55d398326f99059fF775485246999027B3197955';
  String get pancakeSwapBuyWithBnbUrl =>
      'https://pancakeswap.finance/swap?chain=bsc&outputCurrency=$contractAddress&inputCurrency=BNB';
  String get pancakeSwapBuyWithWbnbUrl =>
      'https://pancakeswap.finance/swap?chain=bsc&outputCurrency=$contractAddress&inputCurrency=0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c';
  String get pancakeSwapSellUrl =>
      'https://pancakeswap.finance/swap?chain=bsc&inputCurrency=$contractAddress&outputCurrency=0x55d398326f99059fF775485246999027B3197955';
  String get dexScreenerUrl => 'https://dexscreener.com/bsc/$contractAddress';

  // Global Announcement Banner (Broadcast from Admin)
  bool isBannerActive = true;
  String broadcastMessage = '🔥 VIP STAKING BONUS: PancakeSwap V2/V3 liquidity active!';

  // Admin Security
  String adminPin = '7777';

  void updateMiningSettings({
    double? newTapYield,
    int? newMaxEnergy,
    double? newHashrate,
    double? newPassiveYield,
    double? newDailyCap,
  }) {
    if (newTapYield != null) {
      tapYield = newTapYield;
      StorageService.instance.saveTapYield(newTapYield);
    }
    if (newMaxEnergy != null) maxEnergy = newMaxEnergy;
    if (newHashrate != null) baseHashrateGhs = newHashrate;
    if (newPassiveYield != null) {
      passiveYieldPerHour = newPassiveYield;
      StorageService.instance.savePassiveYieldPerHour(newPassiveYield);
    }
    if (newDailyCap != null) {
      dailyMiningCapJwc = newDailyCap;
      StorageService.instance.saveDailyMiningCap(newDailyCap);
    }
    notifyListeners();
  }

  void updateMarketSettings({
    double? newPrice,
    double? newWbnbPrice,
    double? newPriceChange,
    double? newStakingApy,
    double? newReferralPct,
  }) {
    if (newPrice != null) {
      jwcPriceUsdt = newPrice;
      StorageService.instance.saveJwcPrice(newPrice);
    }
    if (newWbnbPrice != null) {
      wbnbPriceUsdt = newWbnbPrice;
      StorageService.instance.saveWbnbPrice(newWbnbPrice);
    }
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

class StakedPosition {
  final String id;
  final double amount;
  final int lockDays;
  final double apy;
  final double expectedYield;
  final DateTime startDate;
  final DateTime unlockDate;
  bool isClaimed;

  StakedPosition({
    required this.id,
    required this.amount,
    required this.lockDays,
    required this.apy,
    required this.expectedYield,
    required this.startDate,
    required this.unlockDate,
    this.isClaimed = false,
  });

  bool get isMatured => DateTime.now().isAfter(unlockDate);
  int get remainingDays =>
      isMatured ? 0 : unlockDate.difference(DateTime.now()).inDays + 1;
}
