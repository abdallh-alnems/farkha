import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/routes/route.dart';
import '../../../core/services/open_gmail.dart';

class DrawerSupportContact extends StatefulWidget {
  const DrawerSupportContact({super.key});

  @override
  State<DrawerSupportContact> createState() => _DrawerSupportContactState();
}

class _DrawerSupportContactState extends State<DrawerSupportContact> {
  bool _isExpanded = false;

  Future<void> _handleEmail() async {
    Navigator.pop(context);
    openGmail();
  }

  Future<void> _handleSuggestion() async {
    Navigator.pop(context);
    Get.toNamed(AppRoute.suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13).r,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(
            Icons.support_agent_rounded,
            size: 21.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text('الدعم والتواصل', style: TextStyle(fontSize: 15.sp)),
          trailing: const SizedBox.shrink(),
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          initiallyExpanded: _isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          children: [
            ListTile(
              onTap: _handleEmail,
              title: Text('البريد الإلكتروني', style: TextStyle(fontSize: 15.sp)),
              shape: const Border(),
              contentPadding: EdgeInsets.symmetric(horizontal: 13.w),
            ),
            ListTile(
              onTap: _handleSuggestion,
              title: Text('إرسال اقتراح', style: TextStyle(fontSize: 15.sp)),
              shape: const Border(),
              contentPadding: EdgeInsets.symmetric(horizontal: 13.w),
            ),
          ],
        ),
      ),
    );
  }
}

