import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class EarnScreen extends StatefulWidget {
  final double jwcBalance;
  final Function(double deltaJwc) onRewardClaimed;

  const EarnScreen({
    super.key,
    required this.jwcBalance,
    required this.onRewardClaimed,
  });

  @override
  State<EarnScreen> createState() => _EarnScreenState();
}

class _EarnScreenState extends State<EarnScreen> {
  bool _day1Claimed = false;
  final Set<String> _completedQuests = {};

  final String _referralLink = 'https://t.me/JuwishCoinBot/app?startapp=ref_whale777';

  @override
  void initState() {
    super.initState();
    _completedQuests.addAll(StorageService.instance.loadClaimedTasks());
    _day1Claimed = _completedQuests.contains('__streak_day_1__');
  }

  void _claimStreakDay1() {
    if (_day1Claimed) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _day1Claimed = true;
      _completedQuests.add('__streak_day_1__');
    });
    StorageService.instance.saveClaimedTasks(_completedQuests);
    widget.onRewardClaimed(50.0);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppTheme.surfaceElevated,
        content: Row(
          children: [
            Icon(Icons.bolt_rounded, color: AppTheme.goldPrimary),
            SizedBox(width: 8),
            Text(
              'Claimed Day 1 Bonus: +50 JWC!',
              style: TextStyle(color: AppTheme.goldChampagne, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _completeQuest(String title, double reward) {
    if (_completedQuests.contains(title)) return;
    HapticFeedback.mediumImpact();
    setState(() => _completedQuests.add(title));
    StorageService.instance.saveClaimedTasks(_completedQuests);
    widget.onRewardClaimed(reward);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.surfaceElevated,
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppTheme.emeraldPositive),
            const SizedBox(width: 8),
            Text(
              'Quest Complete: +${reward.toStringAsFixed(0)} JWC!',
              style: const TextStyle(color: AppTheme.goldChampagne, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _copyReferralLink() {
    Clipboard.setData(ClipboardData(text: _referralLink));
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('VIP Referral Link copied to clipboard!'),
        duration: Duration(seconds: 2),
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
            // Ecosystem Rewards Banner
            _buildRewardsHeroBanner(),
            const SizedBox(height: 14),

            // 7-Day Gold Streak Matrix
            _buildStreakMatrix(),
            const SizedBox(height: 14),

            // VIP Daily Tasks & Quests
            _buildQuestsSection(),
            const SizedBox(height: 14),

            // Referral Program Card
            _buildReferralCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.luxuryCardDecoration(glowing: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stars_rounded, color: AppTheme.goldPrimary, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'ECOSYSTEM REWARDS',
                        style: TextStyle(
                          color: AppTheme.goldPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    'VIP Earn & Quests',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppTheme.textLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.goldPrimary.withAlpha(80)),
                ),
                child: const Text(
                  'HIGH ROLLER',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppTheme.goldAmber,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLowest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL EARNED TO DATE',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 9, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.jwcBalance.toStringAsFixed(widget.jwcBalance < 10 ? 2 : 0)} JWC',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        color: AppTheme.goldChampagne,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Text(
                  '≈ \$${(widget.jwcBalance * 3.0).toStringAsFixed(2)} USD',
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    color: AppTheme.goldAmber,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakMatrix() {
    final streakDays = [
      {'day': 'D1', 'reward': '+50', 'claimed': _day1Claimed, 'ready': !_day1Claimed},
      {'day': 'D2', 'reward': '+100', 'locked': true},
      {'day': 'D3', 'reward': '+150', 'locked': true},
      {'day': 'D4', 'reward': '+250', 'locked': true},
      {'day': 'D5', 'reward': '+400', 'locked': true},
      {'day': 'D6', 'reward': '+600', 'locked': true},
      {'day': 'D7', 'reward': 'VAULT', 'locked': true},
    ];

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
                  Icon(Icons.calendar_today_rounded, color: AppTheme.goldAmber, size: 16),
                  SizedBox(width: 6),
                  Text(
                    '7-Day Gold Streak',
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
                child: Text(
                  _day1Claimed ? 'STREAK ACTIVE' : 'DAY 1 READY',
                  style: const TextStyle(
                    color: AppTheme.obsidian,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal 7 Day Grid
          Row(
            children: streakDays.map((d) {
              final isClaimed = d['claimed'] == true;
              final isReady = d['ready'] == true;

              return Expanded(
                child: GestureDetector(
                  onTap: isReady ? _claimStreakDay1 : null,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isReady ? AppTheme.goldPrimary.withAlpha(40) : AppTheme.surfaceLowest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isReady
                            ? AppTheme.goldPrimary
                            : isClaimed
                                ? AppTheme.goldAmber.withAlpha(80)
                                : Colors.white.withAlpha(10),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          d['day'] as String,
                          style: TextStyle(
                            color: isReady ? AppTheme.goldPrimary : AppTheme.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          isClaimed
                              ? Icons.check_circle_rounded
                              : isReady
                                  ? Icons.bolt_rounded
                                  : Icons.lock_outline_rounded,
                          size: 14,
                          color: isClaimed
                              ? AppTheme.emeraldPositive
                              : isReady
                                  ? AppTheme.goldPrimary
                                  : AppTheme.textMuted,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          d['reward'] as String,
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            color: isReady ? AppTheme.goldChampagne : AppTheme.textMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestsSection() {
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
                  Icon(Icons.military_tech_rounded, color: AppTheme.goldPrimary, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'VIP DAILY QUESTS',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppTheme.goldChampagne,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.goldPrimary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '15 JWC DAILY POOL',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    color: AppTheme.obsidian,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Complete all 4 daily community & trading tasks to claim your share of 15 JWC (\$45.00 USDT) daily rewards.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 11, height: 1.4),
          ),
          const SizedBox(height: 12),
          _questTile('Join Telegram Channel', 'Subscribe to official JWC announcements', 3.0, Icons.telegram_rounded),
          _questTile('Follow on X / Twitter', 'Follow @JuwishCoin on X', 3.0, Icons.share_rounded),
          _questTile('Boost Telegram Channel', 'Grant 1 Telegram level boost', 4.0, Icons.rocket_launch_rounded),
          _questTile('Execute In-App Swaps', 'Trade or swap tokens in the terminal', 5.0, Icons.swap_horiz_rounded),
        ],
      ),
    );
  }

  Widget _questTile(String title, String desc, double reward, IconData icon) {
    final isDone = _completedQuests.contains(title);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.goldPrimary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppTheme.textLight, fontSize: 12, fontWeight: FontWeight.w700),
                ),
                Text(
                  desc,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _completeQuest(title, reward),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDone ? AppTheme.surfaceElevated : AppTheme.goldPrimary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isDone ? 'CLAIMED' : '+${reward.toStringAsFixed(0)} JWC',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  color: isDone ? AppTheme.textMuted : AppTheme.obsidian,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.luxuryCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.group_add_rounded, color: AppTheme.goldPrimary, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Whale Referral Program',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppTheme.textLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                '10% MINING DIVIDEND',
                style: TextStyle(color: AppTheme.goldAmber, fontSize: 9, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Earn 10% lifetime hash-rate dividends from invited traders and 2,500 JWC bonus upon qualification.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 11, height: 1.4),
          ),
          const SizedBox(height: 10),

          // Copy Link Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLowest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withAlpha(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _referralLink,
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      color: AppTheme.goldChampagne,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _copyReferralLink,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.goldPrimary.withAlpha(60)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded, color: AppTheme.goldPrimary, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'COPY',
                          style: TextStyle(
                            color: AppTheme.goldPrimary,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
}
