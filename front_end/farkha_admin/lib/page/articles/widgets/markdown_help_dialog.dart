import 'package:flutter/material.dart';

Future<void> showMarkdownHelpDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('دليل تنسيق المحتوى'),
        content: const _MarkdownHelpContent(),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      );
    },
  );
}

class _MarkdownHelpContent extends StatelessWidget {
  const _MarkdownHelpContent();

  static const List<_MarkdownHelpEntry> _entries = [
    _MarkdownHelpEntry(label: 'عنوان رئيسي', syntax: '#'),
    _MarkdownHelpEntry(label: 'عنوان فرعي', syntax: '##'),
    _MarkdownHelpEntry(label: 'عنوان صغير', syntax: '###'),
    _MarkdownHelpEntry(label: 'قائمة نقطية', syntax: '-'),
    _MarkdownHelpEntry(label: 'قائمة مرقمة', syntax: '1.'),
    _MarkdownHelpEntry(label: 'نص غامق', syntax: '**النص**'),
  ];

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _entries
              .map(
                (_MarkdownHelpEntry entry) => _MarkdownHelpRow(entry: entry),
              )
              .toList(),
        ),
      );
}

class _MarkdownHelpRow extends StatelessWidget {
  final _MarkdownHelpEntry entry;

  const _MarkdownHelpRow({required this.entry});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                entry.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              entry.syntax,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      );
}

class _MarkdownHelpEntry {
  final String label;
  final String syntax;

  const _MarkdownHelpEntry({
    required this.label,
    required this.syntax,
  });
}
