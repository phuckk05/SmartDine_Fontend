
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModeNotifier extends StateNotifier<bool> {
  ModeNotifier(super.state);
  
  void setMode(bool newState) {
    state = newState;
  }
}
final  modeProvider = StateNotifierProvider<ModeNotifier, bool>((ref) => ModeNotifier(false));