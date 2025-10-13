import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier(super.state);

  void toggle() => state = !state;
}

final isLoadingNotifierProvider = StateNotifierProvider(
  (ref) => LoadingNotifier(false),
);
