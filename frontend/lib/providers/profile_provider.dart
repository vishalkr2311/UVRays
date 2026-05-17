// lib/providers/profile_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class ProfileState {
  final bool isLoading;
  final User? profileUser;
  final String? error;

  ProfileState({
    this.isLoading = false,
    this.profileUser,
    this.error,
  });

  ProfileState copyWith({
    bool? isLoading,
    User? profileUser,
    String? error,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profileUser: profileUser ?? this.profileUser,
      error: error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ApiService _apiService = ApiService();

  ProfileNotifier() : super(ProfileState());

  Future<void> createProfile(Map<String, dynamic> profileData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.createProfile(profileData);

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data['user']);
        state = state.copyWith(isLoading: false, profileUser: user);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create profile: ${e.toString()}',
      );
      print('Create Profile Error: $e');
    }
  }

  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.updateProfile(profileData);

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data['user']);
        state = state.copyWith(isLoading: false, profileUser: user);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update profile: ${e.toString()}',
      );
      print('Update Profile Error: $e');
    }
  }

  Future<void> uploadImages(List<String> imagePaths) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.uploadProfileImages(imagePaths);

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data['user']);
        state = state.copyWith(isLoading: false, profileUser: user);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to upload images: ${e.toString()}',
      );
      print('Upload Images Error: $e');
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(),
);
