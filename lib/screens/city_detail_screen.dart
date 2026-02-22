import 'package:flutter/material.dart';
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
  Future<void> _openGoogleMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${widget.weather.lat},${widget.weather.lon}',
    );
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url, 
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d\'ouvrir Google Maps'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'ouverture de Google Maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static List<Color> _headerGradientColors(String icon, bool isDark) {
    final isSunny = icon.startsWith('01') || icon.startsWith('02');
    if (isSunny) {
      return isDark
          ? [const Color(0xFF2d2416), const Color(0xFF1e1810)]
          : [const Color(0xFFffeaa7), const Color(0xFFfdcb6e)];
    }
    return isDark
        ? [const Color(0xFF1a2e4a), const Color(0xFF16213e)]
        : [const Color(0xFF74b9ff), const Color(0xFF0984e3)];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.weather.cityName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => MyApp.of(context)?.toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _headerGradientColors(widget.weather.icon, isDark),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Hero(
                    tag: 'weather_${widget.weather.cityName}',
                    child: Image.network(
                      'https://openweathermap.org/img/wn/${widget.weather.icon}@4x.png',
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.cloud_rounded,
                          size: 120,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${widget.weather.temperature.toStringAsFixed(1)}°C',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.weather.description,
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildInfoRow(
                        context, Icons.thermostat_rounded, 'Température', '${widget.weather.temperature.toStringAsFixed(1)}°C'),
                    const Divider(height: 24),
                    _buildInfoRow(
                        context, Icons.water_drop_rounded, 'Humidité', '${widget.weather.humidity.toInt()}%'),
                    const Divider(height: 24),
                    _buildInfoRow(
                        context, Icons.air_rounded, 'Vent', '${widget.weather.windSpeed} m/s'),
                    const Divider(height: 24),
                    _buildInfoRow(
                        context, Icons.location_on_rounded, 'Latitude', '${widget.weather.lat}'),
                    const Divider(height: 24),
                    _buildInfoRow(
                        context, Icons.location_on_rounded, 'Longitude', '${widget.weather.lon}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openGoogleMaps,
                icon: const Icon(Icons.map_rounded),
                label: const Text(
                  'Voir sur Google Maps',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 24, color: colorScheme.primary),
        const SizedBox(width: 16),
        Text(label, style: const TextStyle(fontSize: 16)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
