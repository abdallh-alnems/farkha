import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/strings/app_strings.dart';
import '../../../../core/constant/theme/colors.dart';

class ContactPickerDialog extends StatefulWidget {
  final bool isDark;

  const ContactPickerDialog({super.key, required this.isDark});

  @override
  State<ContactPickerDialog> createState() => _ContactPickerDialogState();
}

class _ContactPickerDialogState extends State<ContactPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _allContacts = [];
  List<Contact> _filtered = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
      );
      final withPhones = contacts.where((c) => c.phones.isNotEmpty).toList();
      if (mounted) {
        setState(() {
          _allContacts = withPhones;
          _filtered = withPhones;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _allContacts;
      } else {
        _filtered = _allContacts.where((c) {
          final name = c.displayName.toLowerCase();
          final phone = c.phones.first.number;
          return name.contains(query.toLowerCase()) || phone.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDark
          ? AppColors.darkSurfaceColor
          : AppColors.lightSurfaceColor,
      title: Text(
        'اختر جهة اتصال',
        style: TextStyle(
            color: widget.isDark ? Colors.white : Colors.black87,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400.h,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _filter,
              style: TextStyle(
                  color: widget.isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'بحث...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: widget.isDark ? Colors.black12 : Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filtered.isEmpty
                      ? Center(
                          child: Text('لا توجد نتائج',
                              style: TextStyle(
                                  color: widget.isDark
                                      ? Colors.white54
                                      : Colors.black54)))
                      : ListView.separated(
                          itemCount: _filtered.length,
                          separatorBuilder: (ctx, i) => Divider(
                              height: 1,
                              color: widget.isDark
                                  ? Colors.white10
                                  : Colors.black12),
                          itemBuilder: (ctx, i) {
                            final c = _filtered[i];
                            return ListTile(
                              title: Text(c.displayName,
                                  style: TextStyle(
                                      color: widget.isDark
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 14.sp)),
                              subtitle: Text(c.phones.first.number,
                                  style: TextStyle(
                                      color: widget.isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                      fontSize: 12.sp),
                                  textDirection: ui.TextDirection.ltr),
                              onTap: () => Navigator.of(context).pop(c),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
      ],
    );
  }
}
