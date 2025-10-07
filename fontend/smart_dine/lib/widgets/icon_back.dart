import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class IconBack {
  static IconButton back(BuildContext context) => IconButton(
    icon: Icon(
      FluentIcons.chevron_left_28_filled,
      size: 28,
      color:
          IconThemeData(color: Theme.of(context).colorScheme.onSurface).color,
    ),
    onPressed: () {
      Navigator.pop(context);
    },
  );
}
