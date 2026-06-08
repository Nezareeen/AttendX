import 'package:flutter/material.dart';

class AppColors {
  // Base colors
  static const Color yellow = Color(0xFFFFC107);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9E9E9E);
  
  // WhatsApp theme colors
  static const Color waTealGreen = Color(0xFF075E54);
  static const Color waLightGreen = Color(0xFF25D366);
  static const Color waOutgoingBubble = Color(0xFFDCF8C6);
  static const Color waChatBackground = Color(0xFFECE5DD);

  // Primary colors
  static const Color primaryStart = yellow;
  static const Color primaryEnd = yellow;
  static const Color accentPink = grey;
  static const Color accentOrange = grey;

  // Background colors
  static const Color bgDarkStart = white;
  static const Color bgDarkMid = white;
  static const Color bgDarkEnd = white;

  // Solid colors replacing Glass colors to remove glass theme
  static const Color glassWhite = white;
  static const Color glassBorder = grey;
  static const Color glassHighlight = white;

  // Text colors
  static const Color textPrimary = black;
  static const Color textSecondary = grey;
  static const Color textMuted = grey;

  // Status colors
  static const Color success = black;
  static const Color warning = yellow;
  static const Color error = black;
  static const Color info = grey;

  // Gradients (Solid colors replacing gradients to remove glass theme)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [bgDarkStart, bgDarkMid, bgDarkEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentPink, accentOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
