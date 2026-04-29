import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/services/open_gmail.dart';

class DrawerSupportContact extends StatefulWidget {
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;

  const DrawerSupportContact({
    super.key,
    required this.isExpanded,
    required this.onExpansionChanged,
  });

  @override
  State<DrawerSupportContact> createState() => _DrawerSupportContactState();
}

class _DrawerSupportContactState extends State<DrawerSupportContact> {

  Future<void> _handleEmail() async {
    Navigator.pop(context);
    unawaited(openGmail());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13).r,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: ValueKey<bool>(widget.isExpanded),
          leading: Icon(
            Icons.support_agent_rounded,
            size: 21.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text('التواصل', style: TextStyle(fontSize: 15.sp)),
          trailing: const SizedBox.shrink(),
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          initiallyExpanded: widget.isExpanded,
          onExpansionChanged: widget.onExpansionChanged,
          children: [
            ListTile(
              onTap: _handleEmail,
              title: Text(
                'البريد الإلكتروني',
                style: TextStyle(fontSize: 15.sp),
              ),
              shape: const Border(),
              contentPadding: EdgeInsets.symmetric(horizontal: 13.w),
            ),
          ],
        ),
      ),
    );
  }
}
