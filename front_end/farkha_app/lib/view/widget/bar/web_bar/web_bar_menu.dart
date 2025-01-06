import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebBarMenu extends StatelessWidget {
  final Map<String, String> items;
  final String label;

  const WebBarMenu({
    super.key,
    required this.items,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String value) {},
      icon: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
          Icon(Icons.arrow_drop_down, color: Colors.white),
        ],
      ),
      itemBuilder: (BuildContext context) {
        return items.keys.map((String key) => _buildMenuItem(key)).toList();
      },
    );
  }

  PopupMenuItem<String> _buildMenuItem(String title) {
    return PopupMenuItem<String>(
      value: title,
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(title),
      ),
    );
  }
}
