import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/app_config.dart';
import '../screens/admin_screen.dart';

class VipHeader extends StatelessWidget {
  final String title;
  final double jwcBalance;

  const VipHeader({
    super.key,
    required this.title,
    this.jwcBalance = 148250.0,
  });

  void _showAdminPinDialog(BuildContext context) {
    HapticFeedback.selectionClick();
    final textController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(210),
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.surfaceCharcoal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppTheme.goldPrimary.withAlpha(120), width: 1.2),
              ),
              title: const Row(
                children: [
                  Icon(Icons.shield_rounded, color: AppTheme.goldPrimary, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'VIP ADMIN ACCESS',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppTheme.goldChampagne,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter master security PIN to configure tokenomics, mining rates & announcements:',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: textController,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 22,
                      letterSpacing: 8.0,
                      color: AppTheme.goldPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: AppTheme.surfaceLowest,
                      hintText: '••••',
                      hintStyle: TextStyle(color: AppTheme.textMuted.withAlpha(90), letterSpacing: 8.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppTheme.goldPrimary.withAlpha(80)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppTheme.goldPrimary, width: 1.5),
                      ),
                    ),
                    onSubmitted: (pin) {
                      _verifyAndOpenAdmin(context, dialogCtx, pin, setDialogState, (err) {
                        setDialogState(() => errorMessage = err);
                      });
                    },
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppTheme.rubyNegative, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          errorMessage!,
                          style: const TextStyle(color: AppTheme.rubyNegative, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('CANCEL', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ),
                ElevatedButton(
                  onPressed: () {
                    _verifyAndOpenAdmin(
                      context,
                      dialogCtx,
                      textController.text.trim(),
                      setDialogState,
                      (err) => setDialogState(() => errorMessage = err),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.goldPrimary,
                    foregroundColor: AppTheme.obsidian,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'UNLOCK TERMINAL',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.8),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _verifyAndOpenAdmin(
    BuildContext rootContext,
    BuildContext dialogCtx,
    String enteredPin,
    StateSetter setDialogState,
    void Function(String) onError,
  ) {
    if (enteredPin == AppConfig.instance.adminPin) {
      HapticFeedback.heavyImpact();
      Navigator.of(dialogCtx).pop();
      Navigator.of(rootContext).push(
        MaterialPageRoute(builder: (_) => const AdminScreen()),
      );
    } else {
      HapticFeedback.vibrate();
      onError('Access Denied: Invalid Security PIN (Default: 7777)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCharcoal.withAlpha(240),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.goldPrimary.withAlpha(35),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(120),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Row: Network status, wallet address, balance, notifications, avatar
          Row(
            children: [
              // BSC Network Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.goldAmber.withAlpha(80),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppTheme.emeraldPositive,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'BSC',
                      style: TextStyle(
                        color: AppTheme.goldAmber,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Wallet Address Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withAlpha(15),
                    width: 0.8,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppTheme.goldPrimary,
                      size: 13,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '0x7F2b...c819',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Balance Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.goldPrimary.withAlpha(60),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      color: AppTheme.goldPrimary,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${jwcBalance.toStringAsFixed(0)} JWC',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        color: AppTheme.goldChampagne,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Notifications
              Stack(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withAlpha(20),
                        width: 0.8,
                      ),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppTheme.textLight,
                      size: 16,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppTheme.goldPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.goldPrimary,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              // Avatar
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.goldPrimary,
                    width: 1.2,
                  ),
                  gradient: AppTheme.goldGradient,
                ),
                child: ClipOval(
                  child: Container(
                    color: AppTheme.surfaceElevated,
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppTheme.goldPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Bottom Row: Screen Title and VIP Tier Badge (Tappable for Admin Access)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              GestureDetector(
                onTap: () => _showAdminPinDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.goldPrimary.withAlpha(120),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.goldPrimary.withAlpha(35),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.stars_rounded,
                        color: AppTheme.goldPrimary,
                        size: 13,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'VIP TIER 3',
                        style: TextStyle(
                          fontFamily: 'Inter',
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
        ],
      ),
    );
  }
}
