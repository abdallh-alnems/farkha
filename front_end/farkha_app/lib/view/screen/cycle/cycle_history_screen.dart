import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/routes/route.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../widget/cycle/history/history_filter_bar.dart';
import '../../widget/cycle/history/history_cycle_item.dart';

class CycleHistoryScreen extends StatefulWidget {
  const CycleHistoryScreen({super.key});

  @override
  State<CycleHistoryScreen> createState() => _CycleHistoryScreenState();
}

class _CycleHistoryScreenState extends State<CycleHistoryScreen> {
  late final CycleController cycleCtrl;
  final TextEditingController _searchController = TextEditingController();
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    cycleCtrl =
        Get.isRegistered<CycleController>()
            ? Get.find<CycleController>()
            : Get.put(CycleController());
    if (cycleCtrl.searchQuery.value.isNotEmpty) {
      _searchController.text = cycleCtrl.searchQuery.value;
    }
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    await cycleCtrl.fetchHistory(isRefresh: true);
    if (mounted) {
      setState(() => _isInitialLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سجل الدورات',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor:
            isDark
                ? AppColors.darkBackGroundColor
                : AppColors.appBackGroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed<void>(AppRoute.cycleComparison);
            },
            icon: Icon(
              Icons.compare,
              size: 23.sp,
              color: colorScheme.onSurface,
            ),
            tooltip: 'مقارنة الدورات',
          ),
        ],
      ),
      body: Column(
        children: [
          HistoryFilterBar(
            isDark: isDark,
            searchController: _searchController,
            cycleCtrl: cycleCtrl,
          ),
          Expanded(
            child:
                _isInitialLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _loadHistory,
                        color: AppColors.primaryColor,
                        child: Obx(() {
                          if (cycleCtrl.historyCycles.isEmpty) {
                            return SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 150.h),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        cycleCtrl.searchQuery.value.isNotEmpty
                                            ? Icons.search_off
                                            : Icons.history,
                                        size: 64.sp,
                                        color:
                                            colorScheme.outline.withValues(alpha: 0.5),
                                      ),
                                      SizedBox(height: 16.h),
                                      Text(
                                        cycleCtrl.searchQuery.value.isNotEmpty
                                            ? 'لا توجد نتائج تطابق بحثك'
                                            : 'لا يوجد سجل دورات سابقة',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          color:
                                              colorScheme.onSurface.withValues(alpha: 0.5),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            controller: cycleCtrl.historyScrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.all(16.r),
                            itemCount:
                                cycleCtrl.historyCycles.length +
                                (cycleCtrl.isLoadingMore.value ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == cycleCtrl.historyCycles.length) {
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0.r),
                                    child: const CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final cycle = cycleCtrl.historyCycles[index];
                              return HistoryCycleItem(
                                cycle: cycle,
                                isDark: isDark,
                                cycleCtrl: cycleCtrl,
                              );
                            },
                          );
                        }),
                      ),
          ),
        ],
      ),
    );
  }
}
