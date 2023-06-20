import 'package:farkha_app/utils/theme.dart';
import 'package:flutter/material.dart';

class ListTitleDrawer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Function() onTap;
  const ListTitleDrawer({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: TextStyle(fontSize: 18, color: drawerTypeColor),
        textDirection: TextDirection.rtl,
      ),
      leading: Icon(
        icon,
        size: 20,
        color: color,
      ),
    );
  }
}
