import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:me_talk/core/style.dart';

class ListPost extends ConsumerStatefulWidget {
  const ListPost({super.key});

  @override
  ConsumerState<ListPost> createState() => _ListPostState();
}
class _ListPostState extends ConsumerState<ListPost> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      // padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: Style.paddingPhone),
              child: Row(
                children: [
                  CircleAvatar(radius: 20),
                  SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phúc $index', style: Style.fontUsername),
                      Text('5 giờ trước', style: Style.fontCaption),
                    ],
                  ),

                  Spacer(),

                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(FluentIcons.more_horizontal_20_regular),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Style.paddingPhone,
              ),
              child: Text(
                'Nội dung bài viết của Phúc $index',
                style: Style.fontCaption,
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Style.paddingPhone,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'lib/widgets/list_connect.dart assets/images/LogoApp2.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Style.paddingPhone,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(FluentIcons.thumb_like_20_regular),
                        onPressed: () {},
                      ),
                      Text('25', style: Style.fontCaption),
                    ],
                  ),
                  SizedBox(width: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(FluentIcons.comment_20_regular),
                        onPressed: () {},
                      ),
                      Text('10', style: Style.fontCaption),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
