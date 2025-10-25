import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenHistory extends ConsumerStatefulWidget {
  const ScreenHistory({super.key});

  @override
  ConsumerState<ScreenHistory> createState() => _ScreenHistoryState();
}

class _ScreenHistoryState extends ConsumerState<ScreenHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('History Screen')),
    );
  }
}
