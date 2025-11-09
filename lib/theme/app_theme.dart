import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// class AppTheme {
//   static const _primary = Color(0xFF48C6EF);
//   static const _secondary = Color(0xFF6F86D6);

//   static ThemeData light() {
//     final base = ThemeData(
//       colorScheme: ColorScheme.fromSeed(
//         seedColor: _primary,
//         brightness: Brightness.light,
//       ),
//       useMaterial3: true,
//       textTheme: GoogleFonts.poppinsTextTheme(),
//     );

//     return base.copyWith(
//       scaffoldBackgroundColor: const Color(0xFFF7FAFC),
//       appBarTheme: const AppBarTheme(
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         surfaceTintColor: Colors.transparent,
//         systemOverlayStyle: SystemUiOverlayStyle(
//           statusBarColor: Colors.transparent,
//           statusBarIconBrightness: Brightness.dark,
//           statusBarBrightness: Brightness.light,
//         ),
//       ),
//       cardTheme: CardTheme(
//         elevation: 1,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           backgroundColor: _secondary,
//           foregroundColor: Colors.white,
//         ),
//       ),
//     );
//   }

//   static ThemeData dark() {
//     final base = ThemeData(
//       colorScheme: ColorScheme.fromSeed(
//         seedColor: _secondary,
//         brightness: Brightness.dark,
//       ),
//       useMaterial3: true,
//       textTheme: GoogleFonts.poppinsTextTheme(
//         ThemeData.dark().textTheme,
//       ),
//     );

//     return base.copyWith(
//       scaffoldBackgroundColor: const Color(0xFF0B1220),
//       appBarTheme: const AppBarTheme(
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         surfaceTintColor: Colors.transparent,
//         systemOverlayStyle: SystemUiOverlayStyle(
//           statusBarColor: Colors.transparent,
//           statusBarIconBrightness: Brightness.light,
//           statusBarBrightness: Brightness.dark,
//         ),
//       ),
//       cardTheme: CardTheme(
//         elevation: 1,
//         color: const Color(0xFF0F172A),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           backgroundColor: _primary,
//           foregroundColor: Colors.white,
//         ),
//       ),
//     );
//   }

//   // 🌊 Helper gradient
//   static LinearGradient oceanGradient() => const LinearGradient(
//         colors: [_primary, _secondary],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       );
// }

class AppTheme {
  static const _primary = Color(0xFF48C6EF);
  static const _secondary = Color(0xFF6F86D6);

  static ThemeData light() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primary,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(),
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF7FAFC),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        // 🟢 sedikit efek gradient lembut di area atas (terlihat di notch/edge)
        backgroundColor: _primary.withOpacity(0.05),
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Brightness.dark, // jam/sinyal gelap → terlihat di light
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.black87,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: _secondary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _secondary,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0B1220),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        // 🌙 gradient lembut tetap ada tapi disesuaikan agar tidak silau
        backgroundColor: _secondary.withOpacity(0.15),
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Brightness.light, // jam putih → terlihat di dark
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 1,
        color: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: _primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  // 🌊 Helper gradient
  static LinearGradient oceanGradient() => const LinearGradient(
        colors: [_primary, _secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
