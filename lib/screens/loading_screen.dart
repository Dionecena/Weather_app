import 'dart:async';
import 'package:flutter/material.dart';
import 'package:examen/models/weather.dart';
import 'package:examen/services/weather_service.dart';
import 'package:examen/main.dart';
import 'package:examen/routes/app_routes.dart';
import 'package:examen/widgets/circular_gauge.dart';

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
  bool _showBoom = false;
  bool _showSuccessContent = false;

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
      _showBoom = false;
      _showSuccessContent = false;
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
        _showBoom = true;
      });

      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() {
        _showBoom = false;
        _showSuccessContent = true;
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

  Widget _buildGradientBackground(bool isDark) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
              : [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          _buildGradientBackground(isDark),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: const Text('Chargement'),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _buildBody(isDark),
                  ),
                ),
              ],
            ),
          ),
          if (_showBoom) _buildBoomOverlay(isDark),
        ],
      ),
    );
  }

  Widget _buildBoomOverlay(bool isDark) {
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 350),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Center(
            child: Container(
              width: 160 * value,
              height: 160 * value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? Colors.blue.shade300 : Colors.white)
                    .withValues(alpha: 0.4 * (1 - value)),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 80 * value,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_hasError) {
      return _buildErrorState(isDark);
    }
    if (_isLoading) {
      return _buildLoadingState(isDark);
    }
    if (_showSuccessContent) {
      return _buildSuccessState(isDark);
    }
    return _buildLoadingState(isDark);
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 80,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Une erreur est survenue',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage.contains('Exception:')
                ? _errorMessage.replaceFirst('Exception: ', '')
                : _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vérifiez votre connexion et réessayez.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _startLoading,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF0f3460) : Colors.white,
              foregroundColor: isDark ? Colors.white : const Color(0xFF4facfe),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularGauge(
          progress: _progress,
          size: 220,
          strokeWidth: 14,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_download_rounded,
                size: 48,
                color: isDark ? Colors.white70 : Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                '${(_progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            );
          },
          child: Text(
            _messages[_messageIndex],
            key: ValueKey<int>(_messageIndex),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularGauge(
          progress: 1.0,
          size: 220,
          strokeWidth: 14,
          child: Icon(
            Icons.check_circle_rounded,
            size: 56,
            color: isDark ? Colors.white70 : Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Données chargées avec succès !',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.white,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => AppRoutes.toWeatherTable(context, _weatherData),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFF0f3460) : Colors.white,
            foregroundColor: isDark ? Colors.white : const Color(0xFF4facfe),
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 8,
          ),
          child: const Text(
            'Voir les résultats',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: _startLoading,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Recommencer'),
          style: TextButton.styleFrom(
            foregroundColor: isDark ? Colors.white70 : Colors.white,
          ),
        ),
      ],
    );
  }
}
