import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:examen/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  bool get isDark => _themeMode == ThemeMode.dark;

  // ─── Design tokens ────────────────────────────────────────────────────────
  // Dark palette
  static const Color _darkBg = Color(0xFF0A0A0F);
  static const Color _darkSurface = Color(0xFF111118);
  static const Color _darkCard = Color(0xFF16161F);
  static const Color _darkBorder = Color(0xFF1E1E2A);
  static const Color _accent = Color(0xFF5B8DEF);
  static const Color _accentLight = Color(0xFF7BA7FF);

  // Light palette
  static const Color _lightBg = Color(0xFFF4F6FB);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightCard = Color(0xFFF8F9FE);
  static const Color _lightBorder = Color(0xFFE4E8F4);

  TextTheme _buildTextTheme(bool dark) {
    final primary = dark ? Colors.white : const Color(0xFF0A0A0F);
    final secondary =
        dark ? const Color(0xFF8A8A9A) : const Color(0xFF6B7280);
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(
        fontWeight: FontWeight.w700,
        fontSize: 52,
        color: primary,
        letterSpacing: -2.0,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.outfit(
        fontWeight: FontWeight.w700,
        fontSize: 40,
        color: primary,
        letterSpacing: -1.5,
        height: 1.1,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        fontSize: 28,
        color: primary,
        letterSpacing: -0.8,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        fontSize: 22,
        color: primary,
        letterSpacing: -0.5,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontWeight: FontWeight.w500,
        fontSize: 18,
        color: primary,
      ),
      titleLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: primary,
      ),
      titleMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: primary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 15,
        color: secondary,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 13,
        color: secondary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 11,
        color: secondary,
        letterSpacing: 0.3,
      ),
      labelLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: primary,
        letterSpacing: 0.2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Météo Sénégal',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: _accent,
          onPrimary: Colors.white,
          secondary: _accentLight,
          onSecondary: Colors.white,
          error: const Color(0xFFEF4444),
          onError: Colors.white,
          surface: _lightSurface,
          onSurface: const Color(0xFF0A0A0F),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: _lightBg,
        textTheme: _buildTextTheme(false),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0A0A0F),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF0A0A0F)),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        extensions: const [
          AppColors(
            bg: _lightBg,
            surface: _lightSurface,
            card: _lightCard,
            border: _lightBorder,
            accent: _accent,
            accentLight: _accentLight,
            textPrimary: Color(0xFF0A0A0F),
            textSecondary: Color(0xFF6B7280),
            textTertiary: Color(0xFF9CA3AF),
          ),
        ],
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: _accent,
          onPrimary: Colors.white,
          secondary: _accentLight,
          onSecondary: Colors.white,
          error: const Color(0xFFEF4444),
          onError: Colors.white,
          surface: _darkSurface,
          onSurface: Colors.white,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: _darkBg,
        textTheme: _buildTextTheme(true),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        extensions: const [
          AppColors(
            bg: _darkBg,
            surface: _darkSurface,
            card: _darkCard,
            border: _darkBorder,
            accent: _accent,
            accentLight: _accentLight,
            textPrimary: Colors.white,
            textSecondary: Color(0xFF8A8A9A),
            textTertiary: Color(0xFF4A4A5A),
          ),
        ],
      ),
      home: const HomeScreen(),
    );
  }
}

/// Theme extension for custom design tokens
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color bg;
  final Color surface;
  final Color card;
  final Color border;
  final Color accent;
  final Color accentLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  const AppColors({
    required this.bg,
    required this.surface,
    required this.card,
    required this.border,
    required this.accent,
    required this.accentLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
  });

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? card,
    Color? border,
    Color? accent,
    Color? accentLight,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      accentLight: accentLight ?? this.accentLight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentLight: Color.lerp(accentLight, other.accentLight, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
    );
  }
}
