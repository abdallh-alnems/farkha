import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TitleArticle extends StatelessWidget {
  final String title;
  const TitleArticle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3).r,
      child: Text(
        ": $title",
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}
