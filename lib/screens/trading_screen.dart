import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class TradingScreen extends StatefulWidget {
  final double jwcBalance;
  final Function(double deltaJwc, double deltaUsdt) onSwapComplete;

  const TradingScreen({
    super.key,
    required this.jwcBalance,
    required this.onSwapComplete,
  });

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  String _selectedPair = 'JWC / USDT';
  final List<String> _pairs = ['JWC / USDT', 'JWC / BNB', 'WBNB', 'BTCB'];

  String _selectedTimeframe = '1H';
  final List<String> _timeframes = ['15m', '1H', '4H', '1D', '1W'];

  bool _isInstantSwap = true;
  String _payToken = 'USDT';
  String _receiveToken = 'JWC';
  double _usdtBalance = 4500.0;
  final double _bnbBalance = 14.85;

  final TextEditingController _payAmountController = TextEditingController(text: '500.00');
  final TextEditingController _receiveAmountController = TextEditingController(text: '175.74');

  final double _currentPrice = 2.8450; // 1 JWC = 2.8450 USDT
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
    } else if (_payToken == 'BNB' && _receiveToken == 'JWC') {
      // 1 BNB ~ 600 USDT -> 600 / 2.845 ~ 210.89 JWC
      final double jwc = (pay * 600) / _currentPrice;
      _receiveAmountController.text = jwc.toStringAsFixed(2);
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

  void _setPercentage(double percent) {
    double totalAvailable = 0;
    if (_payToken == 'USDT') totalAvailable = _usdtBalance;
    if (_payToken == 'JWC') totalAvailable = widget.jwcBalance;
    if (_payToken == 'BNB') totalAvailable = _bnbBalance;

    final amount = totalAvailable * percent;
    _payAmountController.text = amount.toStringAsFixed(2);
    _recalculateReceive();
    setState(() {});
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

    if (_payToken == 'USDT' && _receiveToken == 'JWC') {
      if (pay > _usdtBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient USDT Balance'),
            backgroundColor: AppTheme.crimsonNegative,
          ),
        );
        return;
      }
      _usdtBalance -= pay;
      widget.onSwapComplete(receive ?? 0, -pay);
    } else if (_payToken == 'JWC' && _receiveToken == 'USDT') {
      if (pay > widget.jwcBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient JWC Balance'),
            backgroundColor: AppTheme.crimsonNegative,
          ),
        );
        return;
      }
      _usdtBalance += receive ?? 0;
      widget.onSwapComplete(-pay, receive ?? 0);
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
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'PROCEED',
              style: TextStyle(color: AppTheme.goldPrimary, fontWeight: FontWeight.bold),
            ),
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
                      setState(() => _selectedPair = pair);
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
                child: const Row(
                  children: [
                    Icon(Icons.trending_up_rounded, color: AppTheme.emeraldPositive, size: 13),
                    SizedBox(width: 3),
                    Text(
                      '+18.42%',
                      style: TextStyle(
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
                      'Bal: ${_payToken == "USDT" ? _usdtBalance.toStringAsFixed(2) : widget.jwcBalance.toStringAsFixed(2)} $_payToken',
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.goldPrimary.withAlpha(50)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _payToken,
                            style: const TextStyle(
                              color: AppTheme.goldPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.goldPrimary.withAlpha(50)),
                      ),
                      child: Text(
                        _receiveToken,
                        style: const TextStyle(
                          color: AppTheme.goldPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
                    const Text(
                      'PancakeSwap V3 (0.05%)',
                      style: TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
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
