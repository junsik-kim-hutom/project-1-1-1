import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/network_service.dart';

// Provider for the NetworkService instance
final networkServiceProvider = Provider<NetworkService>((ref) {
  final service = NetworkService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Stream provider for the current network status
final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  final service = ref.watch(networkServiceProvider);
  return service.networkStatusStream;
});
