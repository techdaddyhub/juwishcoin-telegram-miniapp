import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/app_config.dart';
import '../utils/platform_link.dart';

class TradingScreen extends StatefulWidget {
  final double jwcBalance;
  final double usdtBalance;
  final double wbnbBalance;
  final Function(double deltaJwc, double deltaUsdt, double deltaWbnb) onSwapComplete;
  final VoidCallback? onOpenDeposit;

  const TradingScreen({
    super.key,
    required this.jwcBalance,
    required this.usdtBalance,
    required this.wbnbBalance,
    required this.onSwapComplete,
    this.onOpenDeposit,
  });

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  String _selectedPair = 'JWC / USDT';
  final List<String> _pairs = ['JWC / USDT', 'JWC / WBNB', 'WBNB / USDT'];

  String _selectedTimeframe = '1H';
  final List<String> _timeframes = ['15m', '1H', '4H', '1D', '1W'];

  bool _isInstantSwap = true;
  String _payToken = 'USDT';
  String _receiveToken = 'JWC';

  final TextEditingController _payAmountController = TextEditingController(text: '15.00');
  final TextEditingController _receiveAmountController = TextEditingController(text: '5.00');

  double get _currentPrice => AppConfig.instance.jwcPriceUsdt; // Dynamic from Admin
  double get _wbnbPrice => AppConfig.instance.wbnbPriceUsdt; // Dynamic from Admin
  double _slippage = 0.5;

  @override
  void initState() {
    super.initState();
    _recalculateReceive();
  }

  @override
  void dispose() {
    _payAmountController.dispose();
    _receiveAmountController.dispose();
    super.dispose();
  }

  void _recalculateReceive() {
    final double? pay = double.tryParse(_payAmountController.text);
    if (pay == null || pay <= 0) {
      _receiveAmountController.text = '0.00';
      return;
    }

    if (_payToken == 'USDT' && _receiveToken == 'JWC') {
      final double jwc = pay / _currentPrice;
      _receiveAmountController.text = jwc.toStringAsFixed(2);
    } else if (_payToken == 'JWC' && _receiveToken == 'USDT') {
      final double usdt = pay * _currentPrice;
      _receiveAmountController.text = usdt.toStringAsFixed(2);
    } else if (_payToken == 'WBNB' && _receiveToken == 'JWC') {
      // 1 WBNB = _wbnbPrice USDT -> (pay * _wbnbPrice) / _currentPrice JWC
      final double jwc = (pay * _wbnbPrice) / _currentPrice;
      _receiveAmountController.text = jwc.toStringAsFixed(2);
    } else if (_payToken == 'JWC' && _receiveToken == 'WBNB') {
      // 1 JWC = _currentPrice USDT -> (pay * _currentPrice) / _wbnbPrice WBNB
      final double wbnb = (pay * _currentPrice) / _wbnbPrice;
      _receiveAmountController.text = wbnb.toStringAsFixed(4);
    } else if (_payToken == 'USDT' && _receiveToken == 'WBNB') {
      final double wbnb = pay / _wbnbPrice;
      _receiveAmountController.text = wbnb.toStringAsFixed(4);
    } else if (_payToken == 'WBNB' && _receiveToken == 'USDT') {
      final double usdt = pay * _wbnbPrice;
      _receiveAmountController.text = usdt.toStringAsFixed(2);
    } else {
      _receiveAmountController.text = (pay * 0.98).toStringAsFixed(2);
    }
  }

  void _switchTokens() {
    setState(() {
      final temp = _payToken;
      _payToken = _receiveToken;
      _receiveToken = temp;
      _recalculateReceive();
    });
  }

