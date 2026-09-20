import 'package:flutter/material.dart';

/// JuwishCoin (JWC) VIP Prestige Wealth Theme
/// Designed for elite Telegram Mini App experience following DESIGN.md
class AppTheme {
  // Brand Palette Architecture
  static const Color obsidian = Color(0xFF080808);
  static const Color surfaceCharcoal = Color(0xFF121214);
  static const Color surfaceElevated = Color(0xFF1E1E24);
  static const Color surfaceHigh = Color(0xFF2A2A2A);
  static const Color surfaceLow = Color(0xFF1C1B1B);
  static const Color surfaceLowest = Color(0xFF0E0E0E);

  static const Color goldPrimary = Color(0xFFFFD700);
  static const Color goldAmber = Color(0xFFFFAA00);
  static const Color goldChampagne = Color(0xFFF5E6C8);
  static const Color goldDim = Color(0xFFE9C400);

  static const Color textLight = Color(0xFFE5E2E1);
  static const Color textMuted = Color(0xFF8E8E93);
  static const Color textZinc = Color(0xFF52525B);

  static const Color emeraldPositive = Color(0xFF00E676);
  static const Color crimsonNegative = Color(0xFFFF4D4D);
  static const Color rubyNegative = Color(0xFFFF4D4D);

  // Reusable Luxury Linear Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFE16D), Color(0xFFFFD700), Color(0xFFFFAA00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldTextGradient = LinearGradient(
    colors: [Color(0xFFFFF6DF), Color(0xFFFFD700), Color(0xFFFFAA00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardBorderGradient = LinearGradient(
    colors: [
      Color(0x66FFD700),
      Color(0x26FFAA00),
      Color(0x08FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassCardGradient = LinearGradient(
    colors: [Color(0xFF1A1A1E), Color(0xFF121214), Color(0xFF0E0E10)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ThemeData Definition
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: obsidian,
      primaryColor: goldPrimary,
      canvasColor: obsidian,
      cardColor: surfaceCharcoal,
      colorScheme: const ColorScheme.dark(
        primary: goldPrimary,
        secondary: goldAmber,
        surface: surfaceCharcoal,
        error: crimsonNegative,
        onPrimary: obsidian,
        onSecondary: obsidian,
        onSurface: textLight,
      ),
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceCharcoal,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: goldPrimary),
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceCharcoal,
        selectedItemColor: goldPrimary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
    );
  }

  // Card BoxDecoration Helper
  static BoxDecoration luxuryCardDecoration({
    double borderRadius = 16,
    bool glowing = false,
    Color? fillColor,
  }) {
    return BoxDecoration(
      color: fillColor ?? surfaceCharcoal,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: glowing ? goldPrimary.withAlpha(120) : goldPrimary.withAlpha(50),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(150),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
        if (glowing)
          BoxShadow(
            color: goldPrimary.withAlpha(30),
            blurRadius: 20,
            spreadRadius: 1,
          ),
      ],
    );
  }
}

