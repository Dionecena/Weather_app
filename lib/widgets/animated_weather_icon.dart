import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'weather_background.dart';

/// Animated weather icon with glow effect and subtle pulse animation
class AnimatedWeatherIcon extends StatelessWidget {
  final String iconCode;
  final double size;
  final bool showGlow;
  final bool animate;

  const AnimatedWeatherIcon({
    super.key,
    required this.iconCode,
    this.size = 80,
    this.showGlow = true,
    this.animate = true,
  });

  Color _glowColor(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.sunny:
        return const Color(0xFFffd200);
      case WeatherCondition.cloudy:
        return const Color(0xFF74b9ff);
      case WeatherCondition.rainy:
        return const Color(0xFF3498db);
      case WeatherCondition.stormy:
        return const Color(0xFF6c5ce7);
      case WeatherCondition.snowy:
        return const Color(0xFFa8d8ea);
      case WeatherCondition.night:
        return const Color(0xFF2d3561);
      case WeatherCondition.default_:
        return const Color(0xFF4facfe);
    }
  }

  @override
  Widget build(BuildContext context) {
    final condition = conditionFromIcon(iconCode);
    final glowColor = _glowColor(condition);

    Widget icon = Image.network(
      'https://openweathermap.org/img/wn/$iconCode@4x.png',
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.cloud_rounded,
          size: size,
          color: Colors.white,
        );
      },
    );

    if (showGlow) {
      icon = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.5),
              blurRadius: size * 0.5,
              spreadRadius: size * 0.1,
            ),
            BoxShadow(
              color: glowColor.withValues(alpha: 0.25),
              blurRadius: size * 0.8,
              spreadRadius: size * 0.2,
            ),
          ],
        ),
        child: icon,
      );
    }

    if (animate) {
      return icon
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1.05, 1.05),
            duration: 3000.ms,
            curve: Curves.easeInOut,
          );
    }

    return icon;
  }
}
