import 'package:farkha_app/core/constant/theme/color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ArticleTitle extends StatelessWidget {
  final String text;
  final void Function() onTap;
  const ArticleTitle({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 19).r,
      child: InkWell(
        onTap: onTap,
        child: Container(
            width: double.infinity,
            height: 49,
            decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(7).r),
            child: Center(
                child: Text(
              text,
              style: TextStyle(fontSize: 19, color: Colors.white),
            ))),
      ),
    );
  }
}
