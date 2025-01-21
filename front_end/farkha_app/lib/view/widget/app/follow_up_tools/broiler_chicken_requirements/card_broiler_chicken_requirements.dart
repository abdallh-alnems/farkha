import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constant/theme/color.dart';

class CardBroilerChickenRequirements extends StatelessWidget {
  final String text1;
  final String text2;
  final String image;
  final bool showText2;

  const CardBroilerChickenRequirements({
    super.key,
    required this.text1,
    this.text2 = "",
    required this.image,
    this.showText2 = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          color: AppColor.primaryColor,
          height: 0,
          thickness: 1,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7.7).r,
          child: Row(
            children: [
              Image.asset(image, scale: 1.23),
              SizedBox(width: 19.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text1,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  showText2
                      ? Padding(
                          padding: const EdgeInsets.only(top: 9).r,
                          child: Text(
                            text2,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
