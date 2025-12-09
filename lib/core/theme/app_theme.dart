import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Apple iOS System Colors (Dark Mode)
  static const Color background = Color(0xFF000000); 
  static const Color surface = Color(0xFF1C1C1E); // Apple System Gray 6 (Dark)
  static const Color surfaceSecondary = Color(0xFF2C2C2E); // Apple System Gray 5 (Dark)
  
  // Premium Brand Colors
  static const Color accent = Color(0xFFD4AF37); // Gold
  static const Color accentDim = Color(0xFF8F7320);
  
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93); // Apple System Gray
  static const Color textTertiary = Color(0xFF48484A);
  
  static const Color divider = Color(0xFF38383A);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      useMaterial3: true,
      
      // Apple-like Transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),

      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accent,
        surface: surface,
        onSurface: textPrimary,
        background: background,
        error: Color(0xFFFF453A), // Apple System Red
      ),
      
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.4, // Tight tracking for large titles
          height: 1.1,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 17, // Standard iOS Body size
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.4,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 17,
          color: textPrimary,
          letterSpacing: -0.4,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 15,
          color: textSecondary,
          letterSpacing: -0.2,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
      ),
      
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 0.5,
        space: 1,
      ),
    );
  }
}
