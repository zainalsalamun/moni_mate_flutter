import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core colors
  static const _primary = Color(0xFF0288D1);
  static const _secondary = Color(0xFF4FC3F7);
  static const _accent = Color(0xFF00E5FF);

  // Backgrounds
  static const _lightBg = Color(0xFFF7FAFC);
  static const _lightCard = Colors.white;
  static const _darkBg = Color(0xFF0B1220);
  static const _darkCard = Color(0xFF131E32);

  // Text Colors
  static const _lightText = Color(0xFF1A202C);
  static const _darkText = Color(0xFFF7FAFC);

  // Radius Configuration
  static const double _cardRadius = 20.0;
  static const double _buttonRadius = 14.0;
  static const double _inputRadius = 14.0;

  static ThemeData light() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primary,
        primary: _primary,
        secondary: _secondary,
        tertiary: _accent,
        brightness: Brightness.light,
        surface: _lightCard,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: _lightText,
        displayColor: _lightText,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: _lightBg,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w700, // Bolder, more modern title
          fontSize: 18,
          color: _lightText,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: _lightText),
      ),
      cardTheme: CardThemeData(
        elevation: 0, // Flat design with soft borders/shadows is more modern
        color: _lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: const BorderSide(
              color: Color(0xFFEDF2F7), width: 1.2), // Soft border
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
          side: const BorderSide(color: _primary, width: 2),
          foregroundColor: _primary,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
          foregroundColor: _primary,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        labelStyle: GoogleFonts.poppins(color: const Color(0xFFA0AEC0)),
        hintStyle: GoogleFonts.poppins(color: const Color(0xFFCBD5E0)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 20,
        selectedItemColor: _primary,
        unselectedItemColor: const Color(0xFFA0AEC0),
        selectedLabelStyle:
            GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle:
            GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12),
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEDF2F7),
        thickness: 1,
        space: 24,
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primary,
        primary: _primary,
        secondary: _secondary,
        tertiary: _accent,
        brightness: Brightness.dark,
        surface: _darkCard,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: _darkText,
        displayColor: _darkText,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: _darkBg,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: _darkText,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: _darkText),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: const BorderSide(
              color: Color(0xFF2D3748),
              width: 1), // Subtle borders in dark mode
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
          side: const BorderSide(color: _primary, width: 2),
          foregroundColor: _primary,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
          foregroundColor: _primary,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A202C),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: const BorderSide(color: Color(0xFF2D3748), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        labelStyle: GoogleFonts.poppins(color: const Color(0xFFA0AEC0)),
        hintStyle: GoogleFonts.poppins(color: const Color(0xFF4A5568)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF131E32),
        elevation: 20,
        selectedItemColor: _primary,
        unselectedItemColor: const Color(0xFF718096),
        selectedLabelStyle:
            GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle:
            GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12),
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2D3748),
        thickness: 1,
        space: 24,
      ),
    );
  }

  // 🌊 Helper gradient - vibrant and refreshed
  static LinearGradient oceanGradient() => const LinearGradient(
        colors: [_primary, _secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Additional modern gradient for dark cards or special elements
  static LinearGradient darkCardGradient() => const LinearGradient(
        colors: [Color(0xFF1A202C), Color(0xFF131E32)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
