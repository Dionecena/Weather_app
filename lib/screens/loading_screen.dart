import 'dart:async';
import 'package:flutter/material.dart';
import 'package:examen/models/weather.dart';
import 'package:examen/services/weather_service.dart';
import 'package:examen/screens/weather_table_screen.dart';
import 'package:examen/main.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double _progress = 0.0;
  int _messageIndex = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<Weather> _weatherData = [];

  final List<String> _messages = [
    'Nous téléchargeons les données...',
    'C\'est presque fini...',
    'Plus que quelques secondes avant d\'avoir le résultat...',
  ];

  Timer? _progressTimer;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    setState(() {
      _progress = 0.0;
      _messageIndex = 0;
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _progress += 0.02;
        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();
        }
      });
    });

    _messageTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _messageIndex = (_messageIndex + 1) % _messages.length;
      });
    });

    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await WeatherService.fetchAllCities();
      if (!mounted) return;

      _progressTimer?.cancel();
      _messageTimer?.cancel();

      setState(() {
        _weatherData = data;
        _progress = 1.0;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      _progressTimer?.cancel();
      _messageTimer?.cancel();

      setState(() {
        _hasError = true;
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chargement'),
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
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_hasError) ...[
              Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                'Une erreur est survenue',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _startLoading,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ] else if (_isLoading) ...[
              Icon(
                Icons.cloud_download,
                size: 80,
                color: isDark ? Colors.white70 : const Color(0xFF4facfe),
              ),
              const SizedBox(height: 32),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 12,
                  backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? const Color(0xFF4facfe) : const Color(0xFF4facfe),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(_progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _messages[_messageIndex],
                  key: ValueKey<int>(_messageIndex),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ),
              ),
            ] else ...[
              Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'Données chargées avec succès !',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeatherTableScreen(weatherData: _weatherData),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Voir les résultats',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _startLoading,
                icon: const Icon(Icons.refresh),
                label: const Text('Recommencer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
