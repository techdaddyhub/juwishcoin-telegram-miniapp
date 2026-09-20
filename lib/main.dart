import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
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
  double _jwcBalance = 148250.0;

  final List<String> _screenTitles = [
    'Trade Terminal',
    'Cloud Mine',
    'Asset Vault',
    'VIP Earn',
  ];

  void _onSwapComplete(double deltaJwc, double deltaUsdt) {
    setState(() {
      _jwcBalance += deltaJwc;
    });
  }

  void _onYieldClaimed(double deltaJwc) {
    setState(() {
      _jwcBalance += deltaJwc;
    });
  }

  void _onBalanceUpdated(double deltaJwc) {
    setState(() {
      _jwcBalance += deltaJwc;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      TradingScreen(
        jwcBalance: _jwcBalance,
        onSwapComplete: _onSwapComplete,
      ),
      MiningScreen(
        onYieldClaimed: _onYieldClaimed,
      ),
      AssetsScreen(
        jwcBalance: _jwcBalance,
        onBalanceUpdated: _onBalanceUpdated,
      ),
      EarnScreen(
        jwcBalance: _jwcBalance,
        onRewardClaimed: _onBalanceUpdated,
      ),
    ];

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
                  // Current Active Screen
                  Expanded(
                    child: IndexedStack(
                      index: _currentIndex,
                      children: screens,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
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
        ),
      ),
    );
  }
}
