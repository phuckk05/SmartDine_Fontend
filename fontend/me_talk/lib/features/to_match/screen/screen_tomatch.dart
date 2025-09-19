import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:me_talk/core/style.dart';

class ScreenTomatch extends ConsumerStatefulWidget {
  const ScreenTomatch({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScreenTomatchState();
}

class _ScreenTomatchState extends ConsumerState<ScreenTomatch> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Ghép đôi', style: Style.fontTitle),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        // Tự lấy màu theo Theme hệ thống
        backgroundColor: Theme.of(context).colorScheme.surface,
        // Ngăn hiệu ứng overlay gây mờ
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 50,
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.search,
              size: 24,
              // color: Colors.blue.shade700,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Container(height: 1000, color: Colors.yellow,
      child: Center(child: Text('jahah')),),
    );
  }
}