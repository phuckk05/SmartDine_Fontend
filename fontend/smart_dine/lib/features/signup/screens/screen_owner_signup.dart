import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/widgets/appbar.dart';

//Giao diện đăng kí chủ nhà hàng
class ScreenOwnerSignup extends ConsumerStatefulWidget {
  final String? title;
  const ScreenOwnerSignup({super.key, this.title});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ScreenOwnerSignupState();
}

class _ScreenOwnerSignupState extends ConsumerState<ScreenOwnerSignup> {
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
  Widget _() {
    return Container();
  }
}
