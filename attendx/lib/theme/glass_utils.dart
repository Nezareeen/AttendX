import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool showBorder;
  final bool showGradientBorder;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blurSigma = 15,
    this.opacity = 0.15,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.showBorder = true,
    this.showGradientBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget glassContent = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: showBorder && !showGradientBorder
                ? Border.all(
                    color: AppColors.glassBorder,
                    width: 1.5,
                  )
                : null,
          ),
          child: child,
        ),
      ),
    );

    if (showGradientBorder) {
      glassContent = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius + 1.5),
          gradient: AppColors.primaryGradient,
        ),
        padding: const EdgeInsets.all(1.5),
        child: glassContent,
      );
    }

    if (margin != null) {
      return Padding(padding: margin!, child: glassContent);
    }

    return glassContent;
  }
}

/// A small glass pill often used for status badges, tags, etc.
class GlassPill extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const GlassPill({
    super.key,
    required this.child,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: (color ?? Colors.white).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: (color ?? Colors.white).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
