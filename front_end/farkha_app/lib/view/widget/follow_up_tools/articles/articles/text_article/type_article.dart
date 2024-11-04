import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TypeArticle extends StatelessWidget {
  final String type;
  const TypeArticle({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15).r,
      child: Text(
        type,
        style: Theme.of(context).textTheme.bodyMedium,
        textDirection: TextDirection.rtl,
      ),
    );
  }
}
