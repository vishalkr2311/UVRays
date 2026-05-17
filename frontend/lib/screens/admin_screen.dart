// lib/screens/admin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/glassmorphism_card.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppTheme.cardDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      backgroundColor: AppTheme.darkBg,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassmorphismCard(
              padding: const EdgeInsets.all(24),
              isNeon: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Admin',
                    style: AppTheme.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Use the controls below for user management and broadcasts.',
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (authState.user != null)
                    Text(
                      'Signed in as: ${authState.user!.email}',
                      style: AppTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.accentNeon,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _AdminActionCard(
                    icon: Icons.dashboard,
                    label: 'Dashboard stats',
                    onTap: () {},
                  ),
                  _AdminActionCard(
                    icon: Icons.people,
                    label: 'Active users',
                    onTap: () {},
                  ),
                  _AdminActionCard(
                    icon: Icons.campaign,
                    label: 'Broadcast message',
                    onTap: () {},
                  ),
                  _AdminActionCard(
                    icon: Icons.person_remove,
                    label: 'Delete profile',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AdminActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphismCard(
        padding: const EdgeInsets.all(16),
        isNeon: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.accentNeon, size: 40),
            const SizedBox(height: 16),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
