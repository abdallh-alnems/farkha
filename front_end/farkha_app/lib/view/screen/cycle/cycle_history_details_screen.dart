import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/services/pdf/pdf_export_service.dart';
import '../../../logic/controller/cycle_controller.dart';

class CycleHistoryDetailsScreen extends StatelessWidget {
  const CycleHistoryDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cycleCtrl = Get.find<CycleController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? AppColors.darkBackGroundColor
              : const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final cycle = cycleCtrl.historicCycleDetails;
          if (cycle.isNotEmpty) {
            try {
              await PdfExportService.exportCycleReport(cycle);
            } catch (e) {
              Get.snackbar(
                'خطأ في التصدير',
                'حدث خطأ غير متوقع، ربما تحتاج لإعادة فتح التطبيق ليتم تفعيل ميزة الطباعة.',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          }
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.picture_as_pdf, color: Colors.white),
        tooltip: 'تصدير كملف PDF',
      ),
      body: Obx(() {
        final status = cycleCtrl.historicCycleStatus.value;
        final cycle = cycleCtrl.historicCycleDetails;
        
        if (cycle.isEmpty) {
          return const Center(child: Text('لا توجد بيانات متاحة'));
        }

        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                _buildHeaderSliver(cycle, isDark),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 40.h),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSummary(cycle, isDark, context),
                    ]),
                  ),
                ),
              ],
            ),
            if (status == StatusRequest.loading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      }),
    );
  }

  // ========================== HEADER ==========================

  Widget _buildHeaderSliver(Map<String, dynamic> cycle, bool isDark) {
    final name = cycle['name']?.toString() ?? 'دورة بدون اسم';
    final breed = cycle['breed']?.toString() ?? 'تسمين';
    final systemType = cycle['systemType']?.toString() ?? 'أرضي';

    return SliverToBoxAdapter(
      child: Stack(
        children: [
          Container(
            height: 160.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.darkSurfaceElevatedColor, AppColors.darkBackGroundColor]
                    : [AppColors.primaryColor, AppColors.primaryColor.withValues(alpha: 0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32.r),
                bottomRight: Radius.circular(32.r),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    onPressed: () => Get.back<void>(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.2),
                      padding: EdgeInsets.all(10.r),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'تقرير الدورة التفصيلي',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 40.w),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 100.h, left: 16.w, right: 16.w, bottom: 20.h),
            child: Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceColor : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: isDark 
                      ? Colors.black.withValues(alpha: 0.3)
                      : AppColors.primaryColor.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                   Text(
                    name,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.secondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (breed.isNotEmpty) _buildTag(breed, Colors.blueAccent, isDark),
                      if (breed.isNotEmpty) SizedBox(width: 8.w),
                      if (systemType.isNotEmpty) _buildTag(systemType, AppColors.sunsetGradientEnd, isDark),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.4 : 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12.sp, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ========================== DASHBOARD & BUTTONS ==========================

  Widget _buildSummary(Map<String, dynamic> cycle, bool isDark, BuildContext context) {
    final startDate = cycle['startDate']?.toString() ?? '-';
    final endDate = cycle['endDate']?.toString() ?? '-';
    final cycleAge = cycle['cycle_age']?.toString() ?? '0';

    final chickCount = cycle['chickCount']?.toString() ?? '0';
    final space = cycle['space']?.toString() ?? '0';
    final liveCount =
        (int.tryParse(chickCount) ?? 0) -
        (int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0);
    final mortality = cycle['mortality']?.toString() ?? '0';
    final mortalityRate = cycle['mortality_rate']?.toString() ?? '0.0';

    final fcr = cycle['fcr']?.toString() ?? '0.00';
    final costPerBird = cycle['cost_per_bird']?.toString() ?? '0.00';
    final averageWeight =
        double.tryParse(cycle['average_weight']?.toString() ?? '0') ?? 0.0;
    
    final totalMeat = liveCount * averageWeight;

    final totalExpenses =
        double.tryParse(cycle['total_expenses']?.toString() ?? '0') ?? 0.0;
    final totalSales =
        double.tryParse(cycle['total_sales']?.toString() ?? '0') ?? 0.0;
    final netProfit =
        double.tryParse(cycle['net_profit']?.toString() ?? '0') ?? 0.0;
    final totalFeed =
        double.tryParse(cycle['total_feed']?.toString() ?? '0') ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoRow(
          icon: Icons.date_range,
          title: 'تاريخ الدورة',
          value: '$startDate - $endDate',
          isDark: isDark,
        ),
        _buildInfoRow(
          icon: Icons.timelapse_rounded,
          title: 'عمر الدورة',
          value: '$cycleAge يوم',
          isDark: isDark,
        ),
        if (space.isNotEmpty && space != '0')
          _buildInfoRow(
            icon: Icons.square_foot,
            title: 'مساحة العنبر',
            value: '$space متر مربع',
            isDark: isDark,
          ),
        SizedBox(height: 16.h),
        
        // Removed separate action cards as they are now integrated into headers/rows below

        SizedBox(height: 24.h),
        _buildSectionTitle(
          'أداء القطيع والمخرجات 📊',
          isDark,
          suffix: InkWell(
            onTap: () => _openBottomSheet(context, 'السجلات والملاحظات اليومية', _buildDailyRecordsList(cycle, isDark)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: (isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor).withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Icon(
                    Icons.notes_rounded, 
                    size: 16.sp, 
                    color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'الملاحظات',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        _buildGrid(
          isDark: isDark,
          items: [
            _GridItem(
              label: 'العدد الأولي',
              value: chickCount,
              color: Colors.blueAccent,
            ),
            _GridItem(
              label: 'المتبقي',
              value: liveCount.toString(),
              color: const Color(0xFF10B981),
            ),
            _GridItem(
              label: 'النافق',
              value: '$mortality ($mortalityRate%)',
              color: const Color(0xFFF43F5E),
            ),
            _GridItem(
              label: 'معامل التحويل',
              value: fcr,
              color: const Color(0xFF6366F1),
            ),
            _GridItem(
              label: 'متوسط الوزن',
              value: '${averageWeight.toStringAsFixed(1)} كجم',
              color: const Color(0xFF9333EA),
            ),
            _GridItem(
              label: 'إجمالي اللحم',
              value: '${totalMeat.toStringAsFixed(0)} كجم',
              color: const Color(0xFFEAB308),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        _buildSectionTitle('المالية والمخزون 💰', isDark),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceColor : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: isDark ? [] : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(20.r),
          child: Column(
            children: [
              _buildFinancialRow('تكلفة الفرخ', '$costPerBird ج', Colors.orange, isDark),
              Divider(color: isDark ? Colors.grey[800] : Colors.grey[200], height: 24.h),
              _buildFinancialRow('إجمالي العلف', '${totalFeed.toStringAsFixed(0)} كجم', Colors.brown, isDark),
              Divider(color: isDark ? Colors.grey[800] : Colors.grey[200], height: 24.h),
              _buildFinancialRow(
                'المصروفات الكلية',
                '${totalExpenses.toStringAsFixed(0)} ج',
                const Color(0xFFF43F5E),
                isDark,
                suffix: InkWell(
                  onTap: () => _openBottomSheet(context, 'المصروفات التفصيلية', _buildExpensesList(cycle, isDark)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Icon(Icons.info_outline, size: 16.sp, color: const Color(0xFFF43F5E)),
                  ),
                ),
              ),
              Divider(color: isDark ? Colors.grey[800] : Colors.grey[200], height: 24.h),
              _buildFinancialRow('المبيعات الكلية', '${totalSales.toStringAsFixed(0)} ج', const Color(0xFF10B981), isDark),
              Divider(color: isDark ? Colors.grey[800] : Colors.grey[200], height: 24.h),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: netProfit >= 0
                      ? const Color(0xFF10B981).withValues(alpha: 0.1)
                      : const Color(0xFFF43F5E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: netProfit >= 0
                        ? const Color(0xFF10B981).withValues(alpha: 0.3)
                        : const Color(0xFFF43F5E).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التصفية (الصافي)',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${netProfit.toStringAsFixed(0)} ج',
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: netProfit >= 0 ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Removed _buildActionButtons and _buildClickableTextRow as requested


  void _openBottomSheet(BuildContext context, String title, Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.bottomSheet<void>(
      Container(
        height: Get.height * 0.8,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackGroundColor : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
              width: 50.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Divider(color: Colors.grey.withValues(alpha: 0.2)),
            Expanded(child: child),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ========================== BOTTOM SHEET LISTS ==========================

  Widget _buildExpensesList(Map<String, dynamic> cycle, bool isDark) {
    final expenses = (cycle['expenses'] as List?) ?? [];
    if (expenses.isEmpty) {
      return Center(
        child: Text(
          'لا توجد مصروفات מסجلة',
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final exp = expenses[index];
        final type = exp['type']?.toString() ?? 'أخرى';
        final amount = double.tryParse(exp['amount']?.toString() ?? '0') ?? 0.0;
        final rawDate = exp['created_at']?.toString() ?? '';
        final notes = exp['notes']?.toString() ?? '';
        
        String formattedDate = rawDate;
        if (formattedDate.isNotEmpty && !formattedDate.contains('/')) {
            try {
               final temp = DateTime.parse(rawDate);
               formattedDate = DateFormat('yyyy/MM/dd').format(temp);
            } catch (_) {}
        }

        IconData iconData = Icons.attach_money;
        Color iconColor = Colors.grey;

        if (type == 'feed' || type == 'علف') {
          iconData = Icons.agriculture;
          iconColor = Colors.brown;
        } else if (type == 'medicine' || type == 'adwya' || type == 'أدوية') {
          iconData = Icons.medication;
          iconColor = Colors.blue;
        } else if (type == 'chicks' || type == 'كتاكيت') {
          iconData = Icons.pets;
          iconColor = Colors.orange;
        } else if (type == 'labor' || type == 'amal') {
          iconData = Icons.engineering;
          iconColor = Colors.teal;
        } else {
          iconData = Icons.monetization_on;
          iconColor = Colors.purple;
        }

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
           decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceColor : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
            ),
            boxShadow: isDark ? [] : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            leading: CircleAvatar(
              backgroundColor: iconColor.withValues(alpha: 0.1),
              child: Icon(iconData, color: iconColor),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                   _getExpenseTypeNameAr(type),
                   style: TextStyle(
                     fontWeight: FontWeight.bold,
                     fontSize: 15.sp,
                     color: isDark ? Colors.white : Colors.black87,
                   ),
                 ),
                 Text(
                   '${amount.toStringAsFixed(1)} ج',
                   style: TextStyle(
                     fontWeight: FontWeight.w900,
                     fontSize: 16.sp,
                     color: const Color(0xFFF43F5E),
                   ),
                 ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 6.h),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                ),
                if (notes.isNotEmpty && notes != 'null') ...[
                  SizedBox(height: 4.h),
                  Text(
                    notes,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyRecordsList(Map<String, dynamic> cycle, bool isDark) {
    final feedEntries = (cycle['feedEntries'] as List?) ?? [];
    final mortalityEntries = (cycle['mortalityEntries'] as List?) ?? [];
    final weightEntries = (cycle['weightEntries'] as List?) ?? [];
    final customDataEntries = (cycle['customDataEntries'] as List?) ?? [];

    final allDates = <String>{};
    for (var entry in feedEntries) { allDates.add(entry['date']?.toString() ?? ''); }
    for (var entry in mortalityEntries) { allDates.add(entry['date']?.toString() ?? ''); }
    for (var entry in weightEntries) { allDates.add(entry['date']?.toString() ?? ''); }
    for (var entry in customDataEntries) { 
        if (entry['element_type'] == 'note') {
            allDates.add(entry['date']?.toString() ?? '');
        }
    }
    allDates.removeWhere((element) => element.isEmpty);

    final sortedDates = allDates.toList()..sort();

    if (sortedDates.isEmpty) {
      return Center(
        child: Text(
          'لا توجد سجلات بيانات مسجلة',
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        double tFeed = 0;
        int tMortality = 0;
        double tWeight = 0;
        final notes = <String>[];

        for (var e in feedEntries) {
          if (e['date'] == date && e['amount'] != null) tFeed += double.tryParse(e['amount'].toString()) ?? 0;
        }
        for (var e in mortalityEntries) {
          if (e['date'] == date && e['count'] != null) tMortality += int.tryParse(e['count'].toString()) ?? 0;
        }
        for (var e in weightEntries) {
          if (e['date'] == date && e['weight'] != null) {
            tWeight = double.tryParse(e['weight'].toString()) ?? 0;
          }
        }
        for (var e in customDataEntries) {
          if (e['date'] == date && e['element_type'] == 'note' && e['value'] != null) {
            notes.add(e['value'].toString());
          }
        }

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceColor : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
            ),
            boxShadow: isDark ? [] : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_note, size: 18.sp, color: AppColors.primaryColor),
                    SizedBox(width: 8.w),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 15.sp, 
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (tFeed > 0) _buildDailyMetric('علف', '${tFeed.toStringAsFixed(1)} كجم', Colors.brown, isDark),
                        if (tMortality > 0) _buildDailyMetric('نافق', '$tMortality طير', const Color(0xFFF43F5E), isDark),
                        if (tWeight > 0) _buildDailyMetric('وزن', '${tWeight.toStringAsFixed(2)} كجم', const Color(0xFF9333EA), isDark),
                      ],
                    ),
                    if (tFeed <= 0 && tMortality <= 0 && tWeight <= 0 && notes.isEmpty)
                      Center(child: Text('عنصر فارغ', style: TextStyle(color: Colors.grey[500], fontSize: 13.sp))),
                    if (notes.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
                      SizedBox(height: 8.h),
                      Text(
                        'الملاحظات:',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      ...notes.map((note) => Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(color: AppColors.primaryColor, fontSize: 16.sp)),
                            Expanded(
                              child: Text(
                                note,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: isDark ? Colors.white : Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyMetric(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getExpenseTypeNameAr(String type) {
    if (type == 'feed') return 'علف';
    if (type == 'medicine' || type == 'adwya') return 'أدوية وتحصينات';
    if (type == 'chicks') return 'كتاكيت';
    if (type == 'labor' || type == 'amal') return 'عمالة وإيجار';
    if (type == 'other') return 'أخرى';
    return type;
  }

  // ========================== HELPER WIDGETS ==========================

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark, {Widget? suffix}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.secondaryColor,
            ),
          ),
          if (suffix != null) suffix,
        ],
      ),
    );
  }

  Widget _buildGrid({required bool isDark, required List<_GridItem> items}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceElevatedColor : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
            ),
            boxShadow: isDark ? [] : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.value,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFinancialRow(
    String title,
    String value,
    Color iconColor,
    bool isDark, {
    Widget? suffix,
  }) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        if (suffix != null) suffix,
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 15.sp,
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _GridItem {
  final String label;
  final String value;
  final Color color;

  _GridItem({required this.label, required this.value, required this.color});
}