  void _showTokenSelector(bool isPay) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCharcoal,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppTheme.goldPrimary.withAlpha(70)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPay ? 'Select Spend Token' : 'Select Receive Token',
              style: const TextStyle(
                color: AppTheme.goldChampagne,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...['USDT', 'WBNB', 'JWC'].map((token) {
              final isCurrent = isPay ? _payToken == token : _receiveToken == token;
              String balanceStr = '';
              if (token == 'USDT') balanceStr = '${widget.usdtBalance.toStringAsFixed(2)} USDT';
              if (token == 'WBNB') balanceStr = '${widget.wbnbBalance.toStringAsFixed(4)} WBNB';
              if (token == 'JWC') balanceStr = '${widget.jwcBalance.toStringAsFixed(2)} JWC';

              return ListTile(
                onTap: () {
                  Navigator.of(ctx).pop();
                  setState(() {
                    if (isPay) {
                      if (_receiveToken == token) {
                        _receiveToken = _payToken;
                      }
                      _payToken = token;
                    } else {
                      if (_payToken == token) {
                        _payToken = _receiveToken;
                      }
                      _receiveToken = token;
                    }
                    _recalculateReceive();
                  });
                },
                leading: CircleAvatar(
                  backgroundColor: isCurrent ? AppTheme.goldPrimary : AppTheme.surfaceElevated,
                  child: Text(
                    token.substring(0, 1),
                    style: TextStyle(
                      color: isCurrent ? AppTheme.obsidian : AppTheme.goldChampagne,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  token,
                  style: const TextStyle(color: AppTheme.textLight, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('In-App Balance: $balanceStr', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                trailing: isCurrent ? const Icon(Icons.check_circle_rounded, color: AppTheme.emeraldPositive) : null,
              );
            }),
          ],
        ),
      ),
    );
  }

  void _setPercentage(double percent) {
    double totalAvailable = 0;
    if (_payToken == 'USDT') totalAvailable = widget.usdtBalance;
    if (_payToken == 'JWC') totalAvailable = widget.jwcBalance;
    if (_payToken == 'WBNB') totalAvailable = widget.wbnbBalance;

    final amount = totalAvailable * percent;
    _payAmountController.text = _payToken == 'WBNB' ? amount.toStringAsFixed(4) : amount.toStringAsFixed(2);
    _recalculateReceive();
    setState(() {});
  }

  void _showInsufficientFundsPrompt(double payAmount, double receiveAmount) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCharcoal,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppTheme.goldPrimary.withAlpha(80)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('🥞', style: TextStyle(fontSize: 22)),
                SizedBox(width: 8),
                Text(
                  'Fund Wallet to Swap',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppTheme.goldChampagne,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Your in-app $_payToken balance is insufficient ($payAmount $_payToken required). Deposit $_payToken to the official receiving wallet or buy directly on PancakeSwap DEX.',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLowest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Your $_payToken Balance:', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      Text(
                        _payToken == 'USDT'
                            ? '${widget.usdtBalance.toStringAsFixed(2)} USDT'
                            : (_payToken == 'WBNB'
                                ? '${widget.wbnbBalance.toStringAsFixed(4)} WBNB'
                                : '${widget.jwcBalance.toStringAsFixed(2)} JWC'),
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          color: AppTheme.goldPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('JWC Rate:', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      Text(
                        '1 JWC = \$${_currentPrice.toStringAsFixed(2)} USDT',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          color: AppTheme.goldChampagne,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  final url = _payToken == 'WBNB' || _receiveToken == 'WBNB'
                      ? AppConfig.instance.pancakeSwapBuyWithWbnbUrl
                      : AppConfig.instance.pancakeSwapBuyUrl;
                  openExternalUrl(url);
                },
                icon: const Text('🥞', style: TextStyle(fontSize: 16)),
                label: const Text(
                  'OPEN PANCAKESWAP DEX',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldPrimary,
                  foregroundColor: AppTheme.obsidian,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  widget.onOpenDeposit?.call();
                },
                icon: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.goldPrimary, size: 16),
                label: Text(
                  'DEPOSIT $_payToken TO RECEIVING WALLET',
                  style: const TextStyle(color: AppTheme.goldPrimary, fontWeight: FontWeight.bold, fontSize: 11),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.goldPrimary.withAlpha(90)),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _executeSwap() {
    final double? pay = double.tryParse(_payAmountController.text);
    final double? receive = double.tryParse(_receiveAmountController.text);

    if (pay == null || pay <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid swap amount'),
          backgroundColor: AppTheme.crimsonNegative,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    // Check balance and execute
    if (_payToken == 'USDT') {
      if (pay > widget.usdtBalance) {
        _showInsufficientFundsPrompt(pay, receive ?? (pay / _currentPrice));
        return;
      }
      if (_receiveToken == 'JWC') {
        widget.onSwapComplete(receive ?? 0, -pay, 0);
      } else if (_receiveToken == 'WBNB') {
        widget.onSwapComplete(0, -pay, receive ?? 0);
      }
    } else if (_payToken == 'WBNB') {
      if (pay > widget.wbnbBalance) {
        _showInsufficientFundsPrompt(pay, receive ?? ((pay * _wbnbPrice) / _currentPrice));
        return;
      }
      if (_receiveToken == 'JWC') {
        widget.onSwapComplete(receive ?? 0, 0, -pay);
      } else if (_receiveToken == 'USDT') {
        widget.onSwapComplete(0, receive ?? 0, -pay);
      }
    } else if (_payToken == 'JWC') {
      if (pay > widget.jwcBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient JWC Balance to Swap'),
            backgroundColor: AppTheme.crimsonNegative,
          ),
        );
        return;
      }
      if (_receiveToken == 'USDT') {
        widget.onSwapComplete(-pay, receive ?? 0, 0);
      } else if (_receiveToken == 'WBNB') {
        widget.onSwapComplete(-pay, 0, receive ?? 0);
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.goldPrimary, width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.goldPrimary, size: 26),
            SizedBox(width: 8),
            Text(
              'Swap Executed!',
              style: TextStyle(color: AppTheme.goldChampagne, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Swapped $pay $_payToken for ${receive?.toStringAsFixed(2)} $_receiveToken via PancakeSwap V3 Atomic Router.',
          style: const TextStyle(color: AppTheme.textLight, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openExternalUrl(AppConfig.instance.bscScanUrl);
            },
            child: const Text('BSCSCAN', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final url = _payToken == 'JWC'
                  ? AppConfig.instance.pancakeSwapSellUrl
                  : AppConfig.instance.pancakeSwapBuyUrl;
              openExternalUrl(url);
            },
            child: const Text(
              'PANCAKESWAP',
              style: TextStyle(color: AppTheme.goldPrimary, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldPrimary,
              foregroundColor: AppTheme.obsidian,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
            child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BSC Block Telemetry Strip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.goldAmber,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.goldAmber,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'BSC BLOCK #38,419,204',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: AppTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.speed_rounded, color: AppTheme.goldAmber, size: 12),
                      SizedBox(width: 4),
                      Text(
                        '3.0s Finality',
                        style: TextStyle(
                          color: AppTheme.goldAmber,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Live Chart & Price Terminal Card
            _buildPriceChartCard(),
            const SizedBox(height: 14),

            // VIP AI Trading Signals
            _buildAiSignalsCard(),
            const SizedBox(height: 14),

            // Instant Swap Glass Card
            _buildSwapCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceChartCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.luxuryCardDecoration(glowing: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Currency Pair & Quick Switches
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.goldGradient,
                    ),
                    child: const Center(
                      child: Icon(Icons.stars_rounded, size: 18, color: AppTheme.obsidian),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedPair,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: AppTheme.textLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              // Pair Selector Pills
              Row(
                children: _pairs.map((pair) {
                  final isSel = pair == _selectedPair;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPair = pair;
                        if (pair == 'JWC / USDT') {
                          _payToken = 'USDT';
                          _receiveToken = 'JWC';
                        } else if (pair == 'JWC / WBNB') {
                          _payToken = 'WBNB';
                          _receiveToken = 'JWC';
                        } else if (pair == 'WBNB / USDT') {
                          _payToken = 'USDT';
                          _receiveToken = 'WBNB';
                        }
                        _recalculateReceive();
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSel ? AppTheme.goldPrimary : AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        pair.replaceAll('JWC / ', ''),
                        style: TextStyle(
                          color: isSel ? AppTheme.obsidian : AppTheme.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Price and 24h Vol
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$${_currentPrice.toStringAsFixed(4)}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: AppTheme.goldPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up_rounded, color: AppTheme.emeraldPositive, size: 13),
                    const SizedBox(width: 3),
                    Text(
                      '+${AppConfig.instance.priceChange24h.toStringAsFixed(2)}%',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        color: AppTheme.emeraldPositive,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '24H VOL',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppTheme.textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    '\$4.82M',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      color: AppTheme.textLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Timeframes & Moving Averages
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: _timeframes.map((tf) {
                  final isSel = tf == _selectedTimeframe;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTimeframe = tf),
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSel ? AppTheme.goldPrimary : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tf,
                        style: TextStyle(
                          color: isSel ? AppTheme.obsidian : AppTheme.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Row(
                children: [
                  Text(
                    'MA7: ',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
                  ),
                  Text(
                    '\$2.814  ',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      color: AppTheme.goldPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'MA25: ',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
                  ),
                  Text(
                    '\$2.698',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      color: AppTheme.goldAmber,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Custom Candlestick Wave Chart Visual
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.surfaceLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withAlpha(12),
                width: 0.8,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomPaint(
                painter: _CandleChartPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSignalsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.luxuryCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.psychology_rounded, color: AppTheme.goldPrimary, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'VIP AI Trading Signals',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppTheme.textLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.goldPrimary.withAlpha(60)),
                ),
                child: const Text(
                  'NEURAL v4.2',
                  style: TextStyle(
                    color: AppTheme.goldPrimary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Signal Gauge
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLowest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'OVERALL SIGNAL METER',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      'STRONG BUY (92%)',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        color: AppTheme.goldPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.92,
                    backgroundColor: AppTheme.surfaceElevated,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.goldPrimary),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Technical Indicators Grid
          Row(
            children: [
              Expanded(
                child: _indicatorTile('RSI (14)', '61.4', 'Bullish', AppTheme.emeraldPositive),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _indicatorTile('MACD', 'Golden', 'Active', AppTheme.goldPrimary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _indicatorTile('SuperTrend', '\$2.710', 'Support', AppTheme.goldAmber),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Action Apply Button
          GestureDetector(
            onTap: () {
              _payToken = 'USDT';
              _receiveToken = 'JWC';
              _payAmountController.text = '1000.00';
              _recalculateReceive();
              HapticFeedback.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Applied Long Breakout Signal to Instant Swap'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.goldPrimary.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.goldPrimary.withAlpha(80)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome_rounded, color: AppTheme.goldPrimary, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'APPLY SIGNAL TO INSTANT SWAP',
                    style: TextStyle(
                      color: AppTheme.goldPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _indicatorTile(String title, String val, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 9),
          ),
          const SizedBox(height: 2),
          Text(
            val,
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              color: AppTheme.textLight,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwapCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.luxuryCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // PancakeSwap DEX Direct Gateway Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLowest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.goldPrimary.withAlpha(50)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🥞', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PancakeSwap V3 DEX Pool',
                          style: TextStyle(
                            color: AppTheme.goldChampagne,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Target: \$${_currentPrice.toStringAsFixed(2)} USDT',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => openExternalUrl(AppConfig.instance.pancakeSwapBuyUrl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.goldPrimary,
                    foregroundColor: AppTheme.obsidian,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text(
                    'BUY ON DEX',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ),

          // Swap Mode Tabs
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLowest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isInstantSwap = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _isInstantSwap ? AppTheme.surfaceElevated : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Instant Swap',
                          style: TextStyle(
                            color: _isInstantSwap ? AppTheme.goldPrimary : AppTheme.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isInstantSwap = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !_isInstantSwap ? AppTheme.surfaceElevated : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Limit Order',
                          style: TextStyle(
                            color: !_isInstantSwap ? AppTheme.goldPrimary : AppTheme.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // YOU PAY SECTION
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha(15)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'YOU PAY',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      'Bal: ${_payToken == "USDT" ? widget.usdtBalance.toStringAsFixed(2) : (_payToken == "WBNB" ? widget.wbnbBalance.toStringAsFixed(4) : widget.jwcBalance.toStringAsFixed(2))} $_payToken',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        color: AppTheme.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _payAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          color: AppTheme.textLight,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0.00',
                          hintStyle: TextStyle(color: AppTheme.textMuted),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (_) => _recalculateReceive(),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showTokenSelector(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.goldPrimary.withAlpha(50)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _payToken,
                              style: const TextStyle(
                                color: AppTheme.goldPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.goldPrimary, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Percentage Quick Selectors
                Row(
                  children: [0.25, 0.50, 0.75, 1.0].map((pct) {
                    final label = pct == 1.0 ? 'MAX' : '${(pct * 100).toInt()}%';
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _setPercentage(pct),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Invert Switcher Button
          Center(
            child: GestureDetector(
              onTap: _switchTokens,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.goldPrimary.withAlpha(80)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.goldPrimary.withAlpha(40),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.swap_vert_rounded,
                  color: AppTheme.goldPrimary,
                  size: 20,
                ),
              ),
            ),
          ),

          // YOU RECEIVE SECTION
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha(15)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'YOU RECEIVE (ESTIMATED)',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      '1 JWC = \$${_currentPrice.toStringAsFixed(4)}',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        color: AppTheme.goldAmber,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _receiveAmountController.text,
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          color: AppTheme.goldChampagne,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showTokenSelector(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.goldPrimary.withAlpha(50)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _receiveToken,
                              style: const TextStyle(
                                color: AppTheme.goldPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.goldPrimary, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Slippage and Route Breakdown
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'DEX Route',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        final url = _payToken == 'JWC'
                            ? AppConfig.instance.pancakeSwapSellUrl
                            : AppConfig.instance.pancakeSwapBuyUrl;
                        openExternalUrl(url);
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'PancakeSwap V3 (0.05%)',
                            style: TextStyle(
                              color: AppTheme.goldPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.open_in_new_rounded, color: AppTheme.goldPrimary, size: 12),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Slippage Tolerance',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    ),
                    Row(
                      children: [0.1, 0.5, 1.0].map((s) {
                        final isSel = s == _slippage;
                        return GestureDetector(
                          onTap: () => setState(() => _slippage = s),
                          child: Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSel ? AppTheme.goldPrimary : AppTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '$s%',
                              style: TextStyle(
                                color: isSel ? AppTheme.obsidian : AppTheme.textMuted,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Divider(height: 1, color: Colors.white10),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'BEP-20 Contract',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: AppConfig.instance.contractAddress));
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: AppTheme.surfaceElevated,
                                content: Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: AppTheme.emeraldPositive, size: 16),
                                    SizedBox(width: 8),
                                    Text(
                                      'Contract copied: 0xfEEE...9e99',
                                      style: TextStyle(color: AppTheme.goldChampagne, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppConfig.instance.shortContractAddress,
                                style: const TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  color: AppTheme.goldChampagne,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.copy_rounded, color: AppTheme.goldAmber, size: 11),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            openExternalUrl(AppConfig.instance.bscScanUrl);
                          },
                          child: const Icon(Icons.travel_explore_rounded, color: AppTheme.goldPrimary, size: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Execute Swap Button
          ElevatedButton(
            onPressed: _executeSwap,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppTheme.goldPrimary,
              foregroundColor: AppTheme.obsidian,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              shadowColor: AppTheme.goldPrimary.withAlpha(120),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bolt_rounded, size: 20, color: AppTheme.obsidian),
                SizedBox(width: 6),
                Text(
                  'EXECUTE INSTANT SWAP',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Direct PancakeSwap External Swap Button
          OutlinedButton.icon(
            onPressed: () {
              final url = _payToken == 'BNB'
                  ? AppConfig.instance.pancakeSwapBuyWithBnbUrl
                  : AppConfig.instance.pancakeSwapBuyUrl;
              openExternalUrl(url);
            },
            icon: const Text('🥞', style: TextStyle(fontSize: 16)),
            label: const Text(
              'BUY JWC ON PANCAKESWAP DEX',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.goldPrimary,
                letterSpacing: 0.5,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.goldPrimary.withAlpha(140)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

// Candlestick Wave Painter for Smooth Visuals
class _CandleChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0x15FFFFFF)
      ..strokeWidth = 0.5;

    // Horizontal grid
    canvas.drawLine(Offset(0, size.height * 0.33), Offset(size.width, size.height * 0.33), gridPaint);
    canvas.drawLine(Offset(0, size.height * 0.66), Offset(size.width, size.height * 0.66), gridPaint);

    final linePaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppTheme.goldAmber, AppTheme.goldPrimary, AppTheme.goldChampagne],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.goldPrimary.withAlpha(60),
          AppTheme.goldPrimary.withAlpha(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.75);
    path.cubicTo(
      size.width * 0.25, size.height * 0.65,
      size.width * 0.45, size.height * 0.85,
      size.width * 0.65, size.height * 0.40,
    );
    path.cubicTo(
      size.width * 0.80, size.height * 0.15,
      size.width * 0.90, size.height * 0.25,
      size.width, size.height * 0.08,
    );

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // End pulse dot
    final dotPaint = Paint()..color = AppTheme.goldChampagne;
    canvas.drawCircle(Offset(size.width - 2, size.height * 0.08), 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
