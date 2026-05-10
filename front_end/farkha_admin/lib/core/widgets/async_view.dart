import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class AsyncView<T> extends StatelessWidget {
  final Rx<Status> status;
  final String? errorMessage;
  final Widget child;

  const AsyncView({
    super.key,
    required this.status,
    this.errorMessage,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (status.value) {
        case Status.loading:
          return Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        case Status.error:
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppTheme.accent),
                SizedBox(height: 12),
                Text(
                  errorMessage ?? 'حدث خطأ',
                  style: TextStyle(color: AppTheme.textSecondary, fontFamily: 'Cairo'),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Get.forceAppUpdate(),
                  child: Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        case Status.success:
          return child;
      }
    });
  }
}

enum Status { loading, success, error }
