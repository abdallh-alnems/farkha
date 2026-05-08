import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constant/storage_keys.dart';
import '../../../../core/constant/theme/colors.dart';
import '../../../../core/services/initialization.dart';
import '../../../../logic/controller/cycle_controller.dart';
import 'member_list_item.dart';

class MembersTab extends StatefulWidget {
  final bool isDark;
  final int? cycleId;
  final bool shrinkWrap;
  const MembersTab({
    super.key,
    required this.isDark,
    required this.cycleId,
    this.shrinkWrap = false,
  });

  @override
  State<MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends State<MembersTab> {
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fetchMembers();
    });
  }

  Future<void> _fetchMembers() async {
    final cycleId = widget.cycleId;
    if (cycleId == null) return;
    if (mounted) setState(() => _isFetching = true);

    final cycleCtrl = Get.find<CycleController>();

    final currentId = cycleCtrl.currentCycle['cycle_id'];
    final currentIdInt =
        currentId is int ? currentId : int.tryParse(currentId?.toString() ?? '');
    if (currentIdInt != cycleId) {
      final idx = cycleCtrl.cycles.indexWhere((c) {
        final cId = c['cycle_id'];
        final cIdInt = cId is int ? cId : int.tryParse(cId?.toString() ?? '');
        return cIdInt == cycleId;
      });
      if (idx != -1) {
        cycleCtrl.currentCycle.assignAll(cycleCtrl.cycles[idx]);
      }
    }

    await cycleCtrl.fetchCycleDetails(cycleId);
    if (mounted) setState(() => _isFetching = false);
  }

  Map<String, dynamic>? _findCycle(CycleController cycleCtrl) {
    final cycleId = widget.cycleId;
    if (cycleId == null) return null;

    final currentId = cycleCtrl.currentCycle['cycle_id'];
    final currentIdInt =
        currentId is int ? currentId : int.tryParse(currentId?.toString() ?? '');
    if (currentIdInt == cycleId) return cycleCtrl.currentCycle;

    final idx = cycleCtrl.cycles.indexWhere((c) {
      final cId = c['cycle_id'];
      final cIdInt = cId is int ? cId : int.tryParse(cId?.toString() ?? '');
      return cIdInt == cycleId;
    });
    if (idx != -1) return cycleCtrl.cycles[idx];

    return cycleCtrl.currentCycle;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_isFetching) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: const CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      );
    }

    final cycleCtrl = Get.find<CycleController>();
    final myServices = Get.find<MyServices>();
    final String currentUserPhone =
        myServices.getStorage.read<String>(StorageKeys.userPhone) ?? '';

    return Obx(() {
      final cycle = _findCycle(cycleCtrl);
      final List<dynamic> members =
          (cycle?['members'] as List?) ?? [];
      final bool isOwner = cycle?['is_owner'] == true;

      final header = Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
        child: Row(
          children: [
            Icon(Icons.people_rounded,
                size: 16.sp, color: AppColors.primaryColor),
            SizedBox(width: 6.w),
            Text(
              'الأعضاء الحاليون',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(width: 6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${members.length}',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
      );

      if (members.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.group_off_rounded,
                      size: 40.sp,
                      color: colorScheme.onSurface.withValues(alpha: 0.2)),
                  SizedBox(height: 8.h),
                  Text(
                    'لا يوجد أعضاء في الدورة',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }

      final list = ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
        shrinkWrap: widget.shrinkWrap,
        physics: widget.shrinkWrap
            ? const NeverScrollableScrollPhysics()
            : null,
        itemCount: members.length,
        separatorBuilder: (ctx, i) => SizedBox(height: 8.h),
        itemBuilder: (ctx, i) {
          final Map<String, dynamic> member =
              Map<String, dynamic>.from(members[i] as Map);
          final String memberPhone = member['phone']?.toString() ?? '';
          final bool isCurrentUser = currentUserPhone.isNotEmpty &&
              memberPhone == currentUserPhone;
          return MemberListItem(
            member: member,
            isDark: widget.isDark,
            cycleCtrl: cycleCtrl,
            isOwner: isOwner,
            isCurrentUser: isCurrentUser,
          );
        },
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          widget.shrinkWrap ? list : Expanded(child: list),
        ],
      );
    });
  }
}
