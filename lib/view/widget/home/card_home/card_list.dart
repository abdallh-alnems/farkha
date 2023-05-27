import 'package:farkha_app/logic/controller/data_controller.dart';
import 'package:farkha_app/model/data_model.dart';
import 'package:farkha_app/view/widget/home/card_home/card_data.dart';
import 'package:farkha_app/view/widget/home/circle_master/master_list.dart';
import 'package:farkha_app/view/widget/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CardList extends StatelessWidget {
  const CardList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DataController controller = Get.put(DataController());

    return GetBuilder<DataController>(builder: (_) {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        );
      } else {
        return ListView.builder(
          itemCount: controller.frakhAbid.length +
              controller.frakhBaladi.length +
              controller.bydBaladi.length +
              controller.frakhSasso.length +
              controller.frakhAmihatAbid.length +
              controller.batMolar.length +
              controller.batFiransawi.length +
              controller.batMaskufi.length +
              controller.katakitAbid.length +
              controller.katakitBaladi.length +
              controller.katakitSasso.length +
              controller.bydAbid.length +
              controller.bydAihmar.length,
          itemBuilder: (BuildContext context, int index) {
            return ViewListCard(
              controller: controller,
              index: index,
            );
          },
        );
      }
    });
  }
}

class ViewListCard extends StatelessWidget {
  final int index;

  final DataController controller;

  const ViewListCard({
    Key? key,
    required this.index,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // MasterList(),

        // frakh

        const TextUtils(
          text: 'اسعار الدواجن',
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),

        CardViewData(
          type: 'ابيض',
          price1: controller.frakhAbid[index].todayPrice,
          price2: controller.frakhAbid[index].yesterdayPrice,
          price3: controller.frakhAbid[index].firstYesterdayPrice,
          price4: controller.frakhAbid[index].fourDaysAgoPrice,
        ),
        CardViewData(
          price1: controller.frakhSasso[index].todayPrice,
          price2: controller.frakhSasso[index].yesterdayPrice,
          price3: controller.frakhSasso[index].firstYesterdayPrice,
          price4: controller.frakhSasso[index].fourDaysAgoPrice,
          type: 'ساسو',
        ),
        CardViewData(
          price1: controller.frakhBaladi[index].todayPrice,
          price2: controller.frakhBaladi[index].yesterdayPrice,
          price3: controller.frakhBaladi[index].firstYesterdayPrice,
          price4: controller.frakhBaladi[index].fourDaysAgoPrice,
          type: 'بلدي',
        ),
        CardViewData(
          price1: controller.frakhAmihatAbid[index].todayPrice,
          price2: controller.frakhAmihatAbid[index].yesterdayPrice,
          price3: controller.frakhAmihatAbid[index].firstYesterdayPrice,
          price4: controller.frakhAmihatAbid[index].fourDaysAgoPrice,
          type: 'امهات ابيض',
        ),

        //katakit

        Divider(
          color: Colors.black,
          height: 60,
        ),

        const TextUtils(
          text: 'اسعار الكتاكيت',
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),

        CardViewData(
          price1: controller.katakitAbid[index].todayPrice,
          price2: controller.katakitAbid[index].yesterdayPrice,
          price3: controller.katakitAbid[index].firstYesterdayPrice,
          price4: controller.katakitAbid[index].fourDaysAgoPrice,
          type: 'ابيض',
        ),
        CardViewData(
          price1: controller.katakitSasso[index].todayPrice,
          price2: controller.katakitSasso[index].yesterdayPrice,
          price3: controller.katakitSasso[index].firstYesterdayPrice,
          price4: controller.katakitSasso[index].fourDaysAgoPrice,
          type: 'ساسو',
        ),
        CardViewData(
          price1: controller.katakitBaladi[index].todayPrice,
          price2: controller.katakitBaladi[index].yesterdayPrice,
          price3: controller.katakitBaladi[index].firstYesterdayPrice,
          price4: controller.katakitBaladi[index].fourDaysAgoPrice,
          type: 'بلدي',
        ),

        //byd

        Divider(
          color: Colors.black,
          height: 60,
        ),

        const TextUtils(
          text: 'اسعار البيض',
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),

        CardViewData(
          price1: controller.bydAbid[index].todayPrice,
          price2: controller.bydAbid[index].yesterdayPrice,
          price3: controller.bydAbid[index].firstYesterdayPrice,
          price4: controller.bydAbid[index].fourDaysAgoPrice,
          type: 'ابيض',
        ),
        CardViewData(
          price1: controller.bydAihmar[index].todayPrice,
          price2: controller.bydAihmar[index].yesterdayPrice,
          price3: controller.bydAihmar[index].firstYesterdayPrice,
          price4: controller.bydAihmar[index].fourDaysAgoPrice,
          type: 'احمر',
        ),
        CardViewData(
          price1: controller.bydBaladi[index].todayPrice,
          price2: controller.bydBaladi[index].yesterdayPrice,
          price3: controller.bydBaladi[index].firstYesterdayPrice,
          price4: controller.bydBaladi[index].fourDaysAgoPrice,
          type: 'بلدي',
        ),

        //bat

        Divider(
          color: Colors.black,
          height: 60,
        ),

        const TextUtils(
          text: 'اسعار البط',
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),

        CardViewData(
          price1: controller.batMaskufi[index].todayPrice,
          price2: controller.batMaskufi[index].yesterdayPrice,
          price3: controller.batMaskufi[index].firstYesterdayPrice,
          price4: controller.batMaskufi[index].fourDaysAgoPrice,
          type: 'مسكوفي',
        ),
        CardViewData(
          price1: controller.batMolar[index].todayPrice,
          price2: controller.batMolar[index].yesterdayPrice,
          price3: controller.batMolar[index].firstYesterdayPrice,
          price4: controller.batMolar[index].fourDaysAgoPrice,
          type: 'مولار',
        ),
        CardViewData(
          price1: controller.batFiransawi[index].todayPrice,
          price2: controller.batFiransawi[index].yesterdayPrice,
          price3: controller.batFiransawi[index].firstYesterdayPrice,
          price4: controller.batFiransawi[index].fourDaysAgoPrice,
          type: 'فرنساوي',
        ),
      ],
    );
  }
}
