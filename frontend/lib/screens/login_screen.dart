// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/neon_gradient_button.dart';
import '../widgets/glassmorphism_card.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _adminEmailController = TextEditingController();
  final TextEditingController _adminPasswordController = TextEditingController();
  bool _showEmailForm = false;
  bool _showAdminForm = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated && !next.isLoading) {
        if (next.role == 'admin') {
          Navigator.of(context).pushReplacementNamed('/admin');
        } else if (next.isProfileComplete) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          Navigator.of(context).pushReplacementNamed('/profile-setup');
        }
      }

      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error ?? 'An error occurred'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }

      if (next.message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message ?? ''),
            backgroundColor: AppTheme.accentNeon,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header Section
                Column(
                  children: [
                    GestureDetector(
                      onLongPress: () => setState(() {
                        _showAdminForm = true;
                        _showEmailForm = false;
                      }),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: AppTheme.phantomGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.secondaryNeon.withOpacity(0.5),
                              blurRadius: 25,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '💝',
                            style: TextStyle(fontSize: 50),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ShaderMask(
                      shaderCallback: (bounds) => AppTheme.neonGradient.createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                      child: Text(
                        'BlindMeet',
                        style: AppTheme.textTheme.displayMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Find Your Perfect Match in the Dark',
                      style: AppTheme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                GlassmorphismCard(
                  padding: const EdgeInsets.all(32),
                  isNeon: true,
                  child: Column(
                    children: [
                      Text(
                        _showAdminForm
                            ? 'Admin Sign In'
                            : _showEmailForm
                                ? 'Email OTP Login'
                                : 'Welcome Back',
                        style: AppTheme.textTheme.headlineSmall?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _showAdminForm
                            ? 'Enter admin credentials to manage the platform'
                            : _showEmailForm
                                ? 'Enter your email to receive a one-time code'
                                : 'Sign in to continue your journey',
                        style: AppTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      if (!_showEmailForm && !_showAdminForm) ...[
                        NeonGradientButton(
                          text: authState.isLoading
                              ? 'Signing in...'
                              : 'Continue with Google',
                          onPressed: () => ref.read(authProvider.notifier).googleLogin(),
                          isLoading: authState.isLoading,
                        ),
                        const SizedBox(height: 16),
                        NeonGradientButton(
                          text: 'Login with Email OTP',
                          onPressed: () => setState(() => _showEmailForm = true),
                        ),
                      ],

                      if (_showEmailForm) ...[
                        TextField(
                          controller: _emailController,
                          style: TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.cardDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        NeonGradientButton(
                          text: 'Send OTP',
                          onPressed: () {
                            ref.read(authProvider.notifier).requestEmailOtp(_emailController.text.trim());
                          },
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            'Note: If this email is not registered, sending an OTP will create an account automatically.',
                            style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _otpController,
                          style: TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'OTP Code',
                            labelStyle: TextStyle(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.cardDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        NeonGradientButton(
                          text: 'Verify OTP',
                          onPressed: () {
                            ref.read(authProvider.notifier).verifyEmailOtp(
                                  _emailController.text.trim(),
                                  _otpController.text.trim(),
                                );
                          },
                          isLoading: authState.isLoading,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => setState(() {
                            _showEmailForm = false;
                            _emailController.clear();
                            _otpController.clear();
                          }),
                          child: Text(
                            'Back to main login',
                            style: TextStyle(color: AppTheme.accentNeon),
                          ),
                        ),
                      ],

                      if (_showAdminForm) ...[
                        TextField(
                          controller: _adminEmailController,
                          style: TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Admin Email',
                            labelStyle: TextStyle(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.cardDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _adminPasswordController,
                          obscureText: true,
                          style: TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.cardDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        NeonGradientButton(
                          text: authState.isLoading ? 'Signing in...' : 'Admin Sign In',
                          onPressed: () {
                            ref.read(authProvider.notifier).adminLogin(
                                  email: _adminEmailController.text.trim(),
                                  password: _adminPasswordController.text.trim(),
                                );
                          },
                          isLoading: authState.isLoading,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => setState(() {
                            _showAdminForm = false;
                            _adminEmailController.clear();
                            _adminPasswordController.clear();
                          }),
                          child: Text(
                            'Back to main login',
                            style: TextStyle(color: AppTheme.accentNeon),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Info Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GlassmorphismCard(
                    padding: const EdgeInsets.all(16),
                    opacity: 0.05,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.accentNeon.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  '🔒',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your privacy is our priority',
                                style: AppTheme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryNeon.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  '⚡',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Real-time connections and messaging',
                                style: AppTheme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
