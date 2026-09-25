import 'dart:convert';
import '../utils/platform_storage.dart';
import '../models/app_config.dart';

/// Centralized persistence service to ensure zero data loss on web reload or bot refresh.
class StorageService {
  static final StorageService instance = StorageService._internal();
  StorageService._internal();

  // Storage Keys
  static const String _keyJwcBalance = 'jwc_balance_v1';
  static const String _keyUsdtBalance = 'usdt_balance_v1';
  static const String _keyWbnbBalance = 'wbnb_balance_v1';
  static const String _keyMiningUnlocked = 'mining_unlocked_v1';
  static const String _keyUserDepositedJwc = 'user_deposited_jwc_v1';
  static const String _keyMiningTotalFarmed = 'mining_total_farmed_v1';
  static const String _keyMiningUnclaimed = 'mining_unclaimed_v1';
  static const String _keyMiningEnergy = 'mining_energy_v1';
  static const String _keyStakedPositions = 'staked_positions_v1';
  static const String _keyDepositTxs = 'deposit_txs_v1';
  static const String _keyClaimedTasks = 'claimed_tasks_v1';
  static const String _keyAdminWallet = 'admin_deposit_wallet_v1';
  static const String _keyJwcPrice = 'jwc_price_usdt_v1';
  static const String _keyWbnbPrice = 'wbnb_price_usdt_v1';
  static const String _keyDailyMinedAmount = 'mining_daily_mined_amount_v1';
  static const String _keyDailyMinedDate = 'mining_daily_mined_date_v1';
  static const String _keyTapYield = 'mining_tap_yield_v1';
  static const String _keyPassiveYieldPerHour = 'mining_passive_hourly_v1';
  static const String _keyDailyMiningCap = 'mining_daily_cap_v1';

  // --- Balances ---
  double loadJwcBalance() => PlatformStorage.getDouble(_keyJwcBalance) ?? 0.0;
  void saveJwcBalance(double val) => PlatformStorage.saveDouble(_keyJwcBalance, val);

  double loadUsdtBalance() => PlatformStorage.getDouble(_keyUsdtBalance) ?? 0.0;
  void saveUsdtBalance(double val) => PlatformStorage.saveDouble(_keyUsdtBalance, val);

  double loadWbnbBalance() => PlatformStorage.getDouble(_keyWbnbBalance) ?? 0.0;
  void saveWbnbBalance(double val) => PlatformStorage.saveDouble(_keyWbnbBalance, val);

  // --- Mining State ---
  bool loadMiningUnlocked() => PlatformStorage.getBool(_keyMiningUnlocked) ?? false;
  void saveMiningUnlocked(bool val) => PlatformStorage.saveBool(_keyMiningUnlocked, val);

  double loadUserDepositedJwc() => PlatformStorage.getDouble(_keyUserDepositedJwc) ?? 0.0;
  void saveUserDepositedJwc(double val) => PlatformStorage.saveDouble(_keyUserDepositedJwc, val);

  double loadMiningTotalFarmed() => PlatformStorage.getDouble(_keyMiningTotalFarmed) ?? 0.0;
  void saveMiningTotalFarmed(double val) => PlatformStorage.saveDouble(_keyMiningTotalFarmed, val);

  double loadMiningUnclaimed() => PlatformStorage.getDouble(_keyMiningUnclaimed) ?? 0.0;
  void saveMiningUnclaimed(double val) => PlatformStorage.saveDouble(_keyMiningUnclaimed, val);

  int loadMiningEnergy() => PlatformStorage.getInt(_keyMiningEnergy) ?? 1000;
  void saveMiningEnergy(int val) => PlatformStorage.saveInt(_keyMiningEnergy, val);

