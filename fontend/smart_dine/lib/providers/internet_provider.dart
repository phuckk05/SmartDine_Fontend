import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetNotifier extends StateNotifier<bool> {
  InternetNotifier() : super(true) {
    _init();
  }

  StreamSubscription<ConnectivityResult>? _sub;

  Future<void> _init() async {
    await check(); // initial check
    _sub = Connectivity().onConnectivityChanged.listen((_) {
      // non-blocking re-check on connectivity change
      check();
    });
  }

  /// Kiểm tra kết nối internet thực tế (DNS lookup)
  /// trả về true nếu có internet, false nếu không
  Future<bool> check() async {
    try {
      // timeout để tránh treo lâu
      final result = await InternetAddress.lookup(
        'example.com',
      ).timeout(Duration(seconds: 5));
      final hasConnection =
          result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      state = hasConnection;
      return hasConnection;
    } catch (_) {
      state = false;
      return false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final internetProvider = StateNotifierProvider<InternetNotifier, bool>(
  (ref) => InternetNotifier(),
);
