// lib/providers/search_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class SearchState {
  final bool isLoading;
  final List<User> users;
  final String? error;

  SearchState({
    this.isLoading = false,
    this.users = const [],
    this.error,
  });

  SearchState copyWith({
    bool? isLoading,
    List<User>? users,
    String? error,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      error: error,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final ApiService _apiService = ApiService();

  SearchNotifier() : super(SearchState());

  Future<void> getAllUsers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getAllUsers();

      if (response.statusCode == 200) {
        final users = (response.data['users'] as List)
            .map((u) => User.fromJson(u))
            .toList();
        state = state.copyWith(isLoading: false, users: users);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch users: ${e.toString()}',
      );
      print('Get All Users Error: $e');
    }
  }

  Future<void> searchUsers({
    String? location,
    String? gender,
    int? minAge,
    int? maxAge,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.searchUsers(
        location: location,
        gender: gender,
        minAge: minAge,
        maxAge: maxAge,
      );

      if (response.statusCode == 200) {
        final users = (response.data['users'] as List)
            .map((u) => User.fromJson(u))
            .toList();
        state = state.copyWith(isLoading: false, users: users);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed: ${e.toString()}',
      );
      print('Search Users Error: $e');
    }
  }

  void clearSearch() {
    state = SearchState();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(),
);
