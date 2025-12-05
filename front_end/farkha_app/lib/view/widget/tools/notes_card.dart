import 'package:flutter/material.dart';

import '../../../core/constant/theme/colors.dart';

class NotesCard extends StatelessWidget {
  final List<String> notes;
  final String? title;

  const NotesCard({
    super.key,
    required this.notes,
    this.title = '📌 ملاحظات هامة',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        const SizedBox(height: 32),
        Card(
          color: isDark 
              ? AppColors.darkSurfaceElevatedColor 
              : AppColors.lightSurfaceColor,
          elevation: isDark ? 0 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark 
                  ? AppColors.darkOutlineColor.withOpacity(0.5)
                  : AppColors.lightOutlineColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Text(
                  title!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                ...notes.map((note) => _buildNoteItem(context, note)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildNoteItem(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 18,
            color: colorScheme.primary,
          ),
                     const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