  // --- Staked Positions ---
  List<StakedPosition> loadStakedPositions() {
    final raw = PlatformStorage.getString(_keyStakedPositions);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        return StakedPosition(
          id: map['id'] as String,
          amount: (map['amount'] as num).toDouble(),
          lockDays: map['lockDays'] as int,
          apy: (map['apy'] as num).toDouble(),
          expectedYield: (map['expectedYield'] as num).toDouble(),
          startDate: DateTime.parse(map['startDate'] as String),
          unlockDate: DateTime.parse(map['unlockDate'] as String),
          isClaimed: map['isClaimed'] as bool? ?? false,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  void saveStakedPositions(List<StakedPosition> positions) {
    try {
      final list = positions.map((p) => {
        'id': p.id,
        'amount': p.amount,
        'lockDays': p.lockDays,
        'apy': p.apy,
        'expectedYield': p.expectedYield,
        'startDate': p.startDate.toIso8601String(),
        'unlockDate': p.unlockDate.toIso8601String(),
        'isClaimed': p.isClaimed,
      }).toList();
      PlatformStorage.saveString(_keyStakedPositions, jsonEncode(list));
    } catch (_) {}
  }

  // --- Deposit Transactions ---
  List<Map<String, dynamic>> loadDepositTransactions() {
    final raw = PlatformStorage.getString(_keyDepositTxs);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  void saveDepositTransactions(List<Map<String, dynamic>> txs) {
    try {
      PlatformStorage.saveString(_keyDepositTxs, jsonEncode(txs));
    } catch (_) {}
  }

  void addDepositTransaction({
    required String token,
    required double amount,
    required String txHash,
    required String status,
  }) {
    final txs = loadDepositTransactions();
    txs.insert(0, {
      'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
      'token': token,
      'amount': amount,
      'txHash': txHash,
      'status': status,
      'timestamp': DateTime.now().toIso8601String(),
    });
    saveDepositTransactions(txs);
  }

  // --- Claimed Earn Tasks ---
  Set<String> loadClaimedTasks() {
    final raw = PlatformStorage.getString(_keyClaimedTasks);
    if (raw == null || raw.isEmpty) return {};
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e.toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  void saveClaimedTasks(Set<String> tasks) {
    try {
      PlatformStorage.saveString(_keyClaimedTasks, jsonEncode(tasks.toList()));
    } catch (_) {}
  }

  // --- Admin Configuration Persistence ---
  String? loadAdminDepositWallet() => PlatformStorage.getString(_keyAdminWallet);
  void saveAdminDepositWallet(String addr) => PlatformStorage.saveString(_keyAdminWallet, addr);

  double? loadJwcPrice() => PlatformStorage.getDouble(_keyJwcPrice);
  void saveJwcPrice(double price) => PlatformStorage.saveDouble(_keyJwcPrice, price);

  double? loadWbnbPrice() => PlatformStorage.getDouble(_keyWbnbPrice);
  void saveWbnbPrice(double price) => PlatformStorage.saveDouble(_keyWbnbPrice, price);

  // --- Daily Mining Guardrail Persistence ---
  double loadDailyMinedAmount() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = PlatformStorage.getString(_keyDailyMinedDate);
    if (savedDate != today) {
      PlatformStorage.saveString(_keyDailyMinedDate, today);
      PlatformStorage.saveDouble(_keyDailyMinedAmount, 0.0);
      return 0.0;
    }
    return PlatformStorage.getDouble(_keyDailyMinedAmount) ?? 0.0;
  }

  void saveDailyMinedAmount(double val) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    PlatformStorage.saveString(_keyDailyMinedDate, today);
    PlatformStorage.saveDouble(_keyDailyMinedAmount, val);
  }

  // --- Mining Parameters Persistence ---
  double? loadTapYield() => PlatformStorage.getDouble(_keyTapYield);
  void saveTapYield(double val) => PlatformStorage.saveDouble(_keyTapYield, val);

  double? loadPassiveYieldPerHour() => PlatformStorage.getDouble(_keyPassiveYieldPerHour);
  void savePassiveYieldPerHour(double val) => PlatformStorage.saveDouble(_keyPassiveYieldPerHour, val);

  double? loadDailyMiningCap() => PlatformStorage.getDouble(_keyDailyMiningCap);
  void saveDailyMiningCap(double val) => PlatformStorage.saveDouble(_keyDailyMiningCap, val);
}
