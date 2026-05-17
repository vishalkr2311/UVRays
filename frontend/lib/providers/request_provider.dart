// lib/providers/request_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/request_model.dart';
import '../services/api_service.dart';

class RequestState {
  final bool isLoading;
  final List<ConnectionRequest> incomingRequests;
  final List<ConnectionRequest> acceptedConnections;
  final String? error;

  RequestState({
    this.isLoading = false,
    this.incomingRequests = const [],
    this.acceptedConnections = const [],
    this.error,
  });

  RequestState copyWith({
    bool? isLoading,
    List<ConnectionRequest>? incomingRequests,
    List<ConnectionRequest>? acceptedConnections,
    String? error,
  }) {
    return RequestState(
      isLoading: isLoading ?? this.isLoading,
      incomingRequests: incomingRequests ?? this.incomingRequests,
      acceptedConnections: acceptedConnections ?? this.acceptedConnections,
      error: error,
    );
  }
}

class RequestNotifier extends StateNotifier<RequestState> {
  final ApiService _apiService = ApiService();

  RequestNotifier() : super(RequestState());

  Future<void> sendRequest(int receiverId, {String? message}) async {
    try {
      await _apiService.sendRequest(receiverId, message: message);
    } catch (e) {
      state = state.copyWith(error: 'Failed to send request: ${e.toString()}');
      print('Send Request Error: $e');
    }
  }

  Future<void> acceptRequest(int requestId) async {
    try {
      await _apiService.acceptRequest(requestId);
      await getIncomingRequests();
      await getAcceptedConnections();
    } catch (e) {
      state = state.copyWith(error: 'Failed to accept request: ${e.toString()}');
      print('Accept Request Error: $e');
    }
  }

  Future<void> rejectRequest(int requestId) async {
    try {
      await _apiService.rejectRequest(requestId);
      await getIncomingRequests();
    } catch (e) {
      state = state.copyWith(error: 'Failed to reject request: ${e.toString()}');
      print('Reject Request Error: $e');
    }
  }

  Future<void> getIncomingRequests() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getIncomingRequests();

      if (response.statusCode == 200) {
        final requests = (response.data['requests'] as List)
            .map((r) => ConnectionRequest.fromJson(r))
            .toList();
        state = state.copyWith(isLoading: false, incomingRequests: requests);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch incoming requests: ${e.toString()}',
      );
      print('Get Incoming Requests Error: $e');
    }
  }

  Future<void> getAcceptedConnections() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getAcceptedConnections();

      if (response.statusCode == 200) {
        final connections = (response.data['connections'] as List)
            .map((c) => ConnectionRequest.fromJson(c))
            .toList();
        state = state.copyWith(isLoading: false, acceptedConnections: connections);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch connections: ${e.toString()}',
      );
      print('Get Accepted Connections Error: $e');
    }
  }
}

final requestProvider = StateNotifierProvider<RequestNotifier, RequestState>(
  (ref) => RequestNotifier(),
);
