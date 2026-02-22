import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:examen/main.dart';
import 'package:examen/models/weather.dart';
import 'package:examen/routes/app_routes.dart';
import 'package:examen/screens/city_detail_screen.dart';

class WeatherTableScreen extends StatefulWidget {
  final List<Weather> weatherData;

  const WeatherTableScreen({super.key, required this.weatherData});

  @override
  State<WeatherTableScreen> createState() => _WeatherTableScreenState();
}

class _WeatherTableScreenState extends State<WeatherTableScreen> {
  int? _pressedIndex;

  static List<Color> _gradientColorsForTemp(double temp, bool isDark) {
    if (temp < 10) {
      return isDark
          ? [const Color(0xFF1e3a5f), const Color(0xFF0d2137)]
          : [const Color(0xFFa8d8ea), const Color(0xFF7eb8d4)];
    }
    if (temp < 20) {
      return isDark
          ? [const Color(0xFF1a2e4a), const Color(0xFF16213e)]
          : [const Color(0xFFb8e0d2), const Color(0xFF8fc9b4)];
    }
    if (temp < 30) {
      return isDark
          ? [const Color(0xFF2d2416), const Color(0xFF1e1810)]
          : [const Color(0xFFffeaa7), const Color(0xFFfdcb6e)];
    }
    return isDark
        ? [const Color(0xFF3d2a1a), const Color(0xFF2d1f14)]
        : [const Color(0xFFff9f43), const Color(0xFFee5a24)];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Météo des villes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => MyApp.of(context)?.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Recommencer l\'expérience',
            onPressed: () => AppRoutes.restartToLoading(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.weatherData.length,
        itemBuilder: (context, index) {
          final weather = widget.weatherData[index];
          final isPressed = _pressedIndex == index;
          return GestureDetector(
            onTapDown: (_) => setState(() => _pressedIndex = index),
            onTapUp: (_) => setState(() => _pressedIndex = null),
            onTapCancel: () => setState(() => _pressedIndex = null),
            onTap: () => AppRoutes.toCityDetail(context, weather),
            child: AnimatedScale(
              scale: isPressed ? 0.98 : 1.0,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: Colors.transparent,
                elevation: 6,
                shadowColor: Colors.black.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _gradientColorsForTemp(
                          weather.temperature, isDark),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'weather_${weather.cityName}',
                          child: Image.network(
                            'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                            width: 60,
                            height: 60,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.cloud_rounded, size: 60);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weather.cityName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.grey.shade900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                weather.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.water_drop_rounded,
                                    size: 14,
                                    color: isDark
                                        ? Colors.blue.shade200
                                        : Colors.blue.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${weather.humidity.toInt()}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.air_rounded,
                                    size: 14,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${weather.windSpeed} m/s',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${weather.temperature.toStringAsFixed(1)}°C',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : Colors.grey.shade900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: isDark ? Colors.white54 : Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: (index * 80).ms, duration: 400.ms)
                .slideY(begin: 0.15, end: 0, curve: Curves.easeOut, delay: (index * 80).ms),
          );
        },
      ),
    );
  }
}
