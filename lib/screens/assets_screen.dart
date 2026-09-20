import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class AssetsScreen extends StatefulWidget {
  final double jwcBalance;
  final Function(double deltaJwc) onBalanceUpdated;

  const AssetsScreen({
    super.key,
    required this.jwcBalance,
    required this.onBalanceUpdated,
  });

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  bool _hideBalance = false;
  String _payDepositToken = 'BNB';
  final TextEditingController _depositAmountController = TextEditingController(text: '2.50');

  // P2P State
  final TextEditingController _p2pRecipientController = TextEditingController(text: '@alex_whale');
  final TextEditingController _p2pAmountController = TextEditingController(text: '1000.00');
  final TextEditingController _p2pNoteController = TextEditingController(text: 'Telegram VIP OTC Deal');
  final String _p2pAsset = 'JWC';

  final List<Map<String, String>> _recentContacts = [
    {'name': '@alex_whale', 'initials': 'AW'},
    {'name': '@crypto_sarah', 'initials': 'CS'},
    {'name': '0x88f2...c1', 'initials': '0x'},
  ];

  @override
  void dispose() {
    _depositAmountController.dispose();
    _p2pRecipientController.dispose();
    _p2pAmountController.dispose();
    _p2pNoteController.dispose();
    super.dispose();
  }

  void _executeAutoBuyDeposit() {
    final double? bnb = double.tryParse(_depositAmountController.text);
    if (bnb == null || bnb <= 0) return;

    HapticFeedback.mediumImpact();
    // 1 BNB ~ 210.89 JWC -> 2.5 BNB ~ 527.2 JWC
    final double addedJwc = bnb * 210.89;
    widget.onBalanceUpdated(addedJwc);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.goldPrimary),
        ),
        title: const Row(
          children: [
            Icon(Icons.bolt_rounded, color: AppTheme.goldPrimary, size: 24),
            SizedBox(width: 8),
            Text('Auto-Buy Staked!', style: TextStyle(color: AppTheme.goldChampagne)),
          ],
        ),
        content: Text(
          'Successfully routed $bnb BNB through PancakeSwap V3 (0.05% Pool). Credited +${addedJwc.toStringAsFixed(2)} JWC to your Staking Vault at 32.5% APY.',
          style: const TextStyle(color: AppTheme.textLight, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('EXCELLENT', style: TextStyle(color: AppTheme.goldPrimary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _executeP2pTransfer() {
    final double? amt = double.tryParse(_p2pAmountController.text);
    final recipient = _p2pRecipientController.text.trim();
    if (amt == null || amt <= 0 || recipient.isEmpty) return;

    if (_p2pAsset == 'JWC' && amt > widget.jwcBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient JWC in Vault'),
          backgroundColor: AppTheme.crimsonNegative,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    if (_p2pAsset == 'JWC') {
      widget.onBalanceUpdated(-amt);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.goldPrimary),
        ),
        title: const Row(
          children: [
            Icon(Icons.send_rounded, color: AppTheme.goldPrimary, size: 24),
            SizedBox(width: 8),
            Text('VIP Transfer Sent', style: TextStyle(color: AppTheme.goldChampagne)),
          ],
        ),
        content: Text(
          'Sent $amt $_p2pAsset to $recipient with Zero Fees via Internal Off-Chain Escrow.\nMemo: ${_p2pNoteController.text}',
          style: const TextStyle(color: AppTheme.textLight, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CONFIRM', style: TextStyle(color: AppTheme.goldPrimary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalVaultUsd = (widget.jwcBalance * 2.8450) + (14.85 * 600) + 4500.0;

    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Total Vault Portfolio Master Card
            _buildVaultHeroCard(totalVaultUsd),
            const SizedBox(height: 14),

            // Direct Auto-Buy Deposit via PancakeSwap V3
            _buildAutoBuyDepositSection(),
            const SizedBox(height: 14),

            // VIP Peer-to-Peer Transfer Section
            _buildP2pTransferSection(),
            const SizedBox(height: 14),

            // Detailed Asset Breakdown
            _buildAssetBreakdownSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildVaultHeroCard(double totalVaultUsd) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.luxuryCardDecoration(glowing: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppTheme.goldPrimary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppTheme.goldPrimary, blurRadius: 6),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'TOTAL VAULT PORTFOLIO',
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
              IconButton(
                icon: Icon(
                  _hideBalance ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppTheme.goldChampagne,
                  size: 18,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() => _hideBalance = !_hideBalance);
                },
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Total USD
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _hideBalance ? '••••••••••' : '\$${totalVaultUsd.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  color: AppTheme.goldPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'USD',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppTheme.goldAmber,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Metric Badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up_rounded, color: AppTheme.emeraldPositive, size: 13),
                    SizedBox(width: 3),
                    Text(
                      '+\$14,892.40 (+3.66%)',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        color: AppTheme.emeraldPositive,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Text('Holding: ', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                    Text(
                      '${widget.jwcBalance.toStringAsFixed(0)} JWC',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        color: AppTheme.goldChampagne,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Quick Action Buttons
          Row(
            children: [
              Expanded(
                child: _heroActionButton('Deposit', 'Auto-Buy', Icons.south_rounded, AppTheme.goldPrimary, () {
                  HapticFeedback.selectionClick();
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _heroActionButton('Withdraw', 'BSC Network', Icons.north_rounded, AppTheme.textMuted, () {
                  HapticFeedback.selectionClick();
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _heroActionButton('Transfer', 'P2P 0-Fee', Icons.send_rounded, AppTheme.goldAmber, () {
                  HapticFeedback.selectionClick();
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroActionButton(String title, String badge, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 3),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoBuyDepositSection() {
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
                  Text('🥞', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 6),
                  Text(
                    'PancakeSwap V3 Gateway',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppTheme.textLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.goldPrimary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '1-CLICK AUTO-BUY',
                  style: TextStyle(
                    color: AppTheme.obsidian,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Pay With Token Pills
          Row(
            children: ['BNB', 'USDT', 'BUSD', 'WBNB'].map((tok) {
              final isSel = tok == _payDepositToken;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _payDepositToken = tok),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? AppTheme.goldPrimary : AppTheme.surfaceLowest,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSel ? AppTheme.goldPrimary : Colors.white.withAlpha(10),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        tok,
                        style: TextStyle(
                          color: isSel ? AppTheme.obsidian : AppTheme.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Deposit Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLowest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withAlpha(15)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _depositAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      color: AppTheme.textLight,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: '0.00',
                    ),
                  ),
                ),
                Text(
                  _payDepositToken,
                  style: const TextStyle(
                    color: AppTheme.goldPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Quick Adder Buttons
          Row(
            children: [0.5, 1.0, 2.5, 5.0].map((add) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    _depositAmountController.text = add.toStringAsFixed(1);
                    setState(() {});
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '+$add',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          color: AppTheme.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Staking Bonus Banner
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLow,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.goldAmber.withAlpha(30)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_clock_rounded, color: AppTheme.goldAmber, size: 14),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Direct Auto-Stake: +32.5% APY starts accumulating instantly.',
                    style: TextStyle(color: AppTheme.goldChampagne, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // CTA Button
          ElevatedButton(
            onPressed: _executeAutoBuyDeposit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: AppTheme.goldPrimary,
              foregroundColor: AppTheme.obsidian,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🥞', style: TextStyle(fontSize: 16)),
                SizedBox(width: 6),
                Text(
                  'INSTANT AUTO-BUY & DEPOSIT',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildP2pTransferSection() {
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
                  Icon(Icons.swap_horiz_rounded, color: AppTheme.goldPrimary, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'VIP Peer-to-Peer Transfer',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppTheme.textLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ZERO-FEE OFF-CHAIN',
                  style: TextStyle(
                    color: AppTheme.emeraldPositive,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Recipient Input
          TextField(
            controller: _p2pRecipientController,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: AppTheme.textLight,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.surfaceLowest,
              hintText: 'Telegram @username or BSC 0x...',
              hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withAlpha(15)),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Recent Contacts
          Row(
            children: _recentContacts.map((c) {
              return GestureDetector(
                onTap: () {
                  _p2pRecipientController.text = c['name']!;
                  setState(() {});
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.goldPrimary.withAlpha(40)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 8,
                        backgroundColor: AppTheme.goldPrimary,
                        child: Text(
                          c['initials']!,
                          style: const TextStyle(color: AppTheme.obsidian, fontSize: 7, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        c['name']!,
                        style: const TextStyle(color: AppTheme.goldChampagne, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Asset & Amount
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _p2pAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    color: AppTheme.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.surfaceLowest,
                    hintText: 'Amount',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white.withAlpha(15)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.goldPrimary.withAlpha(60)),
                ),
                child: Text(
                  _p2pAsset,
                  style: const TextStyle(
                    color: AppTheme.goldPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // CTA Button
          ElevatedButton(
            onPressed: _executeP2pTransfer,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: AppTheme.surfaceElevated,
              foregroundColor: AppTheme.goldPrimary,
              side: const BorderSide(color: AppTheme.goldPrimary, width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_rounded, size: 16, color: AppTheme.goldPrimary),
                SizedBox(width: 6),
                Text(
                  'SEND INSTANTLY (0% FEE)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetBreakdownSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.luxuryCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ASSET ALLOCATION',
            style: TextStyle(
              fontFamily: 'Inter',
              color: AppTheme.goldChampagne,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          _assetRow('JuwishCoin (JWC)', '${widget.jwcBalance.toStringAsFixed(0)} JWC', '\$${(widget.jwcBalance * 2.8450).toStringAsFixed(2)}', AppTheme.goldPrimary),
          _assetRow('Binance Coin (BNB)', '14.85 BNB', '\$8,910.00', AppTheme.goldAmber),
          _assetRow('Tether USD (USDT)', '4,500.00 USDT', '\$4,500.00', AppTheme.emeraldPositive),
          _assetRow('Bitcoin BEP20 (BTCB)', '0.15 BTCB', '\$9,650.00', AppTheme.goldChampagne),
        ],
      ),
    );
  }

  Widget _assetRow(String name, String balance, String usd, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: const TextStyle(color: AppTheme.textLight, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                balance,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  color: AppTheme.textLight,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                usd,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  color: AppTheme.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
