import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'models/app_config.dart';
import 'services/storage_service.dart';
import 'widgets/vip_header.dart';
import 'screens/trading_screen.dart';
import 'screens/mining_screen.dart';
import 'screens/assets_screen.dart';
import 'screens/earn_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.obsidian,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const JuwishCoinApp());
}

class JuwishCoinApp extends StatelessWidget {
  const JuwishCoinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JuwishCoin JWC',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  double _jwcBalance = 0.0;
  double _usdtBalance = 0.0;
  double _wbnbBalance = 0.0;

  final List<String> _screenTitles = [
    'Trade Terminal',
    'Cloud Mine',
    'Asset Vault',
    'VIP Earn',
  ];

  @override
  void initState() {
    super.initState();
    _jwcBalance = StorageService.instance.loadJwcBalance();
    _usdtBalance = StorageService.instance.loadUsdtBalance();
    _wbnbBalance = StorageService.instance.loadWbnbBalance();
  }

  void _onSwapComplete(double deltaJwc, double deltaUsdt, [double deltaWbnb = 0.0]) {
    setState(() {
      _jwcBalance = (_jwcBalance + deltaJwc).clamp(0.0, double.infinity);
      _usdtBalance = (_usdtBalance + deltaUsdt).clamp(0.0, double.infinity);
      _wbnbBalance = (_wbnbBalance + deltaWbnb).clamp(0.0, double.infinity);
    });
    StorageService.instance.saveJwcBalance(_jwcBalance);
    StorageService.instance.saveUsdtBalance(_usdtBalance);
    StorageService.instance.saveWbnbBalance(_wbnbBalance);
    if (deltaJwc > 0) {
      AppConfig.instance.recordDepositOrPurchase(deltaJwc);
    }
  }

  void _onYieldClaimed(double deltaJwc) {
    setState(() {
      _jwcBalance += deltaJwc;
    });
    StorageService.instance.saveJwcBalance(_jwcBalance);
  }

  void _onBalanceUpdated(double deltaJwc) {
    setState(() {
      _jwcBalance = (_jwcBalance + deltaJwc).clamp(0.0, double.infinity);
    });
    StorageService.instance.saveJwcBalance(_jwcBalance);
    if (deltaJwc > 0) {
      AppConfig.instance.recordDepositOrPurchase(deltaJwc);
    }
  }

  void _onDepositConfirmed({
    required String token,
    required double amount,
    required String txHash,
  }) {
    setState(() {
      if (token == 'USDT') {
        _usdtBalance += amount;
      } else if (token == 'WBNB' || token == 'BNB') {
        _wbnbBalance += amount;
      } else if (token == 'JWC') {
        _jwcBalance += amount;
        AppConfig.instance.recordDepositOrPurchase(amount);
      }
    });
    StorageService.instance.saveJwcBalance(_jwcBalance);
    StorageService.instance.saveUsdtBalance(_usdtBalance);
    StorageService.instance.saveWbnbBalance(_wbnbBalance);

    StorageService.instance.addDepositTransaction(
      token: token,
      amount: amount,
      txHash: txHash,
      status: 'VERIFIED_ON_CHAIN',
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      TradingScreen(
        jwcBalance: _jwcBalance,
        usdtBalance: _usdtBalance,
        wbnbBalance: _wbnbBalance,
        onSwapComplete: (deltaJwc, deltaUsdt, [deltaWbnb = 0.0]) => _onSwapComplete(deltaJwc, deltaUsdt, deltaWbnb),
        onOpenDeposit: () => setState(() => _currentIndex = 2),
      ),
      MiningScreen(
        onYieldClaimed: _onYieldClaimed,
        onNavigateToTab: (index) => setState(() => _currentIndex = index),
        onDirectActivationPurchase: (jwcAmount) {
          setState(() {
            _jwcBalance += jwcAmount;
          });
          StorageService.instance.saveJwcBalance(_jwcBalance);
          AppConfig.instance.recordDepositOrPurchase(jwcAmount);
        },
      ),
      AssetsScreen(
        jwcBalance: _jwcBalance,
        usdtBalance: _usdtBalance,
        wbnbBalance: _wbnbBalance,
        onBalanceUpdated: _onBalanceUpdated,
        onDepositConfirmed: _onDepositConfirmed,
        onNavigateToTrade: () => setState(() => _currentIndex = 0),
      ),
      EarnScreen(
        jwcBalance: _jwcBalance,
        onRewardClaimed: _onBalanceUpdated,
      ),
    ];

    return ListenableBuilder(
      listenable: AppConfig.instance,
      builder: (context, _) {
        final config = AppConfig.instance;

        return Scaffold(
          backgroundColor: AppTheme.obsidian,
          resizeToAvoidBottomInset: true,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.obsidian,
                  border: Border.symmetric(
                    vertical: BorderSide(
                      color: AppTheme.goldPrimary.withAlpha(20),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(200),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // VIP Top Header Bar
                      VipHeader(
                        title: _screenTitles[_currentIndex],
                        jwcBalance: _jwcBalance,
                      ),
                      // Live Global Broadcast Announcement Banner
                      if (config.isBannerActive && config.broadcastMessage.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.goldAmber.withAlpha(45),
                                AppTheme.goldPrimary.withAlpha(20),
                              ],
                            ),
                            border: Border(
                              bottom: BorderSide(
                                color: AppTheme.goldAmber.withAlpha(80),
                                width: 0.8,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: AppTheme.goldPrimary.withAlpha(40),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.campaign_rounded,
                                  color: AppTheme.goldPrimary,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  config.broadcastMessage,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    color: AppTheme.goldChampagne,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Current Active Screen
                      Expanded(
                        child: IndexedStack(
                          index: _currentIndex,
                          children: screens,
                        ),
                      ),
                      // Bottom Navigation Bar docked inside mobile frame
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCharcoal,
                          border: Border(
                            top: BorderSide(
                              color: AppTheme.goldPrimary.withAlpha(40),
                              width: 1,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(180),
                              blurRadius: 16,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: BottomNavigationBar(
                          currentIndex: _currentIndex,
                          onTap: (index) {
                            HapticFeedback.selectionClick();
                            setState(() => _currentIndex = index);
                          },
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          type: BottomNavigationBarType.fixed,
                          selectedItemColor: AppTheme.goldPrimary,
                          unselectedItemColor: AppTheme.textMuted,
                          selectedLabelStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          items: const [
                            BottomNavigationBarItem(
                              icon: Icon(Icons.candlestick_chart_rounded),
                              activeIcon: Icon(Icons.candlestick_chart_rounded, color: AppTheme.goldPrimary),
                              label: 'Trade',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(Icons.stars_rounded),
                              activeIcon: Icon(Icons.stars_rounded, color: AppTheme.goldPrimary),
                              label: 'Mine',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(Icons.account_balance_wallet_rounded),
                              activeIcon: Icon(Icons.account_balance_wallet_rounded, color: AppTheme.goldPrimary),
                              label: 'Vault',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(Icons.military_tech_rounded),
                              activeIcon: Icon(Icons.military_tech_rounded, color: AppTheme.goldPrimary),
                              label: 'Earn',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
