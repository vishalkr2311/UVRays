// lib/widgets/neon_gradient_button.dart

import 'package:flutter/material.dart';
import '../theme/theme.dart';

class NeonGradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double width;
  final double height;
  final bool isSecondary;

  const NeonGradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width = double.infinity,
    this.height = 50,
    this.isSecondary = false,
  }) : super(key: key);

  @override
  State<NeonGradientButton> createState() => _NeonGradientButtonState();
}

class _NeonGradientButtonState extends State<NeonGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.isSecondary
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.tertiaryNeon.withOpacity(0.8),
                      AppTheme.secondaryNeon.withOpacity(0.8),
                    ],
                  )
                : AppTheme.neonGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.isSecondary
                    ? AppTheme.secondaryNeon.withOpacity(0.5)
                    : AppTheme.accentNeon.withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.isSecondary
                            ? AppTheme.textPrimary
                            : AppTheme.textPrimary,
                      ),
                    ),
                  )
                : Text(
                    widget.text,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}
