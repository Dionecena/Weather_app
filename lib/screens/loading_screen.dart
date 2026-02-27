import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:examen/models/weather.dart';
import 'package:examen/services/weather_service.dart';
import 'package:examen/main.dart';
import 'package:examen/routes/app_routes.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
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
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
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
      _weatherData = [];
    });
    if (!_spinController.isAnimating) _spinController.repeat();

    _progressTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
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
      _spinController.stop();

      setState(() {
        _weatherData = data;
        _progress = 1.0;
        _isLoading = false;
        _showBoom = true;
      });

      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() {
        _showBoom = false;
        _showSuccessContent = true;
      });
    } catch (e) {
      if (!mounted) return;
      _progressTimer?.cancel();
      _messageTimer?.cancel();
      _spinController.stop();
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
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(colors, isDark),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: _buildBody(colors, isDark),
                  ),
                ),
              ],
            ),
            if (_showBoom) _buildBoomOverlay(colors),
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
          const SizedBox(width: 14),
          Text(
            'Chargement',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
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

  Widget _buildBody(AppColors colors, bool isDark) {
    if (_hasError) return _buildErrorState(colors);
    if (_isLoading) return _buildLoadingState(colors);
    if (_showSuccessContent) return _buildSuccessState(colors);
    return _buildLoadingState(colors);
  }

  Widget _buildBoomOverlay(AppColors colors) {
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Center(
            child: Container(
              width: 120 * value,
              height: 120 * value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.accent.withValues(alpha: 0.1 * value),
                border: Border.all(
                  color: colors.accent.withValues(alpha: 0.4 * value),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 48 * value,
                color: colors.accent.withValues(alpha: value),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(AppColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Gauge
        AnimatedBuilder(
          animation: _spinController,
          builder: (context, child) {
            return SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(200, 200),
                    painter: _MinimalGaugePainter(
                      progress: _progress,
                      spinValue: _isLoading ? _spinController.value : 0,
                      accentColor: colors.accent,
                      trackColor: colors.border,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(_progress * 100).toInt()}',
                        style: GoogleFonts.outfit(
                          fontSize: 44,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                          height: 1.0,
                          letterSpacing: -2,
                        ),
                      ),
                      Text(
                        '%',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: colors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 48),
        // Rotating messages
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
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
            style: GoogleFonts.inter(
              fontSize: 14,
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Progress dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final isActive = i == _messageIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 16 : 5,
              height: 5,
              decoration: BoxDecoration(
                color: isActive ? colors.accent : colors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSuccessState(AppColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Success gauge (full)
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(200, 200),
                painter: _MinimalGaugePainter(
                  progress: 1.0,
                  spinValue: 0,
                  accentColor: colors.accent,
                  trackColor: colors.border,
                ),
              ),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.accent.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: colors.accent,
                  size: 32,
                ),
              ),
            ],
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.85, 0.85),
              end: const Offset(1.0, 1.0),
              curve: Curves.elasticOut,
              duration: 600.ms,
            )
            .fadeIn(duration: 300.ms),
        const SizedBox(height: 32),
        Text(
          'Données chargées avec succès !',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .slideY(begin: 0.1, end: 0, delay: 200.ms),
        const SizedBox(height: 8),
        Text(
          '${_weatherData.length} villes chargées',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: colors.textTertiary,
          ),
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 400.ms),
        const SizedBox(height: 48),
        // Primary CTA
        GestureDetector(
          onTap: () => AppRoutes.toWeatherTable(context, _weatherData),
          child: Container(
            width: double.infinity,
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
                Text(
                  'Voir les résultats',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 350.ms, duration: 400.ms)
            .slideY(begin: 0.1, end: 0, delay: 350.ms),
        const SizedBox(height: 12),
        // Recommencer
        GestureDetector(
          onTap: _startLoading,
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  color: colors.textSecondary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recommencer',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 450.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildErrorState(AppColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFEF4444).withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.wifi_off_rounded,
            color: Color(0xFFEF4444),
            size: 36,
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.7, 0.7),
              end: const Offset(1.0, 1.0),
              curve: Curves.elasticOut,
              duration: 500.ms,
            ),
        const SizedBox(height: 24),
        Text(
          'Une erreur est survenue',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
        const SizedBox(height: 8),
        Text(
          _errorMessage.contains('Exception:')
              ? _errorMessage.replaceFirst('Exception: ', '')
              : _errorMessage,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: colors.textSecondary,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
        const SizedBox(height: 6),
        Text(
          'Vérifiez votre connexion et réessayez.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: colors.textTertiary,
          ),
        ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
        const SizedBox(height: 36),
        GestureDetector(
          onTap: _startLoading,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded,
                    color: colors.textSecondary, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Réessayer',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 450.ms, duration: 400.ms)
            .slideY(begin: 0.1, end: 0, delay: 450.ms),
      ],
    );
  }
}

/// Minimal clean gauge painter
class _MinimalGaugePainter extends CustomPainter {
  final double progress;
  final double spinValue;
  final Color accentColor;
  final Color trackColor;

  _MinimalGaugePainter({
    required this.progress,
    required this.spinValue,
    required this.accentColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 10;
    const strokeWidth = 6.0;

    // Track ring
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final progressPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);

    // Spinning indicator dot (only when loading)
    if (progress < 1.0 && spinValue > 0) {
      final spinAngle = startAngle + spinValue * 2 * math.pi;
      final dotPos = Offset(
        center.dx + radius * math.cos(spinAngle),
        center.dy + radius * math.sin(spinAngle),
      );
      final dotPaint = Paint()
        ..color = accentColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(dotPos, 5, dotPaint);

      final dotCorePaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(dotPos, 3, dotCorePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MinimalGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.spinValue != spinValue;
  }
}
