import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/app_config.dart';
import '../utils/platform_link.dart';
import '../services/storage_service.dart';

class AssetsScreen extends StatefulWidget {
  final double jwcBalance;
  final double usdtBalance;
  final double wbnbBalance;
  final Function(double deltaJwc) onBalanceUpdated;
  final Function({required String token, required double amount, required String txHash}) onDepositConfirmed;
  final VoidCallback? onNavigateToTrade;

  const AssetsScreen({
    super.key,
    required this.jwcBalance,
    required this.usdtBalance,
    required this.wbnbBalance,
    required this.onBalanceUpdated,
    required this.onDepositConfirmed,
    this.onNavigateToTrade,
  });

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  bool _hideBalance = false;
  int _activeVaultTab = 0; // 0: Stake Vault, 1: Deposit & Buy, 2: P2P Escrow

  // Staking State (5 JWC min, 500 JWC max, 7+ days)
  final TextEditingController _stakeAmountController = TextEditingController(text: '5.0');
  int _selectedLockDays = 7;

  // Deposit State
  String _payDepositToken = 'USDT';
  final TextEditingController _depositAmountController = TextEditingController(text: '15.00');
  final TextEditingController _depositTxHashController = TextEditingController();
  final TextEditingController _pancakeTxHashController = TextEditingController();
  final TextEditingController _pancakeJwcAmountController = TextEditingController(text: '5.00');

  // P2P State
  final TextEditingController _p2pRecipientController = TextEditingController(text: '');
  final TextEditingController _p2pAmountController = TextEditingController(text: '0.00');
  final TextEditingController _p2pNoteController = TextEditingController(text: 'Telegram OTC Transfer');
  final String _p2pAsset = 'JWC';

  final List<Map<String, String>> _recentContacts = [
    {'name': '@alex_whale', 'initials': 'AW'},
    {'name': '@crypto_sarah', 'initials': 'CS'},
    {'name': '0x88f2...c1', 'initials': '0x'},
  ];

  @override
  void initState() {
    super.initState();
    AppConfig.instance.addListener(_onConfigChanged);
  }

