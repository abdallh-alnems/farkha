import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ReviewsFilterSheet extends StatefulWidget {
  final String? platform;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final void Function(String? platform, DateTime? dateFrom, DateTime? dateTo) onApply;

  const ReviewsFilterSheet({
    super.key,
    this.platform,
    this.dateFrom,
    this.dateTo,
    required this.onApply,
  });

  @override
  State<ReviewsFilterSheet> createState() => _ReviewsFilterSheetState();
}

class _ReviewsFilterSheetState extends State<ReviewsFilterSheet> {
  String? _platform;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    _platform = widget.platform;
    _dateFrom = widget.dateFrom;
    _dateTo = widget.dateTo;
  }

  Future<void> _pickDate(bool isFrom) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? (_dateFrom ?? now) : (_dateTo ?? now),
      firstDate: DateTime(2024),
      lastDate: now,
      builder: (_, child) => Theme(data: AppTheme.darkTheme, child: child!),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _dateFrom = picked;
      } else {
        _dateTo = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('تصفية التقييمات', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('المنصة', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _chip('الكل', null),
              _chip('Android', 'android'),
              _chip('iOS', 'ios'),
            ],
          ),
          const SizedBox(height: 16),
          const Text('الفترة الزمنية', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _dateButton(
                  _dateFrom != null ? '${_dateFrom!.year}-${_dateFrom!.month.toString().padLeft(2, '0')}-${_dateFrom!.day.toString().padLeft(2, '0')}' : 'من تاريخ',
                  () => _pickDate(true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dateButton(
                  _dateTo != null ? '${_dateTo!.year}-${_dateTo!.month.toString().padLeft(2, '0')}-${_dateTo!.day.toString().padLeft(2, '0')}' : 'إلى تاريخ',
                  () => _pickDate(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onApply(null, null, null);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('إعادة تعيين', style: TextStyle(fontFamily: 'Cairo')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_platform, _dateFrom, _dateTo);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('تطبيق', style: TextStyle(fontFamily: 'Cairo')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String? value) {
    final selected = _platform == value;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontFamily: 'Cairo', color: selected ? Colors.white : AppTheme.textSecondary, fontSize: 13)),
      selected: selected,
      selectedColor: AppTheme.primary,
      backgroundColor: AppTheme.surfaceLight,
      side: BorderSide(color: selected ? AppTheme.primary : AppTheme.border),
      onSelected: (_) => setState(() => _platform = value),
    );
  }

  Widget _dateButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
