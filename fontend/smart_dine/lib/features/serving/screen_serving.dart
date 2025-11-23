import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenServing extends ConsumerStatefulWidget {
  final String? branchId;
  final String? userId;
  const ScreenServing({super.key, this.branchId, this.userId});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScreenServingState();
}

class _ScreenServingState extends ConsumerState<ScreenServing> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
