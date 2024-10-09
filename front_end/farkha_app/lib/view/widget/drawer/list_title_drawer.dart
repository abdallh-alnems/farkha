import 'package:flutter/material.dart';

import '../../../core/constant/theme/color.dart';

class ListTitleDrawer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function() onTap;
  const ListTitleDrawer({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, color: Color(0xFFD3D3D3)),
        textDirection: TextDirection.rtl,
      ),
      leading: Icon(
        icon,
        size: 20,
        color: Colors.white,
      ),
    );
  }
}
