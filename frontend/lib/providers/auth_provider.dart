// lib/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../services/firebase_service.dart';

// Auth State
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? accessToken;
  final String? role;
  final String? message;
  final String? error;
  final bool isProfileComplete;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.accessToken,
    this.role,
    this.message,
    this.error,
    this.isProfileComplete = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? accessToken,
    String? role,
    String? message,
    String? error,
    bool? isProfileComplete,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      role: role ?? this.role,
      message: message ?? this.message,
      error: error,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseService _firebaseService = FirebaseService();
  final ApiService _apiService = ApiService();

  AuthNotifier() : super(AuthState()) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('access_token');

      if (savedToken != null) {
        _apiService.setAccessToken(savedToken);
        await _getProfile();
      }
    } catch (e) {
      print('Auth initialization error: $e');
    }
  }

  Future<void> googleLogin() async {
    state = state.copyWith(isLoading: true, error: null, message: null);

    if (!_firebaseService.isReady) {
      state = state.copyWith(
        isLoading: false,
        error:
            'Firebase is not configured. Set up Firebase and update firebase_options.dart before using Google login.',
      );
      return;
    }

    try {
      final idToken = await _firebaseService.googleSignIn();

      if (idToken == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Google Sign-In cancelled',
        );
        return;
      }

      final response = await _apiService.googleLogin(idToken);

      if (response.statusCode == 200) {
        final data = response.data;
        final accessToken = data['accessToken'];
        final user = User.fromJson(data['user']);
        final isProfileComplete = data['user']['isProfileComplete'] ?? false;

        _apiService.setAccessToken(accessToken);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        await prefs.setInt('user_id', user.id);

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
          accessToken: accessToken,
          role: data['user']['role'],
          isProfileComplete: isProfileComplete,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed: ${e.toString()}',
      );
      print('Google Login Error: $e');
    }
  }

  Future<void> requestEmailOtp(String email) async {
    state = state.copyWith(isLoading: true, error: null, message: null);

    try {
      final response = await _apiService.requestEmailOtp(email);
      if (response.statusCode == 200) {
        state = state.copyWith(
          isLoading: false,
          message: response.data['message'] ?? 'OTP sent',
        );
      }
    } catch (e) {
      String friendly = 'OTP request failed: ${e.toString()}';
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          friendly =
              'Unable to reach the backend. Is the server running (http://10.0.2.2:5000 for emulator / http://localhost:5000 for desktop)?';
        }
      }

      state = state.copyWith(
        isLoading: false,
        error: friendly,
      );
      print('OTP Request Error: $e');
    }
  }

  Future<void> verifyEmailOtp(String email, String otpCode) async {
    state = state.copyWith(isLoading: true, error: null, message: null);

    try {
      final response = await _apiService.verifyEmailOtp(email, otpCode);
      if (response.statusCode == 200) {
        final data = response.data;
        final accessToken = data['accessToken'];
        final user = User.fromJson(data['user']);
        final isProfileComplete = data['user']['isProfileComplete'] ?? false;

        _apiService.setAccessToken(accessToken);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        await prefs.setInt('user_id', user.id);

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
          accessToken: accessToken,
          role: data['user']['role'],
          isProfileComplete: isProfileComplete,
        );
      }
    } catch (e) {
      String friendly = 'OTP verification failed: ${e.toString()}';
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          friendly =
              'Unable to reach the backend. Is the server running (http://10.0.2.2:5000 for emulator / http://localhost:5000 for desktop)?';
        }
      }

      state = state.copyWith(
        isLoading: false,
        error: friendly,
      );
      print('OTP Verify Error: $e');
    }
  }

  Future<void> adminLogin({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null, message: null);

    try {
      final response = await _apiService.adminLogin(email, password);
      if (response.statusCode == 200) {
        final data = response.data;
        final accessToken = data['accessToken'];
        final user = User.fromJson(data['user']);

        _apiService.setAccessToken(accessToken);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        await prefs.setInt('user_id', user.id);

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
          accessToken: accessToken,
          role: data['user']['role'],
          isProfileComplete: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Admin login failed: ${e.toString()}',
      );
      print('Admin Login Error: $e');
    }
  }

  Future<void> _getProfile() async {
    try {
      final response = await _apiService.getProfile();

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data['user']);

        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          role: response.data['user']['role'],
          isProfileComplete: user.isProfileComplete,
        );
      }
    } catch (e) {
      print('Get Profile Error: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
      await _firebaseService.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('user_id');

      state = AuthState();
    } catch (e) {
      print('Logout Error: $e');
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
