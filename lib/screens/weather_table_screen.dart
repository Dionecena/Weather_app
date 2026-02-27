import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:examen/main.dart';
import 'package:examen/models/weather.dart';
import 'package:examen/routes/app_routes.dart';

class WeatherTableScreen extends StatefulWidget {
  final List<Weather> weatherData;

  const WeatherTableScreen({super.key, required this.weatherData});

  @override
  State<WeatherTableScreen> createState() => _WeatherTableScreenState();
}

class _WeatherTableScreenState extends State<WeatherTableScreen> {
  int? _pressedIndex;
  final DateTime _loadedAt = DateTime.now();

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Returns a subtle accent color based on temperature
  Color _tempColor(double temp) {
    if (temp < 15) return const Color(0xFF60A5FA); // cool blue
    if (temp < 25) return const Color(0xFF34D399); // green
    if (temp < 32) return const Color(0xFFFBBF24); // amber
    return const Color(0xFFF87171); // red
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(colors, isDark),
            _buildHeader(colors),
            Expanded(
              child: _buildList(colors),
            ),
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
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => AppRoutes.restartToLoading(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: colors.textSecondary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Météo des villes',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              letterSpacing: -0.8,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${widget.weatherData.length} villes • Sénégal',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: colors.textTertiary,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textTertiary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 11,
                    color: colors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Mis à jour à ${_formatTime(_loadedAt)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 80.ms, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildList(AppColors colors) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
      itemCount: widget.weatherData.length,
      itemBuilder: (context, index) {
        final weather = widget.weatherData[index];
        final isPressed = _pressedIndex == index;
        final tempColor = _tempColor(weather.temperature);

        return GestureDetector(
          onTapDown: (_) => setState(() => _pressedIndex = index),
          onTapUp: (_) {
            setState(() => _pressedIndex = null);
            AppRoutes.toCityDetail(context, weather);
          },
          onTapCancel: () => setState(() => _pressedIndex = null),
          child: AnimatedScale(
            scale: isPressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: _buildCard(weather, tempColor, colors),
          ),
        )
            .animate()
            .fadeIn(delay: (index * 70).ms, duration: 350.ms)
            .slideY(
              begin: 0.08,
              end: 0,
              curve: Curves.easeOut,
              delay: (index * 70).ms,
            );
      },
    );
  }

  Widget _buildCard(Weather weather, Color tempColor, AppColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Row(
        children: [
          // Weather icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: tempColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Hero(
              tag: 'weather_${weather.cityName}',
              child: Image.network(
                'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.cloud_rounded,
                    size: 28,
                    color: tempColor,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weather.cityName,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  weather.description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: colors.textTertiary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _miniStat(
                      Icons.water_drop_rounded,
                      '${weather.humidity.toInt()}%',
                      colors,
                    ),
                    const SizedBox(width: 12),
                    _miniStat(
                      Icons.air_rounded,
                      '${weather.windSpeed.toStringAsFixed(1)} m/s',
                      colors,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Temperature
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${weather.temperature.toStringAsFixed(1)}°',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: tempColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'C',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: colors.textTertiary,
                ),
              ),
              const SizedBox(height: 10),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.textTertiary,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String value, AppColors colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: colors.textTertiary),
        const SizedBox(width: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
