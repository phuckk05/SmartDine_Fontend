import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenQlcuahang extends ConsumerStatefulWidget {
  const ScreenQlcuahang({super.key});

  @override
  ConsumerState<ScreenQlcuahang> createState() => _ScreenQlcuahangState();
}

class _ScreenQlcuahangState extends ConsumerState<ScreenQlcuahang> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('Qlcuahang Screen')),
    );
  }
}
