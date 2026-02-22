import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:examen/screens/home_screen.dart';

void main() {
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
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  static const Color _seedColor = Color(0xFF4facfe);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Météo App',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
          surface: const Color(0xFFF5F9FF),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          headlineLarge: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
          headlineMedium: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
          bodyLarge: GoogleFonts.inter(fontSize: 16),
          bodyMedium: GoogleFonts.inter(fontSize: 14),
          labelLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
          surface: const Color(0xFF0d1117),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          headlineLarge: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
          headlineMedium: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
          bodyLarge: GoogleFonts.inter(fontSize: 16),
          bodyMedium: GoogleFonts.inter(fontSize: 14),
          labelLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
