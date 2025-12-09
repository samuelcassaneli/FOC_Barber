import 'dart:ui';
import 'package:flutter/material.dart';

class AppleGlassContainer extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double blur;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const AppleGlassContainer({
    super.key,
    required this.child,
    this.opacity = 0.65, // Higher opacity for "Dark Mode" material feel
    this.blur = 20.0,
    this.borderRadius,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(20);
    
    Widget container = ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E).withOpacity(opacity),
            borderRadius: br,
            border: Border.all(
              color: Colors.white.withOpacity(0.08), // Subtle inner stroke
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}
