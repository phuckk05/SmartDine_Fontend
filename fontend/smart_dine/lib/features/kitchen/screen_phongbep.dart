import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenKitChen extends ConsumerStatefulWidget {
  const ScreenKitChen({super.key});

  @override
  ConsumerState<ScreenKitChen> createState() => _ScreenKitChenState();
}

class _ScreenKitChenState extends ConsumerState<ScreenKitChen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [_search(), SizedBox(height: 20), _listItem()],
          ),
        ),
      ),
    );
  }

  //Cac widget con
  Widget _listItem() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Text('Item $index');
      },
    );
  }

  //Search
  Widget _search() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }
}
