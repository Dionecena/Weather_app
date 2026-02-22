import 'package:flutter/material.dart';
import 'package:examen/models/weather.dart';
import 'package:examen/screens/city_detail_screen.dart';
import 'package:examen/screens/loading_screen.dart';
import 'package:examen/main.dart';

class WeatherTableScreen extends StatelessWidget {
  final List<Weather> weatherData;

  const WeatherTableScreen({super.key, required this.weatherData});

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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoadingScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: weatherData.length,
        itemBuilder: (context, index) {
          final weather = weatherData[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CityDetailScreen(weather: weather),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Image.network(
                      'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                      width: 60,
                      height: 60,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.cloud, size: 60);
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            weather.cityName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            weather.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white54 : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.water_drop, size: 14, color: Colors.blue.shade300),
                              const SizedBox(width: 4),
                              Text('${weather.humidity.toInt()}%',
                                  style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 16),
                              Icon(Icons.air, size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text('${weather.windSpeed} m/s',
                                  style: const TextStyle(fontSize: 12)),
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
                        color: isDark ? const Color(0xFF4facfe) : const Color(0xFF4facfe),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: isDark ? Colors.white38 : Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
