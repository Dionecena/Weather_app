import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:examen/main.dart';
import 'package:examen/routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _buttonPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Top bar
              _buildTopBar(colors, isDark),
              const Spacer(flex: 2),
              // Hero content — centré
              _buildHeroContent(colors),
              const Spacer(flex: 3),
              // CTA
              _buildCta(colors),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(AppColors colors, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo / brand
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.wb_sunny_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Météo',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.1, end: 0),
        // Theme toggle
        GestureDetector(
          onTap: () => MyApp.of(context)?.toggleTheme(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.border, width: 1),
            ),
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: colors.textSecondary,
              size: 18,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildHeroContent(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Eyebrow label — centré
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: colors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: colors.accent.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            'DONNÉES EN TEMPS RÉEL',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colors.accent,
              letterSpacing: 1.2,
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 100.ms, duration: 400.ms)
            .slideY(begin: 0.2, end: 0, delay: 100.ms),
        const SizedBox(height: 20),
        // Main title — centré
        Text(
          'Météo\nSénégal.',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 52,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            letterSpacing: -2.0,
            height: 1.05,
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 500.ms)
            .slideY(begin: 0.15, end: 0, delay: 200.ms),
        const SizedBox(height: 20),
        // Subtitle — centré
        Text(
          'Consultez les conditions météo\npour 5 villes du Sénégal.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: colors.textSecondary,
            height: 1.6,
          ),
        )
            .animate()
            .fadeIn(delay: 350.ms, duration: 500.ms)
            .slideY(begin: 0.1, end: 0, delay: 350.ms),
        const SizedBox(height: 32),
        // City tags — centrés
        _buildCityTags(colors)
            .animate()
            .fadeIn(delay: 450.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildCityTags(AppColors colors) {
    final cities = ['Dakar', 'Saint-Louis', 'Thiès', 'Ziguinchor', 'Touba'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: cities.map((city) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.border, width: 1),
          ),
          child: Text(
            city,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCta(AppColors colors) {
    return Column(
      children: [
        // Divider subtil
        Container(
          height: 1,
          color: colors.border,
          margin: const EdgeInsets.only(bottom: 24),
        )
            .animate()
            .fadeIn(delay: 500.ms, duration: 400.ms),
        // Primary button
        GestureDetector(
          onTapDown: (_) => setState(() => _buttonPressed = true),
          onTapUp: (_) {
            setState(() => _buttonPressed = false);
            AppRoutes.toLoading(context);
          },
          onTapCancel: () => setState(() => _buttonPressed = false),
          child: AnimatedScale(
            scale: _buttonPressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_download_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Lancer l\'expérience',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white70,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 550.ms, duration: 400.ms)
            .slideY(begin: 0.15, end: 0, delay: 550.ms),
        const SizedBox(height: 12),
        // Hint
        Text(
          'OpenWeatherMap API • 5 villes',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: colors.textTertiary,
          ),
        )
            .animate()
            .fadeIn(delay: 650.ms, duration: 400.ms),
      ],
    );
  }
}
