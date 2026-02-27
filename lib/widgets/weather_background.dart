import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Weather condition type for background theming
enum WeatherCondition {
  sunny,
  cloudy,
  rainy,
  stormy,
  snowy,
  night,
  default_,
}

/// Returns the weather condition from an OpenWeatherMap icon code
WeatherCondition conditionFromIcon(String icon) {
  final isNight = icon.endsWith('n');
  final code = icon.replaceAll('d', '').replaceAll('n', '');
  if (isNight) return WeatherCondition.night;
  switch (code) {
    case '01':
      return WeatherCondition.sunny;
    case '02':
    case '03':
    case '04':
      return WeatherCondition.cloudy;
    case '09':
    case '10':
      return WeatherCondition.rainy;
    case '11':
      return WeatherCondition.stormy;
    case '13':
      return WeatherCondition.snowy;
    default:
      return WeatherCondition.default_;
  }
}

/// Returns gradient colors for a given weather condition
List<Color> gradientForCondition(WeatherCondition condition, bool isDark) {
  if (isDark) {
    switch (condition) {
      case WeatherCondition.sunny:
        return [const Color(0xFF1a1200), const Color(0xFF2d1f00), const Color(0xFF0d0d1a)];
      case WeatherCondition.cloudy:
        return [const Color(0xFF0d1117), const Color(0xFF1a2030), const Color(0xFF0a0f1a)];
      case WeatherCondition.rainy:
        return [const Color(0xFF0a0f1a), const Color(0xFF0d1a2e), const Color(0xFF060d1a)];
      case WeatherCondition.stormy:
        return [const Color(0xFF0a0a14), const Color(0xFF14141e), const Color(0xFF080810)];
      case WeatherCondition.snowy:
        return [const Color(0xFF0d1a2e), const Color(0xFF1a2a3e), const Color(0xFF0a1020)];
      case WeatherCondition.night:
        return [const Color(0xFF020408), const Color(0xFF0a0f1a), const Color(0xFF050810)];
      case WeatherCondition.default_:
        return [const Color(0xFF0c0c1d), const Color(0xFF1a1a3e), const Color(0xFF0a0a1a)];
    }
  } else {
    switch (condition) {
      case WeatherCondition.sunny:
        return [const Color(0xFFf7971e), const Color(0xFFffd200), const Color(0xFFff6b35)];
      case WeatherCondition.cloudy:
        return [const Color(0xFF667eea), const Color(0xFF764ba2), const Color(0xFF4facfe)];
      case WeatherCondition.rainy:
        return [const Color(0xFF2c3e50), const Color(0xFF3498db), const Color(0xFF1a252f)];
      case WeatherCondition.stormy:
        return [const Color(0xFF1c1c2e), const Color(0xFF2d2d44), const Color(0xFF16213e)];
      case WeatherCondition.snowy:
        return [const Color(0xFF74b9ff), const Color(0xFFa8d8ea), const Color(0xFF4facfe)];
      case WeatherCondition.night:
        return [const Color(0xFF0c0c1d), const Color(0xFF1a1a3e), const Color(0xFF0a0a1a)];
      case WeatherCondition.default_:
        return [const Color(0xFF667eea), const Color(0xFF764ba2), const Color(0xFF4facfe)];
    }
  }
}

/// Animated gradient background with floating particles
class WeatherBackground extends StatefulWidget {
  final WeatherCondition condition;
  final bool isDark;
  final Widget child;
  final bool showParticles;

  const WeatherBackground({
    super.key,
    required this.condition,
    required this.isDark,
    required this.child,
    this.showParticles = true,
  });

  @override
  State<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _particleController;
  late List<_Particle> _particles;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _particles = List.generate(12, (_) => _Particle.random(_random));
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = gradientForCondition(widget.condition, widget.isDark);

    return AnimatedBuilder(
      animation: Listenable.merge([_gradientController, _particleController]),
      builder: (context, _) {
        return Stack(
          children: [
            // Animated gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                  stops: [
                    0.0,
                    0.5 + _gradientController.value * 0.2,
                    1.0,
                  ],
                ),
              ),
            ),
            // Floating particles
            if (widget.showParticles)
              CustomPaint(
                painter: _ParticlePainter(
                  particles: _particles,
                  progress: _particleController.value,
                  condition: widget.condition,
                  isDark: widget.isDark,
                ),
                size: Size.infinite,
              ),
            // Subtle radial glow overlay
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    Colors.white.withValues(alpha: widget.isDark ? 0.03 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            widget.child,
          ],
        );
      },
    );
  }
}

class _Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;
  double angle;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.angle,
  });

  factory _Particle.random(math.Random random) {
    return _Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      size: random.nextDouble() * 60 + 20,
      speed: random.nextDouble() * 0.3 + 0.05,
      opacity: random.nextDouble() * 0.12 + 0.03,
      angle: random.nextDouble() * math.pi * 2,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final WeatherCondition condition;
  final bool isDark;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.condition,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final animatedY = (particle.y + progress * particle.speed) % 1.0;
      final animatedX = particle.x +
          math.sin(progress * math.pi * 2 + particle.angle) * 0.02;

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      final cx = animatedX * size.width;
      final cy = animatedY * size.height;

      if (condition == WeatherCondition.rainy ||
          condition == WeatherCondition.stormy) {
        // Draw rain drops
        final path = Path();
        path.moveTo(cx, cy);
        path.lineTo(cx - 1, cy + particle.size * 0.4);
        path.lineTo(cx + 1, cy + particle.size * 0.4);
        path.close();
        canvas.drawPath(path, paint);
      } else if (condition == WeatherCondition.snowy) {
        // Draw snowflakes
        _drawSnowflake(canvas, cx, cy, particle.size * 0.3, paint);
      } else {
        // Draw cloud-like circles
        canvas.drawCircle(
          Offset(cx, cy),
          particle.size * 0.5,
          paint,
        );
        canvas.drawCircle(
          Offset(cx + particle.size * 0.3, cy - particle.size * 0.1),
          particle.size * 0.35,
          paint,
        );
        canvas.drawCircle(
          Offset(cx - particle.size * 0.25, cy + particle.size * 0.05),
          particle.size * 0.3,
          paint,
        );
      }
    }
  }

  void _drawSnowflake(Canvas canvas, double cx, double cy, double r, Paint paint) {
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)),
        paint..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