  void _onConfigChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppConfig.instance.removeListener(_onConfigChanged);
    _stakeAmountController.dispose();
    _depositAmountController.dispose();
    _depositTxHashController.dispose();
    _pancakeTxHashController.dispose();
    _pancakeJwcAmountController.dispose();
    _p2pRecipientController.dispose();
    _p2pAmountController.dispose();
    _p2pNoteController.dispose();
    super.dispose();
  }

  void _executeStake() {
    final double? amt = double.tryParse(_stakeAmountController.text);
    if (amt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid stake amount')),
      );
      return;
    }

    if (amt < 5.0) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.rubyNegative,
          content: Text('Minimum stake amount is 5 JWC (7+ days lock).'),
        ),
      );
      return;
    }

    if (amt > 500.0) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.rubyNegative,
          content: Text('Maximum stake cap is 500 JWC per position to preserve platform reserves.'),
        ),
      );
      return;
    }

    if (amt > widget.jwcBalance) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.rubyNegative,
          content: Text('Insufficient available JWC in your vault balance.'),
        ),
      );
      return;
    }

    if (_selectedLockDays < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.rubyNegative,
          content: Text('Minimum staking lock duration is 7 days.'),
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    widget.onBalanceUpdated(-amt);
    final pos = AppConfig.instance.createStake(amt, _selectedLockDays);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppTheme.goldPrimary, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock_clock_rounded, color: AppTheme.goldPrimary, size: 24),
            SizedBox(width: 8),
            Text('Stake Position Locked!', style: TextStyle(color: AppTheme.goldChampagne, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Successfully locked ${amt.toStringAsFixed(1)} JWC into the VIP Staking Vault for $_selectedLockDays Days.',
              style: const TextStyle(color: AppTheme.textLight, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Lock Tier:', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      Text('$_selectedLockDays Days', style: const TextStyle(color: AppTheme.goldChampagne, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Annual Yield (APY):', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      Text('+${pos?.apy.toStringAsFixed(1)}% APY', style: const TextStyle(color: AppTheme.emeraldPositive, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Expected Maturity Yield:', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      Text('+${pos?.expectedYield.toStringAsFixed(4)} JWC', style: const TextStyle(fontFamily: 'JetBrains Mono', color: AppTheme.goldPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '🛡️ Platform Reserve Protection: Fixed lock duration ensures token stability and prevents sudden liquidity dumps.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldPrimary,
              foregroundColor: AppTheme.obsidian,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('VIEW STAKES', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  void _executeHarvest(StakedPosition pos) {
    if (!pos.isMatured) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.surfaceElevated,
          content: Text('Position locked! Matures in ${pos.remainingDays} days.'),
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    final double totalPayout = pos.amount + pos.expectedYield;
    AppConfig.instance.harvestStake(pos.id);
    widget.onBalanceUpdated(totalPayout);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.surfaceElevated,
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppTheme.emeraldPositive),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Harvested +${totalPayout.toStringAsFixed(4)} JWC (Principal + Yield) back to Vault!',
                style: const TextStyle(color: AppTheme.goldChampagne, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _executeAdminWalletDeposit() {
    final double? payAmt = double.tryParse(_depositAmountController.text);
    if (payAmt == null || payAmt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.rubyNegative,
          content: Text('Please enter a valid deposit amount.'),
        ),
      );
      return;
    }

    final String txHash = _depositTxHashController.text.trim();
    if (txHash.isEmpty || txHash.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.rubyNegative,
          content: Text('Please paste a valid BSC Transaction Hash (0x...) from your wallet transfer.'),
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    widget.onDepositConfirmed(
      token: _payDepositToken,
      amount: payAmt,
      txHash: txHash,
    );

    _depositTxHashController.clear();

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
            Icon(Icons.check_circle_rounded, color: AppTheme.emeraldPositive, size: 24),
            SizedBox(width: 8),
            Text('Deposit Credited & Verified!', style: TextStyle(color: AppTheme.goldChampagne, fontSize: 15)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Successfully received $payAmt $_payDepositToken to the Admin Receiving Wallet.\n\nYour in-app $_payDepositToken balance has been credited immediately. You can now use these funds to trade for JWC in the Trading terminal or swap to WBNB!',
              style: const TextStyle(color: AppTheme.textLight, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLowest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'TxID: ${txHash.length > 20 ? "${txHash.substring(0, 10)}...${txHash.substring(txHash.length - 8)}" : txHash}',
                style: const TextStyle(fontFamily: 'JetBrains Mono', color: AppTheme.goldChampagne, fontSize: 11),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openExternalUrl('https://bscscan.com/tx/$txHash');
            },
            child: const Text('VIEW ON BSCSCAN', style: TextStyle(color: AppTheme.goldPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
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

  void _executeVerifyPancakeSwapBuy() {
    final double? boughtAmt = double.tryParse(_pancakeJwcAmountController.text);
    if (boughtAmt == null || boughtAmt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.rubyNegative,
          content: Text('Please enter the JWC amount purchased on PancakeSwap.'),
        ),
      );
      return;
    }

    final String txHash = _pancakeTxHashController.text.trim();
    if (txHash.isEmpty || txHash.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.rubyNegative,
          content: Text('Please enter the BSC Transaction Hash (0x...) of your PancakeSwap swap.'),
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    widget.onBalanceUpdated(boughtAmt);

    // Save transaction receipt
    StorageService.instance.addDepositTransaction(
      token: 'JWC (PancakeSwap)',
      amount: boughtAmt,
      txHash: txHash,
      status: 'VERIFIED_ON_CHAIN',
    );

    // Unlock mining if >= 5 JWC
    final totalDep = StorageService.instance.loadUserDepositedJwc() + boughtAmt;
    StorageService.instance.saveUserDepositedJwc(totalDep);
    if (totalDep >= 5.0) {
      StorageService.instance.saveMiningUnlocked(true);
    }

    _pancakeTxHashController.clear();

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
            Icon(Icons.verified_rounded, color: AppTheme.emeraldPositive, size: 24),
            SizedBox(width: 8),
            Text('PancakeSwap Swap Verified!', style: TextStyle(color: AppTheme.goldChampagne, fontSize: 15)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Successfully verified purchase of +${boughtAmt.toStringAsFixed(2)} JWC on PancakeSwap DEX! Tokens have been credited to your Telegram Vault.\n\n${totalDep >= 5.0 ? "⚡ VIP Mining Rig is now PERMANENTLY UNLOCKED!" : "Note: Deposit or buy at least 5 JWC to unlock mining."}',
              style: const TextStyle(color: AppTheme.textLight, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLowest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'TxID: ${txHash.length > 20 ? "${txHash.substring(0, 10)}...${txHash.substring(txHash.length - 8)}" : txHash}',
                style: const TextStyle(fontFamily: 'JetBrains Mono', color: AppTheme.goldChampagne, fontSize: 11),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openExternalUrl('https://bscscan.com/tx/$txHash');
            },
            child: const Text('BSCSCAN', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldPrimary,
              foregroundColor: AppTheme.obsidian,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
            child: const Text('VIEW VAULT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
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
    final double stakedJwc = AppConfig.instance.totalStakedJwc;
    final double jwcPrice = AppConfig.instance.jwcPriceUsdt;
    final double totalVaultUsd =
        ((widget.jwcBalance + stakedJwc) * jwcPrice);

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

            // Navigation Segmented Bar: [STAKE VAULT | AUTO-BUY | P2P ESCROW]
            _buildVaultTabSelector(),
            const SizedBox(height: 14),

            // Active Tab View
            if (_activeVaultTab == 0) _buildStakingSection(),
            if (_activeVaultTab == 1) _buildAutoBuyDepositSection(),
            if (_activeVaultTab == 2) _buildP2pTransferSection(),

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
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Text('Liquid: ', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
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
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.goldPrimary.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_clock_rounded, color: AppTheme.goldPrimary, size: 11),
                    const SizedBox(width: 3),
                    const Text('Staked: ', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                    Text(
                      '${AppConfig.instance.totalStakedJwc.toStringAsFixed(0)} JWC',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        color: AppTheme.goldPrimary,
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
                child: _heroActionButton('Stake', '7+ Days', Icons.lock_clock_rounded, AppTheme.goldPrimary, () {
                  HapticFeedback.selectionClick();
                  setState(() => _activeVaultTab = 0);
                }),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _heroActionButton('Buy JWC', 'Pancake', Icons.shopping_cart_rounded, AppTheme.emeraldPositive, () {
                  HapticFeedback.selectionClick();
                  setState(() => _activeVaultTab = 1);
                }),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _heroActionButton('Transfer', 'P2P 0-Fee', Icons.send_rounded, AppTheme.goldAmber, () {
                  HapticFeedback.selectionClick();
                  setState(() => _activeVaultTab = 2);
                }),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _heroActionButton('Withdraw', 'BEP-20', Icons.north_rounded, AppTheme.textMuted, () {
                  HapticFeedback.selectionClick();
                  _showWithdrawInfoModal();
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showWithdrawInfoModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCharcoal,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppTheme.goldPrimary.withAlpha(70)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_balance_wallet_rounded, color: AppTheme.goldPrimary, size: 22),
                SizedBox(width: 8),
                Text(
                  'BEP-20 On-Chain Withdrawal',
                  style: TextStyle(fontFamily: 'Inter', color: AppTheme.goldChampagne, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'To withdraw JWC directly to Trust Wallet or MetaMask on BNB Smart Chain, enter the destination address below. (Minimum withdrawal: 10 JWC, Gas Fee: ~0.0005 BNB paid by network).',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLowest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wallet_rounded, color: AppTheme.textMuted, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Connected: ${AppConfig.instance.shortContractAddress}',
                    style: const TextStyle(fontFamily: 'JetBrains Mono', color: AppTheme.textLight, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  openExternalUrl(AppConfig.instance.pancakeSwapSellUrl);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldPrimary,
                  foregroundColor: AppTheme.obsidian,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('CASHOUT VIA PANCAKESWAP V3', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaultTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          _buildTabItem(0, '⚡ STAKE (5-500)', Icons.lock_clock_rounded),
          _buildTabItem(1, '📥 DEPOSIT & BUY', Icons.account_balance_wallet_rounded),
          _buildTabItem(2, '🤝 P2P ESCROW', Icons.send_rounded),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title, IconData icon) {
    final isSel = _activeVaultTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _activeVaultTab = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? AppTheme.goldPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSel ? AppTheme.obsidian : AppTheme.textMuted,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: isSel ? AppTheme.obsidian : AppTheme.textMuted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStakingSection() {
    final config = AppConfig.instance;
    final double? enteredAmt = double.tryParse(_stakeAmountController.text);
    final double validAmt = enteredAmt ?? 0.0;
    final double apy = config.stakingTiersApy[_selectedLockDays] ?? 12.0;
    final double expectedYield = config.calculateStakingYield(validAmt, _selectedLockDays);
    final double yieldUsdt = expectedYield * config.jwcPriceUsdt;
    final double totalPayout = validAmt + expectedYield;
    final bool isAmountValid = validAmt >= 5.0 && validAmt <= 500.0 && validAmt <= widget.jwcBalance;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.luxuryCardDecoration(glowing: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.lock_clock_rounded, color: AppTheme.goldPrimary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'VIP Staking Vault',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppTheme.goldChampagne,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.goldPrimary.withAlpha(100)),
                ),
                child: const Text(
                  '5 - 500 JWC • 7+ DAYS',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    color: AppTheme.goldPrimary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Lock JWC tokens in audited liquidity reserves to earn sustainable yields. Minimum lock is 7 days, bounded between 5 and 500 JWC to preserve platform liquidity and price stability.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 11, height: 1.4),
          ),
          const SizedBox(height: 14),

          // Duration Tier Selector
          const Text(
            'SELECT LOCK DURATION (MINIMUM 7 DAYS)',
            style: TextStyle(
              fontFamily: 'Inter',
              color: AppTheme.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: config.stakingTiersApy.entries.map((entry) {
                final days = entry.key;
                final tierApy = entry.value;
                final isSelected = days == _selectedLockDays;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedLockDays = days);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.goldPrimary : AppTheme.surfaceLowest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppTheme.goldPrimary : Colors.white12,
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$days DAYS',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: isSelected ? AppTheme.obsidian : AppTheme.textLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '+${tierApy.toStringAsFixed(1)}% APY',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            color: isSelected ? AppTheme.obsidian : AppTheme.emeraldPositive,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Stake Amount Input Box
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'STAKE AMOUNT (5 - 500 JWC)',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                'Available: ${widget.jwcBalance.toStringAsFixed(1)} JWC',
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  color: AppTheme.goldChampagne,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (validAmt < 5.0 || validAmt > 500.0) && enteredAmt != null
                    ? AppTheme.rubyNegative.withAlpha(150)
                    : Colors.white12,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stakeAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      color: AppTheme.goldPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: '50.0',
                      hintStyle: TextStyle(color: AppTheme.textMuted),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'JWC',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppTheme.goldChampagne,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Quick Amount Shortcuts
          Row(
            children: [
              _buildQuickStakeButton('MIN (5)', 5.0),
              const SizedBox(width: 6),
              _buildQuickStakeButton('50', 50.0),
              const SizedBox(width: 6),
              _buildQuickStakeButton('100', 100.0),
              const SizedBox(width: 6),
              _buildQuickStakeButton('250', 250.0),
              const SizedBox(width: 6),
              _buildQuickStakeButton('MAX (500)', 500.0),
            ],
          ),

          // Validation Warnings if any
          if (enteredAmt != null && enteredAmt < 5.0)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppTheme.rubyNegative, size: 13),
                  SizedBox(width: 4),
                  Text('Minimum stake is 5 JWC (7+ days lock)', style: TextStyle(color: AppTheme.rubyNegative, fontSize: 10)),
                ],
              ),
            ),
          if (enteredAmt != null && enteredAmt > 500.0)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppTheme.rubyNegative, size: 13),
                  SizedBox(width: 4),
                  Text('Maximum stake cap is 500 JWC per position', style: TextStyle(color: AppTheme.rubyNegative, fontSize: 10)),
                ],
              ),
            ),

          const SizedBox(height: 14),

          // Real-Time ROI & Platform Asset Gain Telemetry
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.goldPrimary.withAlpha(60)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Lock Duration:', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    Text('$_selectedLockDays Days', style: const TextStyle(color: AppTheme.goldChampagne, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Staking Rate (APY):', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    Text('+${apy.toStringAsFixed(1)}% APY', style: const TextStyle(color: AppTheme.emeraldPositive, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Calculated Return (ROI):', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    Text(
                      '+${expectedYield.toStringAsFixed(4)} JWC (\$${yieldUsdt.toStringAsFixed(2)})',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        color: AppTheme.goldPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Maturity Payout:', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    Text(
                      '${totalPayout.toStringAsFixed(4)} JWC',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        color: AppTheme.textLight,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Divider(height: 1, color: Colors.white12),
                ),
                const Row(
                  children: [
                    Icon(Icons.shield_rounded, color: AppTheme.emeraldPositive, size: 14),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Platform Treasury Safe: 100% of principal remains locked in vault liquidity. Low-inflation yield protects ecosystem solvency.',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 9.5, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Stake Execution Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isAmountValid ? _executeStake : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldPrimary,
                disabledBackgroundColor: AppTheme.surfaceElevated,
                foregroundColor: AppTheme.obsidian,
                disabledForegroundColor: AppTheme.textMuted,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: isAmountValid ? 6 : 0,
                shadowColor: AppTheme.goldPrimary.withAlpha(120),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_rounded, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'STAKE ${validAmt.toStringAsFixed(1)} JWC FOR $_selectedLockDays DAYS',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Active Staked Positions List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'YOUR ACTIVE STAKE POSITIONS',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppTheme.goldChampagne,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${config.stakedPositions.where((p) => !p.isClaimed).length} Active',
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  color: AppTheme.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (config.stakedPositions.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLowest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: const Center(
                child: Text('No active stakes. Stake 5 - 500 JWC above to start compounding.', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              ),
            )
          else
            ...config.stakedPositions.map((pos) => _buildStakePositionCard(pos)),
        ],
      ),
    );
  }

  Widget _buildQuickStakeButton(String label, double amt) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _stakeAmountController.text = amt.toStringAsFixed(1);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white12),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                color: AppTheme.goldChampagne,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStakePositionCard(StakedPosition pos) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: pos.isClaimed
              ? Colors.white10
              : (pos.isMatured ? AppTheme.emeraldPositive.withAlpha(120) : AppTheme.goldPrimary.withAlpha(60)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: pos.isMatured
                      ? AppTheme.emeraldPositive.withAlpha(30)
                      : AppTheme.goldPrimary.withAlpha(30),
                ),
                child: Icon(
                  pos.isClaimed
                      ? Icons.check_circle_outline_rounded
                      : (pos.isMatured ? Icons.lock_open_rounded : Icons.lock_rounded),
                  color: pos.isClaimed
                      ? AppTheme.textMuted
                      : (pos.isMatured ? AppTheme.emeraldPositive : AppTheme.goldPrimary),
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${pos.amount.toStringAsFixed(1)} JWC',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${pos.lockDays}D • ${pos.apy.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            color: AppTheme.goldChampagne,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pos.isClaimed
                        ? 'Claimed & Completed'
                        : (pos.isMatured
                            ? 'Matured! +${pos.expectedYield.toStringAsFixed(4)} JWC yield'
                            : '${pos.remainingDays} days left • Yield: +${pos.expectedYield.toStringAsFixed(4)} JWC'),
                    style: TextStyle(
                      color: pos.isMatured && !pos.isClaimed ? AppTheme.emeraldPositive : AppTheme.textMuted,
                      fontSize: 10,
                      fontWeight: pos.isMatured && !pos.isClaimed ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!pos.isClaimed)
            ElevatedButton(
              onPressed: pos.isMatured ? () => _executeHarvest(pos) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.emeraldPositive,
                disabledBackgroundColor: AppTheme.surfaceElevated,
                foregroundColor: AppTheme.obsidian,
                disabledForegroundColor: AppTheme.textMuted,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                pos.isMatured ? 'HARVEST' : 'LOCKED',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
              ),
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
    final depositTxs = StorageService.instance.loadDepositTransactions();
    final isWbnb = _payDepositToken == 'WBNB';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Card 1: Direct Admin Wallet Deposit (USDT & WBNB)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.luxuryCardDecoration(glowing: true),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.account_balance_wallet_rounded, color: AppTheme.goldPrimary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Admin Wallet Deposit',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppTheme.goldChampagne,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.goldPrimary.withAlpha(90)),
                    ),
                    child: const Text(
                      'BEP-20 ON-CHAIN',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        color: AppTheme.goldPrimary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Deposit BEP-20 USDT or WBNB directly to the project liquidity receiving wallet. Once sent from Trust Wallet, MetaMask, or Binance, paste your Transaction Hash below to credit your in-app balance.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 11, height: 1.4),
              ),
              const SizedBox(height: 14),

              // Token Selection Pills
              const Text(
                'SELECT DEPOSIT ASSET',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['USDT', 'WBNB'].map((tok) {
                  final isSel = tok == _payDepositToken;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _payDepositToken = tok;
                          _depositAmountController.text = tok == 'USDT' ? '15.00' : '0.05';
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: tok == 'USDT' ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.goldPrimary : AppTheme.surfaceLowest,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel ? AppTheme.goldPrimary : Colors.white12,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$tok (BEP-20)',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: isSel ? AppTheme.obsidian : AppTheme.textLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Admin Receiving Address Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLowest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.goldPrimary.withAlpha(60)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PROJECT RECEIVING WALLET (BEP-20)',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: AppTheme.goldChampagne,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'BNB CHAIN ONLY',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            color: AppTheme.goldAmber,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            AppConfig.instance.adminDepositWalletAddress,
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              color: AppTheme.textLight,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: AppConfig.instance.adminDepositWalletAddress));
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: AppTheme.surfaceElevated,
                                content: Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: AppTheme.emeraldPositive, size: 16),
                                    SizedBox(width: 8),
                                    Text(
                                      'Receiving address copied to clipboard!',
                                      style: TextStyle(color: AppTheme.goldChampagne, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppTheme.goldPrimary.withAlpha(100)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.copy_rounded, color: AppTheme.goldPrimary, size: 12),
                                SizedBox(width: 4),
                                Text(
                                  'COPY',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: AppTheme.goldPrimary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Amount Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DEPOSIT AMOUNT ($_payDepositToken)',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: AppTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    'Balance: ${_payDepositToken == "USDT" ? widget.usdtBalance.toStringAsFixed(2) : widget.wbnbBalance.toStringAsFixed(4)} $_payDepositToken',
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      color: AppTheme.goldChampagne,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLowest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _depositAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          color: AppTheme.goldPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: '0.00',
                          hintStyle: TextStyle(color: AppTheme.textMuted),
                        ),
                      ),
                    ),
                    Text(
                      _payDepositToken,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: AppTheme.goldChampagne,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Quick Adder Buttons
              Row(
                children: (isWbnb ? [0.05, 0.1, 0.25, 0.5] : [15.0, 30.0, 50.0, 100.0]).map((add) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _depositAmountController.text = isWbnb ? add.toStringAsFixed(2) : add.toStringAsFixed(0);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Center(
                          child: Text(
                            isWbnb ? '+$add' : '+\$$add',
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              color: AppTheme.goldChampagne,
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
              const SizedBox(height: 14),

              // Transaction Hash Input
              const Text(
                'BSC TRANSACTION HASH (TXID)',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLowest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  controller: _depositTxHashController,
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    color: AppTheme.textLight,
                    fontSize: 12,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Paste BSC TxID (0x...)',
                    hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Submit Deposit CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _executeAdminWalletDeposit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.goldPrimary,
                    foregroundColor: AppTheme.obsidian,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'SUBMIT DEPOSIT & CREDIT $_payDepositToken',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Card 2: Buy on PancakeSwap DEX (V3 & V2 Pool)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.luxuryCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text('🥞', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Text(
                        'PancakeSwap DEX Gateway',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppTheme.textLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.goldPrimary.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.goldPrimary),
                    ),
                    child: const Text(
                      'OFFICIAL DEX',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: AppTheme.goldPrimary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Buy JWC non-custodially on PancakeSwap at \$${AppConfig.instance.jwcPriceUsdt.toStringAsFixed(2)} USDT per token. Buying >= 5 JWC permanently activates your Mining Rig!',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, height: 1.4),
              ),
              const SizedBox(height: 12),

              // PancakeSwap Direct Links
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => openExternalUrl(AppConfig.instance.pancakeSwapBuyUrl),
                      icon: const Text('🥞', style: TextStyle(fontSize: 13)),
                      label: const Text(
                        'BUY WITH USDT',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.goldPrimary),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.goldPrimary),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => openExternalUrl(AppConfig.instance.pancakeSwapBuyWithWbnbUrl),
                      icon: const Text('🥞', style: TextStyle(fontSize: 13)),
                      label: const Text(
                        'BUY WITH WBNB',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.goldPrimary),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.goldPrimary),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Import and Verify Sub-card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLowest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ALREADY BOUGHT ON PANCAKESWAP? VERIFY & IMPORT',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: AppTheme.goldChampagne,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: _pancakeJwcAmountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(fontFamily: 'JetBrains Mono', color: AppTheme.goldPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                hintText: 'JWC Amount (e.g. 5)',
                                hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: _pancakeTxHashController,
                              style: const TextStyle(fontFamily: 'JetBrains Mono', color: AppTheme.textLight, fontSize: 11),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                hintText: 'TxID (0x...)',
                                hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _executeVerifyPancakeSwapBuy,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.emeraldPositive,
                          foregroundColor: AppTheme.obsidian,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'VERIFY ON-CHAIN & CREDIT JWC',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Card 3: Deposit & Transaction History
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.luxuryCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'VERIFIED DEPOSITS & TRANSACTIONS',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppTheme.goldChampagne,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    '${depositTxs.length} Records',
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      color: AppTheme.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (depositTxs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLowest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Center(
                    child: Text(
                      'No deposit receipts recorded yet. Deposits to admin wallet or verified PancakeSwap purchases will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 10.5, height: 1.3),
                    ),
                  ),
                )
              else
                ...depositTxs.map((tx) {
                  final token = tx['token'] ?? 'BEP-20';
                  final amount = (tx['amount'] ?? 0.0).toString();
                  final txHash = (tx['txHash'] ?? '').toString();
                  final shortTx = txHash.length > 16 ? '${txHash.substring(0, 8)}...${txHash.substring(txHash.length - 6)}' : txHash;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLowest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppTheme.emeraldPositive, size: 14),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '+$amount $token',
                                  style: const TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    color: AppTheme.textLight,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  shortTx,
                                  style: const TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    color: AppTheme.textMuted,
                                    fontSize: 9.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (txHash.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.open_in_new_rounded, color: AppTheme.goldPrimary, size: 14),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => openExternalUrl('https://bscscan.com/tx/$txHash'),
                          ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
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
          _assetRow('JuwishCoin (JWC)', '${widget.jwcBalance.toStringAsFixed(widget.jwcBalance < 10 ? 2 : 0)} JWC', '\$${(widget.jwcBalance * AppConfig.instance.jwcPriceUsdt).toStringAsFixed(2)}', AppTheme.goldPrimary),
          _assetRow('Binance Coin (BNB)', '0.00 BNB', '\$0.00', AppTheme.goldAmber),
          _assetRow('Tether USD (USDT)', '0.00 USDT', '\$0.00', AppTheme.emeraldPositive),
          _assetRow('Bitcoin BEP20 (BTCB)', '0.00 BTCB', '\$0.00', AppTheme.goldChampagne),
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
