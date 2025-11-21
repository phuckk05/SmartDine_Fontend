import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models/order.dart';
import 'package:mart_dine/widgets/appbar.dart';

class ScreenHistoryService extends ConsumerStatefulWidget {
  const ScreenHistoryService({super.key});

  @override
  ConsumerState<ScreenHistoryService> createState() =>
      _ScreenHistoryServiceState();
}

class _ScreenHistoryServiceState extends ConsumerState<ScreenHistoryService> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCus(
        title: 'Lịch sử dịch vụ',
        isCanpop: true,
        isButtonEnabled: true,
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Text('Danh sách lịch sử dịch vụ sẽ hiển thị ở đây.'),
            ],
          ),
        ),
      ),
    );
  }

  //Widget
  Widget _buildOrderList(List<Order> orders) {
    return Container();
  }
}
