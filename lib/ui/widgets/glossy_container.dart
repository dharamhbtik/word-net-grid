import 'dart:ui';
import 'package:flutter/material.dart';

class GlossyContainer extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;
  
  const GlossyContainer({
    super.key,
    required this.child,
    this.opacity = 0.2,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ?? Border.all(
                color: Colors.white.withOpacity(0.2), // Lighter, distinct border
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(opacity + 0.15), // Highlight
                  Colors.white.withOpacity(opacity * 0.5),  // See-through
                ],
                stops: const [0.1, 0.9],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
