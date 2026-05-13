import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DisclaimerDialog extends StatelessWidget {
  const DisclaimerDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const DisclaimerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'إخلاء المسؤولية',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            'تطبيق "فرخة" هو أداة مساعدة لإدارة مزارع الدواجن، وجميع البيانات والمعلومات المقدمة من خلاله هي لأغراض إرشادية وتعليمية فقط.\n\n'
            'لا يُعد التطبيق بديلاً عن الاستشارة المتخصصة من طبيب بيطري أو خبير في مجال الدواجن. يجب على المستخدم التحقق من جميع المعلومات واستشارة المتخصصين قبل اتخاذ أي قرارات تخص إدارة المزرعة أو صحة القطيع.\n\n'
            'لا يتحمل مطورو التطبيق أي مسؤولية عن أي خسائر أو أضرار مباشرة أو غير مباشرة ناتجة عن استخدام أو إساءة استخدام المعلومات المقدمة في التطبيق.\n\n'
            'الأسعار والمعلومات المتعلقة بالسوق المعروضة في التطبيق هي لأغراض مرجعية وقد لا تعكس الأسعار الفعلية في جميع المناطق.\n\n'
            'باستخدامك لهذا التطبيق، فإنك توافق على هذه الشروط وتقر بأنك قد قرأت إخلاء المسؤولية هذا وفهمته بالكامل.',
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.8,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                'فهمت',
                style: TextStyle(fontSize: 15.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
