import 'package:flutter/material.dart';

class NoteItem extends StatelessWidget {
  final String text;
  const NoteItem(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
        ],
      ),
    );
  }
}
