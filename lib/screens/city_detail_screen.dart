import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:examen/models/weather.dart';
import 'package:examen/main.dart';

class CityDetailScreen extends StatefulWidget {
  final Weather weather;

  const CityDetailScreen({super.key, required this.weather});

  @override
  State<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends State<CityDetailScreen> {
  bool _mapsPressed = false;

  Future<void> _openGoogleMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${widget.weather.lat},${widget.weather.lon}',
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Impossible d\'ouvrir Google Maps',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de l\'ouverture de Google Maps',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Color _tempColor(double temp) {
    if (temp < 15) return const Color(0xFF60A5FA);
    if (temp < 25) return const Color(0xFF34D399);
    if (temp < 32) return const Color(0xFFFBBF24);
    return const Color(0xFFF87171);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tempColor = _tempColor(widget.weather.temperature);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildTopBar(colors, isDark)),
            SliverToBoxAdapter(child: _buildHero(colors, tempColor)),
            SliverToBoxAdapter(child: _buildMetricsSection(colors, tempColor)),
            SliverToBoxAdapter(child: _buildCoordSection(colors)),
            SliverToBoxAdapter(child: _buildMapsButton(colors)),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(AppColors colors, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: colors.textSecondary,
                size: 18,
              ),
            ),
          ),
          const Spacer(),
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
          ),
        ],
      ),
    );
  }

  Widget _buildHero(AppColors colors, Color tempColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + city name row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: 'weather_${widget.weather.cityName}',
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: tempColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.network(
                    'https://openweathermap.org/img/wn/${widget.weather.icon}@2x.png',
                    width: 48,
                    height: 48,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.cloud_rounded,
                        size: 32,
                        color: tempColor,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.weather.cityName,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.weather.description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0),
          const SizedBox(height: 32),
          // Big temperature
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.weather.temperature.toStringAsFixed(1),
                style: GoogleFonts.outfit(
                  fontSize: 80,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  height: 1.0,
                  letterSpacing: -4,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 4),
                child: Text(
                  '°C',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 500.ms)
              .slideY(begin: 0.1, end: 0, delay: 100.ms),
          const SizedBox(height: 4),
          // Temperature label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: tempColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _tempLabel(widget.weather.temperature),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: tempColor,
                letterSpacing: 0.5,
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms),
        ],
      ),
    );
  }

  String _tempLabel(double temp) {
    if (temp < 15) return 'FRAIS';
    if (temp < 25) return 'AGRÉABLE';
    if (temp < 32) return 'CHAUD';
    return 'TRÈS CHAUD';
  }

  Widget _buildMetricsSection(AppColors colors, Color tempColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conditions',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors.textTertiary,
              letterSpacing: 1.0,
            ),
          )
              .animate()
              .fadeIn(delay: 250.ms, duration: 400.ms),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  icon: Icons.thermostat_rounded,
                  label: 'Température',
                  value: '${widget.weather.temperature.toStringAsFixed(1)}°C',
                  iconColor: tempColor,
                  colors: colors,
                  delay: 300,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricCard(
                  icon: Icons.water_drop_rounded,
                  label: 'Humidité',
                  value: '${widget.weather.humidity.toInt()}%',
                  iconColor: const Color(0xFF60A5FA),
                  colors: colors,
                  delay: 370,
                  progressValue: widget.weather.humidity / 100,
                  progressColor: const Color(0xFF60A5FA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  icon: Icons.air_rounded,
                  label: 'Vent',
                  value: '${widget.weather.windSpeed.toStringAsFixed(1)} m/s',
                  iconColor: const Color(0xFF34D399),
                  colors: colors,
                  delay: 440,
                  progressValue: (widget.weather.windSpeed / 30).clamp(0.0, 1.0),
                  progressColor: const Color(0xFF34D399),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricCard(
                  icon: Icons.explore_rounded,
                  label: 'Latitude',
                  value: '${widget.weather.lat.toStringAsFixed(2)}°N',
                  iconColor: const Color(0xFFA78BFA),
                  colors: colors,
                  delay: 510,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required AppColors colors,
    required int delay,
    double? progressValue,
    Color? progressColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: colors.textTertiary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          if (progressValue != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progressValue.clamp(0.0, 1.0),
                backgroundColor: colors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressColor ?? iconColor,
                ),
                minHeight: 3,
              ),
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delay.ms, duration: 350.ms)
        .slideY(begin: 0.08, end: 0, delay: delay.ms);
  }

  Widget _buildCoordSection(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA78BFA).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: Color(0xFFA78BFA),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Position géographique',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _coordItem(
                    'Latitude',
                    '${widget.weather.lat}°',
                    colors,
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: colors.border,
                ),
                Expanded(
                  child: _coordItem(
                    'Longitude',
                    '${widget.weather.lon}°',
                    colors,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 580.ms, duration: 350.ms)
        .slideY(begin: 0.08, end: 0, delay: 580.ms);
  }

  Widget _coordItem(String label, String value, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: colors.textTertiary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapsButton(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _mapsPressed = true),
        onTapUp: (_) {
          setState(() => _mapsPressed = false);
          _openGoogleMaps();
        },
        onTapCancel: () => setState(() => _mapsPressed = false),
        child: AnimatedScale(
          scale: _mapsPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: colors.accent,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: colors.accent.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.map_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  'Voir sur Google Maps',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.open_in_new_rounded,
                  color: Colors.white70,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 650.ms, duration: 350.ms)
        .slideY(begin: 0.08, end: 0, delay: 650.ms);
  }
}
