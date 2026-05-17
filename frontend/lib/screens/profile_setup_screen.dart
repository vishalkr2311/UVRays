// lib/screens/profile_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/neon_gradient_button.dart';
import '../widgets/glassmorphism_card.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late PageController _pageController;
  int _currentPage = 0;

  // Form fields
  final _nicknameController = TextEditingController();
  String? _selectedGender;
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedSkinColor;
  final _weightController = TextEditingController();
  String? _selectedProfession;
  String? _selectedAlcoholic;
  final _bioController = TextEditingController();

  final _genders = ['Male', 'Female', 'Gay', 'Lesbian', 'Bisexual'];
  final _skinColors = ['Fair', 'Dark', 'Dusky', 'Brown', 'White'];
  final _professions = ['Student', 'Working Professional', 'House Wife'];
  final _alcoholicOptions = ['Yes', 'No'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nicknameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _weightController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _submitProfile();
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitProfile() {
    if (_formKey.currentState!.validate()) {
      final profileData = {
        'nickname': _nicknameController.text,
        'gender': _selectedGender,
        'age': int.parse(_ageController.text),
        'location': _locationController.text,
        'skinColor': _selectedSkinColor,
        'weight': double.parse(_weightController.text),
        'profession': _selectedProfession,
        'alcoholic': _selectedAlcoholic,
        'bio': _bioController.text,
      };

      ref.read(profileProvider.notifier).createProfile(profileData);

      ref.listen(profileProvider, (previous, next) {
        if (next.profileUser != null && !next.isLoading) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
        if (next.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.error ?? 'Error'), backgroundColor: AppTheme.errorColor),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Progress Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Your Profile',
                      style: AppTheme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / 4,
                        minHeight: 4,
                        backgroundColor: AppTheme.cardDark,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.accentNeon,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  children: [
                    _buildPage1(), // Basic Info
                    _buildPage2(), // Physical Info
                    _buildPage3(), // Lifestyle
                    _buildPage4(), // Bio & Images
                  ],
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: NeonGradientButton(
                          text: 'Back',
                          onPressed: _goToPreviousPage,
                          isSecondary: true,
                        ),
                      ),
                    if (_currentPage > 0) const SizedBox(width: 12),
                    Expanded(
                      child: NeonGradientButton(
                        text: _currentPage == 3 ? 'Complete' : 'Next',
                        onPressed: _goToNextPage,
                        isLoading: profileState.isLoading,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Basic Information', style: AppTheme.textTheme.headlineSmall),
            const SizedBox(height: 24),
            Text('Nickname', style: AppTheme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nicknameController,
              decoration: InputDecoration(
                hintText: 'Enter your nickname (A-Z, 0-9, _)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Nickname required';
                if (!RegExp(r'^[A-Za-z][A-Za-z0-9_]{0,9}$').hasMatch(value!)) {
                  return 'Invalid format (start with letter, max 10 chars)';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text('Gender', style: AppTheme.textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              items: _genders
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedGender = value),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value == null ? 'Select gender' : null,
            ),
            const SizedBox(height: 24),
            Text('Age', style: AppTheme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter your age (18-60)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Age required';
                final age = int.tryParse(value!);
                if (age == null || age < 18 || age > 60) {
                  return 'Age must be between 18-60';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Physical Information', style: AppTheme.textTheme.headlineSmall),
          const SizedBox(height: 24),
          Text('Location', style: AppTheme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _locationController,
            decoration: InputDecoration(
              hintText: 'City/Location',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) => (value?.isEmpty ?? true) ? 'Location required' : null,
          ),
          const SizedBox(height: 24),
          Text('Skin Color', style: AppTheme.textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedSkinColor,
            items: _skinColors
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (value) => setState(() => _selectedSkinColor = value),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) => value == null ? 'Select skin color' : null,
          ),
          const SizedBox(height: 24),
          Text('Weight (KG)', style: AppTheme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Your weight in KG',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Weight required';
              final weight = double.tryParse(value!);
              if (weight == null || weight <= 0) {
                return 'Enter valid weight';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lifestyle Information', style: AppTheme.textTheme.headlineSmall),
          const SizedBox(height: 24),
          Text('Profession', style: AppTheme.textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedProfession,
            items: _professions
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (value) => setState(() => _selectedProfession = value),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) => value == null ? 'Select profession' : null,
          ),
          const SizedBox(height: 24),
          Text('Alcoholic', style: AppTheme.textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedAlcoholic,
            items: _alcoholicOptions
                .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                .toList(),
            onChanged: (value) => setState(() => _selectedAlcoholic = value),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) => value == null ? 'Select option' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPage4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About You', style: AppTheme.textTheme.headlineSmall),
          const SizedBox(height: 24),
          Text('Bio (Max 150 characters)', style: AppTheme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _bioController,
            maxLines: 4,
            maxLength: 150,
            decoration: InputDecoration(
              hintText: 'Tell us about yourself...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Bio required';
              if (value!.length > 150) return 'Bio must be 150 characters or less';
              return null;
            },
          ),
          const SizedBox(height: 24),
          GlassmorphismCard(
            padding: const EdgeInsets.all(12),
            opacity: 0.05,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.accentNeon),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Profile images will be uploaded in next screen',
                    style: AppTheme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
