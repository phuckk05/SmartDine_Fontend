import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier(super.state);

  void toggle(bool newValue) => state = newValue;
}

final isLoadingNotifierProvider = StateNotifierProvider(
  (ref) => LoadingNotifier(false),
);
