import 'package:flutter/material.dart';
import 'package:me_talk/core/style.dart';
import 'package:me_talk/widgets/modal_bottom_sheet.dart';

class ListConnected extends StatelessWidget {
  const ListConnected({super.key});

  void showModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ModalBottomSheetOfConnect(index: 3);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10, // Số lượng kết nối giả định
      itemBuilder: (context, index) {
        return InkWell(
          splashColor: Colors.blue.shade100,
          onTap: () {},
          child: ListTile(
            // leading: CircleAvatar(
            //   radius: 20,
            //   backgroundImage:AssetImage(
            //     'assets/images/LogoApp2.png',
            //   ),
            // ),
            title: Text('Đồng chí x $index', style: Style.fontUsername),
            subtitle: Row(
              children: [
                Text('Đã kết nối 2 ngày trước', style: Style.fontCaption),
              ],
            ),

            trailing: IconButton(
              onPressed: () {
                showModal(context);
              },
              icon: Icon(Icons.more_horiz),
            ),
            onTap: () {},
          ),
        );
      },
    );
  }
}
