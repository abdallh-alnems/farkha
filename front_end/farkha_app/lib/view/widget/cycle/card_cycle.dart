import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/constant/routes/route.dart';
import '../../../core/constant/theme/color.dart';
import '../../../core/constant/image_asset.dart';
import '../../../logic/controller/cycle_controller.dart';

class CardCycle extends StatelessWidget {
  const CardCycle({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.put(CycleController());

        final storage = GetStorage();

        final storedCycles = storage.read('cycles');

        if (storedCycles != null &&
            storedCycles is List &&
            storedCycles.isNotEmpty) {
          Get.toNamed(AppRoute.cycle);
        } else {
          Get.toNamed(AppRoute.addCycle, arguments: {'fromHome': true});
        }
      },

      child: Container(
        width: 149.w,
        height: 45.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: AppColor.secondaryColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(ImageAsset.addCycle, scale: 2.3),
            Text(
              "اضف دورة",
              style: TextStyle(
                fontSize: 17.sp,
                color: AppColor.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
