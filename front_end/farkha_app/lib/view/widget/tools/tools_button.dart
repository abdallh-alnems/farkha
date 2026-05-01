import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../ad/interstitial.dart';

class ToolsButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ToolsButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          FocusScope.of(context).unfocus();
          InterstitialAdService.instance.show(onComplete: onPressed);
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
