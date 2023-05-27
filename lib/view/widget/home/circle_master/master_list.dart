import 'package:farkha_app/view/widget/home/circle_master/circle_avatar.dart';
import 'package:flutter/material.dart';

class MasterList extends StatelessWidget {
  const MasterList({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        height: 150,
        child: Row(
          children: [
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: ,
              child: CricleAvatarHome(
                type: 'فراخ',
              ),
            ),
            SizedBox(
              width: 20,
            ),
            CricleAvatarHome(
              type: 'كتاكيت',
            ),
            SizedBox(
              width: 20,
            ),
            CricleAvatarHome(
              type: 'اعلاف',
            ),
            SizedBox(
              width: 20,
            ),
            CricleAvatarHome(
              type: 'بيض',
            ),
            SizedBox(
              width: 20,
            ),
            CricleAvatarHome(
              type: 'بط',
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }
}
