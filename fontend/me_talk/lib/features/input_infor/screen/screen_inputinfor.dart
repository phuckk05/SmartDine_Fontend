import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenInputInfor extends ConsumerStatefulWidget {
  const ScreenInputInfor({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScreenInputInforState();
}
class _ScreenInputInforState extends ConsumerState<ScreenInputInfor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(child: Container(color: Colors.blue,))
    );
  }
}


