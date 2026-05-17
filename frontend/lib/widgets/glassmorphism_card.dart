// lib/widgets/glassmorphism_card.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/theme.dart';

class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final double opacity;
  final VoidCallback? onTap;
  final bool isNeon;

  const GlassmorphismCard({
    Key? key,
    required this.child,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
    this.opacity = 0.1,
    this.onTap,
    this.isNeon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardDark.withOpacity(opacity),
            border: Border.all(
              color: isNeon ? AppTheme.secondaryNeon : AppTheme.tertiaryNeon,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: isNeon ? AppTheme.neonShadow : AppTheme.glassBoxShadow,
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}
