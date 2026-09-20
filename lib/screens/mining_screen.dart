import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class MiningScreen extends StatefulWidget {
  final double initialFarmed;
  final Function(double deltaJwc) onYieldClaimed;

  const MiningScreen({
    super.key,
    this.initialFarmed = 42891.4829,
    required this.onYieldClaimed,
  });

  @override
  State<MiningScreen> createState() => _MiningScreenState();
}

class _MiningScreenState extends State<MiningScreen> with SingleTickerProviderStateMixin {
  late double _totalFarmed;
  double _unclaimedYield = 384.19;
  int _currentEnergy = 940;
  final int _maxEnergy = 1000;
  final double _hashrateGhs = 142.8;

  // Particle tap state
  final List<_TapParticle> _particles = [];
  late AnimationController _orbitController;
  Timer? _idleMiningTimer;
  double _coinScale = 1.0;

  @override
  void initState() {
    super.initState();
    _totalFarmed = widget.initialFarmed;
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Idle cloud mining yield generator
    _idleMiningTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (mounted) {
        setState(() {
          _totalFarmed += 0.0034;
          _unclaimedYield += 0.0034;
          if (_currentEnergy < _maxEnergy) {
            _currentEnergy = min(_maxEnergy, _currentEnergy + 1);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _idleMiningTimer?.cancel();
    super.dispose();
  }

  void _onCoinTapped(TapDownDetails details) {
    if (_currentEnergy < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Energy depleted! Wait for recharge or activate Turbo Boost.'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();

    final randomOffset = Offset(
      details.localPosition.dx + (Random().nextDouble() * 20 - 10),
      details.localPosition.dy - 30,
    );

    setState(() {
      _currentEnergy = max(0, _currentEnergy - 2);
      _totalFarmed += 10.0;
      _unclaimedYield += 10.0;
      _coinScale = 0.94;

      _particles.add(
        _TapParticle(
          id: DateTime.now().microsecondsSinceEpoch,
          position: randomOffset,
        ),
      );
    });

    Future.delayed(const Duration(milliseconds: 90), () {
      if (mounted) {
        setState(() => _coinScale = 1.0);
      }
    });
  }

  void _claimYield() {
    if (_unclaimedYield <= 0.5) return;
    HapticFeedback.mediumImpact();
    final claimed = _unclaimedYield;
    setState(() {
      _unclaimedYield = 0.0;
    });
    widget.onYieldClaimed(claimed);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.surfaceElevated,
        content: Row(
          children: [
            const Icon(Icons.stars_rounded, color: AppTheme.goldPrimary),
            const SizedBox(width: 8),
            Text(
              'Claimed +${claimed.toStringAsFixed(2)} JWC to Vault!',
              style: const TextStyle(color: AppTheme.goldChampagne, fontWeight: FontWeight.bold),
            ),
          ],
        ),
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
            // Core Node Status Pill
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.goldPrimary.withAlpha(80)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppTheme.goldPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.goldPrimary,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'BNB SMART CHAIN CORE NODE',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: AppTheme.goldChampagne,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Farmed Balance Telemetry
            Center(
              child: Column(
                children: [
                  const Text(
                    'TOTAL FARMED JWC',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _totalFarmed.toStringAsFixed(4),
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          color: AppTheme.goldPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          shadows: [
                            Shadow(
                              color: Color(0x66FFD700),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'JWC',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppTheme.goldAmber,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Unclaimed Yield Chip & Claim Button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.goldAmber.withAlpha(40)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded, color: AppTheme.goldAmber, size: 14),
                        const SizedBox(width: 4),
                        const Text(
                          'Unclaimed Yield: ',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        ),
                        Text(
                          '+${_unclaimedYield.toStringAsFixed(2)} JWC',
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            color: AppTheme.goldChampagne,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _claimYield,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.goldPrimary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'CLAIM',
                              style: TextStyle(
                                color: AppTheme.obsidian,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3D Gold JuwishCoin Interactive Medallion Tap Zone
            Center(
              child: SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ambient gold glow backdrops
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.goldPrimary.withAlpha(40),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),

                    // Rotating Orbital Rings
                    RotationTransition(
                      turns: _orbitController,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.goldAmber.withAlpha(80),
                            width: 1.5,
                          ),
                        ),
                        child: CustomPaint(
                          painter: _OrbitDashesPainter(),
                        ),
                      ),
                    ),

                    // Interactive Tap Medallion
                    GestureDetector(
                      onTapDown: _onCoinTapped,
                      child: AnimatedScale(
                        scale: _coinScale,
                        duration: const Duration(milliseconds: 90),
                        curve: Curves.easeOutQuad,
                        child: Container(
                          width: 190,
                          height: 190,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [
                                Color(0xFFFFF6DF),
                                Color(0xFFFFD700),
                                Color(0xFFE9C400),
                                Color(0xFF996B00),
                                Color(0xFF241C09),
                              ],
                              stops: [0.0, 0.45, 0.70, 0.90, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(180),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: AppTheme.goldPrimary.withAlpha(100),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ],
                            border: Border.all(
                              color: const Color(0xFFFFF6DF),
                              width: 2.5,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Inner engraved bezel ring
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0x66FFD700),
                                    width: 2,
                                  ),
                                ),
                              ),
                              // Emblem Icon
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '✡',
                                    style: TextStyle(
                                      fontSize: 68,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3A3000),
                                      shadows: [
                                        Shadow(
                                          color: Color(0xFFFFF6DF),
                                          blurRadius: 4,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'JUWISHCOIN',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2.0,
                                      color: Color(0xFF3A3000),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Particle Tap Overlays
                    ..._particles.map((p) => _ParticleWidget(
                          key: ValueKey(p.id),
                          particle: p,
                          onDismiss: () {
                            setState(() => _particles.remove(p));
                          },
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Energy Bar & Regenerative Telemetry
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: AppTheme.luxuryCardDecoration(fillColor: AppTheme.surfaceLow),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: AppTheme.goldAmber, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'MINING ENERGY',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: AppTheme.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$_currentEnergy / $_maxEnergy',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          color: AppTheme.goldChampagne,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _currentEnergy / _maxEnergy,
                      backgroundColor: AppTheme.surfaceElevated,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.goldAmber),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Active Mining Hardware & Telemetry Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'NODE HASHRATE',
                    '${_hashrateGhs.toStringAsFixed(1)} GH/s',
                    Icons.speed_rounded,
                    AppTheme.goldPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    'ACTIVE RIGS',
                    '4 / 4 ONLINE',
                    Icons.developer_board_rounded,
                    AppTheme.emeraldPositive,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    'PASSIVE YIELD',
                    '+34.5 JWC/h',
                    Icons.trending_up_rounded,
                    AppTheme.goldAmber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Hardware Upgrade Modules
            Container(
              padding: const EdgeInsets.all(14),
              decoration: AppTheme.luxuryCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MINING RIG UPGRADES',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppTheme.goldChampagne,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildRigTile(
                    'Antminer Gold S21 Pro',
                    '54.0 GH/s • Efficiency 16.5 J/TH',
                    'ACTIVE',
                    AppTheme.emeraldPositive,
                  ),
                  const SizedBox(height: 8),
                  _buildRigTile(
                    'Quantum Bullion ASIC Rig',
                    '88.8 GH/s • Multi-Chain Subnet',
                    'ACTIVE',
                    AppTheme.emeraldPositive,
                  ),
                  const SizedBox(height: 8),
                  _buildRigTile(
                    'Solar Micro-Hydro Rig',
                    'Passive +12 JWC/hr Eco Mining',
                    'UPGRADE (2,500 JWC)',
                    AppTheme.goldPrimary,
                    isAction: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: AppTheme.luxuryCardDecoration(fillColor: AppTheme.surfaceLow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 8, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRigTile(String title, String desc, String tag, Color tagColor, {bool isAction = false}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isAction ? AppTheme.goldPrimary : tagColor.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: tagColor.withAlpha(100)),
            ),
            child: Text(
              tag,
              style: TextStyle(
                color: isAction ? AppTheme.obsidian : tagColor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TapParticle {
  final int id;
  final Offset position;
  _TapParticle({required this.id, required this.position});
}

class _ParticleWidget extends StatefulWidget {
  final _TapParticle particle;
  final VoidCallback onDismiss;

  const _ParticleWidget({super.key, required this.particle, required this.onDismiss});

  @override
  State<_ParticleWidget> createState() => _ParticleWidgetState();
}

class _ParticleWidgetState extends State<_ParticleWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _animY;
  late Animation<double> _animOpacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _animY = Tween<double>(begin: 0, end: -60).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _animOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));

    _ctrl.forward().then((_) => widget.onDismiss());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Positioned(
          left: widget.particle.position.dx,
          top: widget.particle.position.dy + _animY.value,
          child: Opacity(
            opacity: _animOpacity.value,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stars_rounded, color: AppTheme.goldPrimary, size: 16),
                SizedBox(width: 2),
                Text(
                  '+10 JWC',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    color: AppTheme.goldChampagne,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(color: AppTheme.goldPrimary, blurRadius: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OrbitDashesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.goldPrimary.withAlpha(120)
      ..style = PaintingStyle.fill;

    const int dots = 8;
    final double radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < dots; i++) {
      final angle = (i * 2 * pi) / dots;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawCircle(Offset(x, y), 2.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

