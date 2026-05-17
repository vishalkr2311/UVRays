// lib/services/api_service.dart

import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _defaultBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:5000/api';
  }
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:5000/api';
  }
  return 'http://localhost:5000/api';
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio _dio;
  String? _accessToken;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _defaultBaseUrl(),
        // Increase timeouts slightly to allow for slower local dev backends
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print('API Error: ${error.message}');
            print('Status Code: ${error.response?.statusCode}');
          }
          return handler.next(error);
        },
      ),
    );
  }

  void setAccessToken(String token) {
    _accessToken = token;
  }

  String? getAccessToken() => _accessToken;

  // Authentication APIs
  Future<Response> googleLogin(String idToken) async {
    try {
      return await _dio.post(
        '/auth/google-login',
        data: {'idToken': idToken},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> requestEmailOtp(String email) async {
    try {
      return await _dio.post('/auth/email-otp-request', data: {'email': email});
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> verifyEmailOtp(String email, String otpCode) async {
    try {
      return await _dio.post('/auth/email-otp-verify', data: {
        'email': email,
        'otpCode': otpCode,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> adminLogin(String email, String password) async {
    try {
      return await _dio.post('/auth/admin-login', data: {
        'email': email,
        'password': password,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> logout() async {
    try {
      final response = await _dio.post('/auth/logout');
      _accessToken = null;
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Profile APIs
  Future<Response> createProfile(Map<String, dynamic> profileData) async {
    try {
      return await _dio.post('/profile/create', data: profileData);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateProfile(Map<String, dynamic> profileData) async {
    try {
      return await _dio.put('/profile/update', data: profileData);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getProfile() async {
    try {
      return await _dio.get('/profile/me');
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getPublicProfile(int userId) async {
    try {
      return await _dio.get('/profile/$userId');
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> uploadProfileImages(List<String> imagePaths) async {
    try {
      FormData formData = FormData();
      for (String path in imagePaths) {
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(path),
          ),
        );
      }
      return await _dio.post('/profile/images/upload', data: formData);
    } catch (e) {
      rethrow;
    }
  }

  // Search APIs
  Future<Response> getAllUsers() async {
    try {
      return await _dio.get('/search/all');
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> searchUsers({
    String? location,
    String? gender,
    int? minAge,
    int? maxAge,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (location != null) queryParams['location'] = location;
      if (gender != null) queryParams['gender'] = gender;
      if (minAge != null) queryParams['minAge'] = minAge;
      if (maxAge != null) queryParams['maxAge'] = maxAge;

      return await _dio.get('/search/search', queryParameters: queryParams);
    } catch (e) {
      rethrow;
    }
  }

  // Request APIs
  Future<Response> sendRequest(int receiverId, {String? message}) async {
    try {
      return await _dio.post(
        '/requests/send',
        data: {
          'receiverId': receiverId,
          'message': message,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> acceptRequest(int requestId) async {
    try {
      return await _dio.post(
        '/requests/accept',
        data: {'requestId': requestId},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> rejectRequest(int requestId) async {
    try {
      return await _dio.post(
        '/requests/reject',
        data: {'requestId': requestId},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getIncomingRequests() async {
    try {
      return await _dio.get('/requests/incoming');
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getAcceptedConnections() async {
    try {
      return await _dio.get('/requests/accepted');
    } catch (e) {
      rethrow;
    }
  }

  // Chat APIs
  Future<Response> getConversations() async {
    try {
      return await _dio.get('/chat/conversations');
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getMessages(int conversationId, {int limit = 50, int offset = 0}) async {
    try {
      return await _dio.get(
        '/chat/conversations/$conversationId/messages',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> sendMessage(int conversationId, String message) async {
    try {
      return await _dio.post(
        '/chat/messages/send',
        data: {
          'conversationId': conversationId,
          'message': message,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getUnreadCount() async {
    try {
      return await _dio.get('/chat/unread-count');
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getAdminDashboard() async {
    try {
      return await _dio.get('/admin/dashboard');
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getAdminUsers() async {
    try {
      return await _dio.get('/admin/users');
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> broadcastNotification(String message) async {
    try {
      return await _dio.post('/admin/broadcast', data: { 'message': message });
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteUser(int userId) async {
    try {
      return await _dio.delete('/admin/users/$userId');
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> setUserPassword(int userId, String password) async {
    try {
      return await _dio.put('/admin/users/$userId/password', data: { 'password': password });
    } catch (e) {
      rethrow;
    }
  }

  // Utility method to update API base URL
  void setApiBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }
}
