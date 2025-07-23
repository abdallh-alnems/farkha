import 'package:farkha_app/core/constant/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CycleStatsBarExplanation extends StatelessWidget {
  const CycleStatsBarExplanation({super.key});

  @override
  Widget build(BuildContext context) {
    const tabs = <String>['ADG', 'FCR', 'النفوق', 'تكلفة الفرخ'];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: AppColor.appBackGroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Top bar: back button and tabs
              Container(
                color: AppColor.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    Expanded(
                      child: TabBar(
                        isScrollable: true,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white54,
                        indicatorColor: Colors.white,
                        tabs: tabs.map((t) => Tab(text: t)).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Content area
              Expanded(
                child: TabBarView(
                  children:
                      tabs.map((t) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(color: Colors.black),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'هنا تضع الشرح التفصيلي للعنصر.',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Text(
                                    'تفاصيل ومحتوى موسع يشرح هذا الجزء من الإحصائيات. يمكنك وضع نصوص طويلة أو رسوم بيانية أو حتى صور هنا حسب الحاجة.',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
