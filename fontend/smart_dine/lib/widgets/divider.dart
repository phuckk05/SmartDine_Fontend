import 'package:flutter/material.dart';

class Divider extends StatelessWidget {
  const Divider({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
      width: double.infinity,
      height: 1,
      color: Colors.blueGrey.shade100.withOpacity(0.5),
    );
  }
}