import 'dart:ui';
import 'package:flutter/material.dart';

/// A premium frosted glass card widget using BackdropFilter.
class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final double blurX;
  final double blurY;
  final double opacity;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final double? width;
  final double? height;
  final Gradient? gradient;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.blurX = 12.0,
    this.blurY = 12.0,
    this.opacity = 0.15,
    this.borderRadius = 20.0,
    this.borderColor,
    this.borderWidth = 1.0,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.boxShadow,
    this.width,
    this.height,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBorderColor = borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.4));
    final effectiveBgColor = backgroundColor ??
        (isDark
            ? Colors.white.withValues(alpha: opacity * 0.6)
            : Colors.white.withValues(alpha: opacity));

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurX, sigmaY: blurY),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              color: gradient == null ? effectiveBgColor : null,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: effectiveBorderColor,
                width: borderWidth,
              ),
              boxShadow: boxShadow ??
                  [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
            ),
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}
