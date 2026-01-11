import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constant/routes/route.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/services/initialization.dart';
import '../../../logic/controller/auth/login_controller.dart';
import '../../../logic/controller/cycle_controller.dart';

class CardCycle extends StatefulWidget {
  const CardCycle({super.key});

  @override
  State<CardCycle> createState() => _CardCycleState();
}

class _CardCycleState extends State<CardCycle> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getCurrentStage(int days) {
    if (days <= 14) return 'تحضين';
    if (days <= 30) return 'تسمين';
    return 'بيع';
  }

  int _getStageIndex(int days) {
    if (days <= 14) return 0;
    if (days <= 30) return 1;
    return 2;
  }

  Color _getStageColor(int stageIndex, bool isDark) {
    switch (stageIndex) {
      case 0:
        return isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;
      case 1:
        return isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;
      case 2:
        return isDark
            ? (Colors.orange[300] ?? Colors.orange)
            : (Colors.orange[600] ?? Colors.orange);
      default:
        return isDark
            ? AppColors.darkSurfaceColor.withValues(alpha: 0.5)
            : Colors.grey[300]!;
    }
  }

  double _getCycleTotalExpenses(String cycleName) {
    try {
      final storage = GetStorage();
      final storageKey = 'expenses_$cycleName';
      final saved = storage.read<List>(storageKey);
      if (saved != null && saved.isNotEmpty) {
        double total = 0.0;
        for (var expense in saved) {
          final payments = expense['payments'] as List<dynamic>?;
          if (payments != null) {
            for (var payment in payments) {
              total += (payment['amount'] as num?)?.toDouble() ?? 0.0;
            }
          }
        }
        return total;
      }
    } catch (e) {
      // ignore errors
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // تهيئة الـ controllers
    final cycleCtrl =
        Get.isRegistered<CycleController>()
            ? Get.find<CycleController>()
            : Get.put(CycleController());
    final loginCtrl =
        Get.isRegistered<LoginController>()
            ? Get.find<LoginController>()
            : Get.put(LoginController());

    // استخدام Obx للاستماع لتغييرات كلا الـ controllers
    return Obx(() {
      // فلترة الدورات لإخفاء الدورات المنتهية
      final allCycles = cycleCtrl.cycles;
      final cycles = allCycles.where((cycle) {
        final status = cycle['status']?.toString();
        return status != 'finished';
      }).toList();

      // تحديث حالة تسجيل الدخول من storage إذا لزم الأمر
      if (Get.isRegistered<MyServices>()) {
        final myServices = Get.find<MyServices>();
        final storedValue =
            myServices.getStorage.read<bool>('is_logged_in') ?? false;
        if (loginCtrl.isLoggedIn.value != storedValue) {
          loginCtrl.isLoggedIn.value = storedValue;
        }
      }
      final isLoggedIn = loginCtrl.isLoggedIn.value;

      // إذا كان هناك دورات والمستخدم غير مسجل الدخول
      if (cycles.isNotEmpty && !isLoggedIn) {
        return Container(
          width: double.infinity,
          height: 47.h,
          margin: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color:
                isDark
                    ? AppColors.darkSurfaceColor
                    : AppColors.lightSurfaceColor,
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Center(
            child: GestureDetector(
      onTap: () {
                Get.toNamed(AppRoute.login);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 24.sp,
                    color:
                        isDark
                            ? AppColors.darkPrimaryColor
                            : AppColors.primaryColor,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'يجب تسجيل الدخول لمتابعة الدورات',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      if (cycles.isEmpty) {
        return Container(
          width: double.infinity,
          height: 47.h,
          margin: const EdgeInsets.all(17),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color:
                isDark
                    ? AppColors.darkSurfaceColor
                    : AppColors.lightSurfaceColor,
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Stack(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoute.addCycle);
                  },
        child: Row(
                    mainAxisSize: MainAxisSize.min,
          children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 24.sp,
                        color:
                            isDark
                                ? AppColors.darkPrimaryColor
                                : AppColors.primaryColor,
                      ),
                      SizedBox(width: 8.w),
            Text(
                        'اضف دورة جديدة',
              style: TextStyle(
                          fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
              ),
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? AppColors.darkSurfaceElevatedColor.withValues(alpha: 
                              0.6,
                            )
                            : AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8.r),
                      bottomRight: Radius.circular(8.r),
                    ),
                    border: Border(
                      right: BorderSide(
                        color:
                            isDark
                                ? AppColors.darkPrimaryColor.withValues(alpha: 0.4)
                                : AppColors.primaryColor.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.menu,
                      color: isDark ? Colors.white : AppColors.primaryColor,
                      size: 18.sp,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    color:
                        isDark
                            ? AppColors.darkSurfaceColor
                            : AppColors.lightSurfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    onSelected: (value) async {
                      if (value == 'history') {
                        // Get.toNamed(AppRoute.history);
                      } else if (value == 'permissions') {
                        await openAppSettings();
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem<String>(
                          value: 'history',
                          child: Text(
                            'السجل',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'permissions',
                          child: Text(
                            'صلاحيات',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 101.h,
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              itemCount: cycles.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final cycle = cycles[index];
                return _buildCycleCard(context, cycle, index, isDark);
              },
            ),
          ),
          if (cycles.length > 1)
            Transform.translate(
              offset: Offset(0, -5.h),
              child: _buildPageIndicator(cycles.length, isDark),
            ),
          SizedBox(height: 8.h),
        ],
      );
    });
  }

  Widget _buildCycleCard(
    BuildContext context,
    Map<String, dynamic> cycle,
    int index,
    bool isDark,
  ) {
    final cycleCtrl =
        Get.isRegistered<CycleController>()
            ? Get.find<CycleController>()
            : Get.put(CycleController());
    
    // استخدام Obx لقراءة القيم المحدثة مباشرة من cycles
    return Obx(() {
      // قراءة الدورة المحدثة من cycles
      final updatedCycle = cycleCtrl.cycles.length > index 
          ? cycleCtrl.cycles[index] 
          : cycle;
      
      final startDateRaw =
          updatedCycle['startDateRaw'] as String? ?? updatedCycle['startDate'] as String? ?? '';
      final ageText = cycleCtrl.ageOf(startDateRaw);
      final age =
          ageText.isEmpty || ageText == 'لم تبدأ' ? 'لم تبدأ' : '$ageText يوم';

      // التحقق من أن الدورة لم تبدأ بعد
      final start =
          startDateRaw.isNotEmpty ? DateTime.tryParse(startDateRaw) : null;
      final isCycleNotStarted = start != null && DateTime.now().isBefore(start);

      // حساب المرحلة الحالية
      int ageDays = 0;
      String currentStage = 'لم تبدأ';
      int stageIndex = -1;
      if (startDateRaw.isNotEmpty && start != null && !isCycleNotStarted) {
        ageDays = DateTime.now().difference(start).inDays;
        stageIndex = _getStageIndex(ageDays);
        currentStage = _getCurrentStage(ageDays);
      }

      // حساب النافق
      final mortality = int.tryParse(updatedCycle['mortality']?.toString() ?? '0') ?? 0;
      final chickCount =
          int.tryParse(updatedCycle['chickCount']?.toString() ?? '0') ?? 0;

      // إجمالي المصروفات - استخدام total_expenses من API إذا كان متوفراً
      double totalExpenses = 0.0;
      if (updatedCycle['total_expenses'] != null) {
        totalExpenses = (double.tryParse(updatedCycle['total_expenses'].toString()) ?? 0.0);
      } else {
        // إذا لم يكن متوفراً من API، استخدم GetStorage كبديل
        final cycleName = updatedCycle['name'] as String? ?? '';
        totalExpenses = _getCycleTotalExpenses(cycleName);
      }

      // حساب تكلفة الفرخ
      final liveChickCount = chickCount - mortality;
      final costPerChick =
          liveChickCount > 0 ? (totalExpenses / liveChickCount) : 0.0;

    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoute.cycle, arguments: {'index': index});
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(17),
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color:
              isDark ? AppColors.darkSurfaceColor : AppColors.lightSurfaceColor,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.black, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // اسم الدورة والثلاث نقاط من الطرف إلى الطرف
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // مسافة متساوية على اليسار
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // المرحلة الحالية على اليسار
                    if (stageIndex >= 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getStageColor(stageIndex, isDark),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color:
                                isDark
                                    ? AppColors.darkPrimaryColor
                                    : AppColors.primaryColor,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark
                                      ? AppColors.darkPrimaryColor
                                      : AppColors.primaryColor)
                                  .withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          currentStage,
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark
                                    ? AppColors.darkBackGroundColor
                                    : Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                // الاسم يأخذ أكبر مساحة
                Expanded(
                  child: Center(
                    child: Text(
                      updatedCycle['name'] as String? ?? 'دورة بدون اسم',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                // مسافة متساوية على اليمين
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: isDark ? Colors.white : AppColors.primaryColor,
                        size: 16.sp,
                      ),
                      onPressed: () {
                        Get.toNamed(AppRoute.addCycle);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    SizedBox(width: 2.w),
                    // ثلاث نقاط
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: isDark ? Colors.white : AppColors.primaryColor,
                        size: 18.sp,
                      ),
                      color:
                          isDark
                              ? AppColors.darkSurfaceColor
                              : AppColors.lightSurfaceColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onSelected: (value) async {
                        if (value == 'cycleData') {
                          _showCycleDataDialog(context, updatedCycle, isDark);
                        } else if (value == 'edit') {
                          final cycleCtrl =
                              Get.isRegistered<CycleController>()
                                  ? Get.find<CycleController>()
                                  : Get.put(CycleController());
                          final data = updatedCycle;
                          final idx = cycleCtrl.cycles.indexWhere(
                            (c) => c['name'] == data['name'],
                          );
                          if (idx != -1) {
                            cycleCtrl.prepareForEdit(data, idx);
                            Get.toNamed(AppRoute.addCycle);
                          }
                        } else if (value == 'delete') {
                          await _showDeleteDialog(context, updatedCycle, isDark);
                        }
                      },
                      itemBuilder: (context) {
                        final theme = Theme.of(context);
                        final colorScheme = theme.colorScheme;
                        return [
                          PopupMenuItem<String>(
                            value: 'cycleData',
                            child: Text(
                              'بيانات الدورة',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Text(
                              'تعديل',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Text(
                              'حذف',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: colorScheme.error,
                              ),
                            ),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 1.h),
            // البيانات المختصرة أو رسالة "ستبدأ الدورة في"
            if (isCycleNotStarted)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Center(
                  child: Text(
                    'ستبدأ الدورة في : ${DateFormat('MM-dd').format(start)} (${DateFormat('EEEE', 'ar').format(start)})',
                    style: TextStyle(
                      color:
                          isDark
                              ? AppColors.darkPrimaryColor
                              : AppColors.primaryColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Center(
                      child: _buildInfoRow(
                        Icons.calendar_today,
                        'العمر',
                        age,
                        isDark,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _buildInfoRow(
                        Icons.agriculture,
                        'العدد',
                        '${chickCount - mortality}',
                        isDark,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _buildInfoRow(
                        Icons.attach_money,
                        'المصروفات',
                        totalExpenses.toStringAsFixed(0),
                        isDark,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _buildInfoRow(
                        Icons.monetization_on,
                        'تكلفة الفرخ',
                        costPerChick > 0
                            ? costPerChick.round().toString()
                            : '0',
                        isDark,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
    });
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 8.5.sp,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 8.5.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPageIndicator(int itemCount, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          width: _currentPage == index ? 8.w : 6.w,
          height: 6.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                _currentPage == index
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  void _showCycleDataDialog(
    BuildContext context,
    Map<String, dynamic> cycle,
    bool isDark,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor:
            isDark ? AppColors.darkSurfaceColor : AppColors.lightSurfaceColor,
        title: Text(
          'بيانات الدورة',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogRow('الاسم', cycle['name'] ?? '-', isDark),
            SizedBox(height: 9.h),
            _buildDialogRow('نوع الدورة', 'تسمين', isDark),
            SizedBox(height: 9.h),
            _buildDialogRow('عدد الفراخ', cycle['chickCount'] ?? '-', isDark),
            SizedBox(height: 9.h),
            _buildDialogRow(
              'المساحة',
              cycle['space'] != null && cycle['space'] != '0' && cycle['space'] != '-'
                  ? '${cycle['space']} م²'
                  : '-',
              isDark,
            ),
            SizedBox(height: 9.h),
            _buildDialogRow('نظام التربية', 'ارضي', isDark),
            SizedBox(height: 9.h),
            _buildDialogRow('تاريخ البدء', cycle['startDate'] ?? '-', isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'حسناً',
              style: TextStyle(
                color:
                    isDark
                        ? AppColors.darkPrimaryColor
                        : AppColors.primaryColor,
                fontSize: 14.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final cycleCtrl =
                  Get.isRegistered<CycleController>()
                      ? Get.find<CycleController>()
                      : Get.put(CycleController());
              final data = cycle;
              final idx = cycleCtrl.cycles.indexWhere(
                (c) => c['name'] == data['name'],
              );
              if (idx != -1) {
                cycleCtrl.prepareForEdit(data, idx);
                Get.back();
                Get.toNamed(AppRoute.addCycle);
              }
            },
            child: Text(
              'تعديل',
              style: TextStyle(
                color:
                    isDark
                        ? AppColors.darkPrimaryColor
                        : AppColors.primaryColor,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label : ',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    Map<String, dynamic> cycle,
    bool isDark,
  ) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor:
            isDark ? AppColors.darkSurfaceColor : AppColors.lightSurfaceColor,
        content: Text(
          'هل تريد حذف دورة ${cycle['name']}؟',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 16.sp,
          ),
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'لا',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'نعم',
              style: TextStyle(color: colorScheme.error, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final cycleCtrl =
          Get.isRegistered<CycleController>()
              ? Get.find<CycleController>()
              : Get.put(CycleController());
      cycleCtrl.currentCycle.assignAll(cycle);
      await cycleCtrl.deleteCurrentCycle();
    }
  }
}
