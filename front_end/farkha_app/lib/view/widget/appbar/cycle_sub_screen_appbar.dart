import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../logic/controller/cycle_controller.dart';

class CycleSubScreenAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String titlePrefix;
  final VoidCallback? onAddPressed;

  const CycleSubScreenAppBar({
    super.key,
    required this.titlePrefix,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cycleCtrl = Get.find<CycleController>();

    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: colorScheme.primary,
        ),
        onPressed: () => Get.back<void>(),
      ),
      title: Obx(() {
        final cycle = cycleCtrl.currentCycle;
        return Text(
          '$titlePrefix ${cycle['name'] ?? 'الدورة'}',
          style: TextStyle(
            color: colorScheme.primary,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        );
      }),
      centerTitle: true,
      actions: [
        if (cycleCtrl.currentCycle['role']?.toString() != 'viewer' &&
            onAddPressed != null)
          IconButton(
            icon: Icon(
              Icons.add,
              color: colorScheme.primary,
            ),
            onPressed: onAddPressed,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
