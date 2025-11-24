import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base class for providers that need realtime updates
abstract class RealtimeNotifier<T> extends StateNotifier<AsyncValue<T>> {
  Timer? _pollingTimer;
  bool _isDisposed = false;

  RealtimeNotifier() : super(const AsyncValue.loading()) {
    _startRealtimeUpdates();
  }

  /// Abstract method to load data - implement this in subclasses
  Future<T> loadData();

  /// Polling interval - can be overridden by subclasses
  Duration get pollingInterval => const Duration(seconds: 30);

  /// Whether to enable realtime updates - can be overridden
  bool get enableRealtime => true;

  void _startRealtimeUpdates() {
    if (!enableRealtime) return;

    // Load initial data
    _loadData();

    // Start polling for realtime updates
    _pollingTimer = Timer.periodic(pollingInterval, (_) {
      if (!_isDisposed) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    if (_isDisposed) return;

    try {
      final data = await loadData();
      if (!_isDisposed) {
        state = AsyncValue.data(data);
      }
    } catch (error, stackTrace) {
      if (!_isDisposed) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  /// Manual refresh - can be called from UI
  Future<void> refresh() async {
    if (_isDisposed) return;
    
    // Set state to loading before fetching new data
    state = const AsyncValue.loading();
    await _loadData();
  }

  /// Stop realtime updates temporarily
  void pauseRealtime() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Resume realtime updates
  void resumeRealtime() {
    if (!enableRealtime || _isDisposed) return;
    if (_pollingTimer == null || !_pollingTimer!.isActive) {
      _pollingTimer = Timer.periodic(pollingInterval, (_) => _loadData());
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pollingTimer?.cancel();
    super.dispose();
  }
}