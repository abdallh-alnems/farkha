import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

Future<bool> showUnstarDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppTheme.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
          SizedBox(width: 10),
          Text('إزالة التمييز', style: TextStyle(fontFamily: 'Cairo', fontSize: 18)),
        ],
      ),
      content: const Text(
        'هل أنت متأكد من إزالة التمييز عن هذا التقييم؟',
        style: TextStyle(fontFamily: 'Cairo', fontSize: 15),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: AppTheme.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('إزالة', style: TextStyle(fontFamily: 'Cairo')),
        ),
      ],
    ),
  ).then((v) => v ?? false);
}
