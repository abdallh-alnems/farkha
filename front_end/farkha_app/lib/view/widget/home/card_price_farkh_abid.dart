import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/theme/color.dart';

class CardPriceFarkhAbid extends StatelessWidget {
  const CardPriceFarkhAbid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 13).r,
      child: Container(
        width: double.infinity,
        height: 31,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: AppColor.primaryColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.arrow_outward,color: Colors.white,),
            Text("55",style: TextStyle(color: Colors.white),),
            Text("56",style: TextStyle(color: Colors.white),),
            Text("اللحم الابيض",style: TextStyle(color: Colors.white),),
          ],
        ),
      ),
    );
  }
}
