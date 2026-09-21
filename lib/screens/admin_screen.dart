import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/app_config.dart';
import '../utils/platform_link.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final AppConfig _config = AppConfig.instance;

  late double _tapYield;
  late int _maxEnergy;
  late double _jwcPrice;
  late double _stakingApy;
  late double _referralPct;
  late bool _bannerActive;
  late TextEditingController _bannerTextCtrl;

  // Mining Activation Gate State
  late bool _miningGateRequired;
  late double _activationThreshold;
  late bool _miningUnlocked;

  @override
  void initState() {
    super.initState();
    _tapYield = _config.tapYield;
    _maxEnergy = _config.maxEnergy;
    _jwcPrice = _config.jwcPriceUsdt;
    _stakingApy = _config.stakingApy;
    _referralPct = _config.referralCommissionPct;
    _bannerActive = _config.isBannerActive;
    _bannerTextCtrl = TextEditingController(text: _config.broadcastMessage);

    _miningGateRequired = _config.isMiningActivationRequired;
    _activationThreshold = _config.activationThresholdJwc;
    _miningUnlocked = _config.isMiningUnlocked;
  }

  @override
  void dispose() {
    _bannerTextCtrl.dispose();
    super.dispose();
  }

  void _saveSettings() {
    HapticFeedback.heavyImpact();
    _config.updateMiningSettings(
      newTapYield: _tapYield,
      newMaxEnergy: _maxEnergy,
    );
    _config.updateMarketSettings(
      newPrice: _jwcPrice,
      newStakingApy: _stakingApy,
      newReferralPct: _referralPct,
    );
    _config.updateBroadcast(
      active: _bannerActive,
      message: _bannerTextCtrl.text.trim(),
    );
    _config.updateMiningGateSettings(
      required: _miningGateRequired,
      threshold: _activationThreshold,
      unlocked: _miningUnlocked,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppTheme.surfaceElevated,
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.emeraldPositive),
            SizedBox(width: 8),
            Text(
              'Admin settings deployed live to all users!',
              style: TextStyle(color: AppTheme.goldChampagne, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceCharcoal,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_rounded, color: AppTheme.goldPrimary, size: 20),
            SizedBox(width: 8),
            Text(
              'VIP ADMIN COMMAND CENTER',
              style: TextStyle(
                fontFamily: 'Inter',
                color: AppTheme.goldChampagne,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Live System Status Overview
            _buildTelemetryCard(),
            const SizedBox(height: 16),

            // Live Broadcast Banner Engine
            _buildBroadcastSection(),
            const SizedBox(height: 16),

            // Mining Parameter Controls
            _buildMiningControls(),
            const SizedBox(height: 16),

            // Market & Staking Controls
            _buildMarketControls(),
            const SizedBox(height: 24),

            // Save & Deploy Button
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppTheme.goldPrimary,
                foregroundColor: AppTheme.obsidian,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 8,
                shadowColor: AppTheme.goldPrimary.withAlpha(120),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_rounded, color: AppTheme.obsidian, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'DEPLOY CHANGES LIVE',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.luxuryCardDecoration(glowing: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LIVE NETWORK TELEMETRY',
                style: TextStyle(color: AppTheme.goldPrimary, fontSize: 10, fontWeight: FontWeight.w800),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldPositive.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '● MAINNET HEALTHY',
                  style: TextStyle(color: AppTheme.emeraldPositive, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                child: _TelemetryStat('Active Miners', '1,428 Nodes'),
              ),
              Expanded(
                child: _TelemetryStat('Vault TVL', '\$421,756 USD'),
              ),
              Expanded(
                child: _TelemetryStat('Mining Hashrate', '142.8 GH/s'),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Colors.white12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('BEP-20 CONTRACT (BSC)', style: TextStyle(color: AppTheme.textMuted, fontSize: 9)),
                  const SizedBox(height: 2),
                  Text(
                    _config.shortContractAddress,
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      color: AppTheme.goldChampagne,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _config.contractAddress));
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Contract address copied!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 11, color: AppTheme.goldAmber),
                    label: const Text('COPY', style: TextStyle(color: AppTheme.goldAmber, fontSize: 10)),
                  ),
                  TextButton.icon(
                    onPressed: () => openExternalUrl(_config.bscScanUrl),
                    icon: const Icon(Icons.open_in_new_rounded, size: 11, color: AppTheme.goldPrimary),
                    label: const Text('BSCSCAN', style: TextStyle(color: AppTheme.goldPrimary, fontSize: 10)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBroadcastSection() {
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
                  Icon(Icons.campaign_rounded, color: AppTheme.goldAmber, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Global User Broadcast Alert',
                    style: TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Switch(
                value: _bannerActive,
                activeThumbColor: AppTheme.goldPrimary,
                onChanged: (val) => setState(() => _bannerActive = val),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _bannerTextCtrl,
            maxLines: 2,
            style: const TextStyle(color: AppTheme.textLight, fontSize: 12),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.surfaceLowest,
              hintText: 'Enter announcement banner message...',
              contentPadding: const EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withAlpha(15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiningControls() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.luxuryCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stars_rounded, color: AppTheme.goldPrimary, size: 18),
              SizedBox(width: 6),
              Text(
                'Cloud Mining Configuration',
                style: TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tap Reward Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tap Yield Reward', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              Text(
                '+${_tapYield.toStringAsFixed(0)} JWC / tap',
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  color: AppTheme.goldPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: _tapYield,
            min: 5,
            max: 100,
            divisions: 19,
            activeColor: AppTheme.goldPrimary,
            inactiveColor: AppTheme.surfaceLowest,
            onChanged: (val) => setState(() => _tapYield = val),
          ),

          // Max Energy Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Max User Energy Capacity', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              Text(
                '$_maxEnergy Energy',
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  color: AppTheme.goldAmber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: _maxEnergy.toDouble(),
            min: 500,
            max: 5000,
            divisions: 9,
            activeColor: AppTheme.goldAmber,
            inactiveColor: AppTheme.surfaceLowest,
            onChanged: (val) => setState(() => _maxEnergy = val.toInt()),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Colors.white12),
          ),

          // Mining Activation Gate (5 JWC Requirement)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield_rounded, color: AppTheme.goldAmber, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Mining Activation Gate (Anti-Sybil)',
                    style: TextStyle(color: AppTheme.textLight, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Switch(
                value: _miningGateRequired,
                activeThumbColor: AppTheme.goldAmber,
                onChanged: (val) => setState(() => _miningGateRequired = val),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Requires users to buy or deposit JWC before mining & tap rewards unlock.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
          ),
          const SizedBox(height: 10),

          // Activation Threshold Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Deposit/Buy Threshold', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              Text(
                '${_activationThreshold.toStringAsFixed(0)} JWC (\$${(_activationThreshold * _jwcPrice).toStringAsFixed(2)})',
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  color: AppTheme.goldPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: _activationThreshold,
            min: 1.0,
            max: 20.0,
            divisions: 19,
            activeColor: AppTheme.goldAmber,
            inactiveColor: AppTheme.surfaceLowest,
            onChanged: (val) => setState(() => _activationThreshold = val),
          ),

          // Test user override toggle
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLowest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Test Current Account Status', style: TextStyle(color: AppTheme.textLight, fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      _miningUnlocked ? 'UNLOCKED (Able to mine)' : 'LOCKED (Requires deposit)',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        color: _miningUnlocked ? AppTheme.emeraldPositive : AppTheme.rubyNegative,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _miningUnlocked = !_miningUnlocked;
                    });
                  },
                  child: Text(
                    _miningUnlocked ? 'LOCK RIG' : 'UNLOCK RIG',
                    style: TextStyle(
                      color: _miningUnlocked ? AppTheme.rubyNegative : AppTheme.emeraldPositive,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketControls() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.luxuryCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.candlestick_chart_rounded, color: AppTheme.goldPrimary, size: 18),
              SizedBox(width: 6),
              Text(
                'Market & Vault Telemetry',
                style: TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Price Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('JWC Token Price', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              Text(
                '\$${_jwcPrice.toStringAsFixed(4)} USDT',
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  color: AppTheme.goldPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: _jwcPrice,
            min: 0.5,
            max: 10.0,
            divisions: 95,
            activeColor: AppTheme.goldPrimary,
            inactiveColor: AppTheme.surfaceLowest,
            onChanged: (val) => setState(() => _jwcPrice = val),
          ),

          // Staking APY Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Staking Pool Yield (APY)', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              Text(
                '+${_stakingApy.toStringAsFixed(1)}% APY',
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  color: AppTheme.emeraldPositive,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: _stakingApy,
            min: 5.0,
            max: 100.0,
            divisions: 19,
            activeColor: AppTheme.emeraldPositive,
            inactiveColor: AppTheme.surfaceLowest,
            onChanged: (val) => setState(() => _stakingApy = val),
          ),

          // Referral Commission
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Referral Commission', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              Text(
                '${_referralPct.toStringAsFixed(0)}% Dividend',
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  color: AppTheme.goldChampagne,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: _referralPct,
            min: 5.0,
            max: 30.0,
            divisions: 5,
            activeColor: AppTheme.goldChampagne,
            inactiveColor: AppTheme.surfaceLowest,
            onChanged: (val) => setState(() => _referralPct = val),
          ),
        ],
      ),
    );
  }
}

class _TelemetryStat extends StatelessWidget {
  final String label;
  final String value;
  const _TelemetryStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 9)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            color: AppTheme.textLight,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

