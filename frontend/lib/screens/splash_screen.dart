// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (authState.isAuthenticated) {
      if (authState.isProfileComplete) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/profile-setup');
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _opacity,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Title
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1000),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: AppTheme.phantomGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.secondaryNeon.withOpacity(0.6),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '💫',
                              style: AppTheme.textTheme.displayLarge,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // App Name
                  ShaderMask(
                    shaderCallback: (bounds) => AppTheme.neonGradient.createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                    child: Text(
                      'BlindMeet',
                      style: AppTheme.textTheme.displayMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    'Dark Fantasy Dating',
                    style: AppTheme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Loading Indicator
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 2 * 3.14159),
                    duration: const Duration(seconds: 2),
                    builder: (context, value, child) {
                      return Transform.rotate(
                        angle: value,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.phantomGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentNeon.withOpacity(0.4),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: const SizedBox.shrink(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
