import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenSetting extends ConsumerStatefulWidget {
  const ScreenSetting({super.key});

  @override
  ConsumerState<ScreenSetting> createState() => _ScreenSettingState();
}

class _ScreenSettingState extends ConsumerState<ScreenSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('Setting Screen')),
    );
  }
}
