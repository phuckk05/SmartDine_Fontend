import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/widgets/appbar.dart';

//Giao diện đăng kí quản lí chi nhánh
class ScreenManagerSigup extends ConsumerStatefulWidget {
  final String? title;
  const ScreenManagerSigup({super.key, this.title});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ScreenManagerSigupState();
}

class _ScreenManagerSigupState extends ConsumerState<ScreenManagerSigup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCus(title: widget.title ?? ''),
      body: SafeArea(child: SingleChildScrollView(child: Column(children: [

            ],
          ))),
    );
  }

  //Các widget con
}
