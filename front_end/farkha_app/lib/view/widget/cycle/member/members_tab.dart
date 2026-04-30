import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constant/storage_keys.dart';
import '../../../../core/constant/strings/app_strings.dart';
import '../../../../core/constant/theme/colors.dart';
import '../../../../core/services/initialization.dart';
import '../../../../logic/controller/cycle_controller.dart';
import 'overlay_toast.dart';

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
    if (_isFetching) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: CircularProgressIndicator(color: AppColors.primaryColor),
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
                color: widget.isDark ? Colors.white70 : Colors.black87,
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
                      color: widget.isDark ? Colors.white24 : Colors.black26),
                  SizedBox(height: 8.h),
                  Text(
                    'لا يوجد أعضاء في الدورة',
                    style: TextStyle(
                      color: widget.isDark ? Colors.white38 : Colors.black45,
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
          return _MemberCard(
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

class _MemberCard extends StatefulWidget {
  final Map<String, dynamic> member;
  final bool isDark;
  final CycleController cycleCtrl;
  final bool isOwner;
  final bool isCurrentUser;

  const _MemberCard({
    required this.member,
    required this.isDark,
    required this.cycleCtrl,
    required this.isOwner,
    required this.isCurrentUser,
  });

  @override
  State<_MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<_MemberCard> {
  bool _isUpdatingRole = false;
  bool _isRemoving = false;

  String get _memberRole => widget.member['role']?.toString() ?? 'viewer';
  String get _memberName =>
      (widget.member['name'] ?? widget.member['phone'] ?? 'عضو').toString();
  String get _memberPhone => widget.member['phone']?.toString() ?? '';
  bool get _isPending => widget.member['status'] == 'pending';

  int? get _userId {
    final raw = widget.member['id'];
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '');
  }

  void _changeRole(String newRole) {
    if (_userId == null || _isUpdatingRole) return;

    final roleLabel = newRole == 'admin' ? 'مشرف' : 'متابع';

    showDialog<bool>(
      context: Get.context!,
      builder: (ctx) => AlertDialog(
        title: const Text('تغيير الصلاحية'),
        content: Text(
          'هل أنت متأكد من تغيير صلاحية $_memberName إلى "$roleLabel"؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed != true || !mounted) return;

      setState(() => _isUpdatingRole = true);

      final result = await widget.cycleCtrl.updateMemberRole(
        targetUserId: _userId!,
        newRole: newRole,
      );

      if (!mounted) return;
      setState(() => _isUpdatingRole = false);

      if (result != null && result['status'] == 'success') {
        showOverlayToast('تم تغيير الصلاحية بنجاح');
      } else {
        showOverlayToast(
          result?['message']?.toString() ?? 'فشل تغيير الصلاحية',
          isError: true,
        );
      }
    });
  }

  void _confirmRemove() {
    if (_userId == null) return;
    showDialog<void>(
      context: Get.context!,
      builder: (ctx) => AlertDialog(
        title: const Text('إزالة عضو'),
        content: Text('هل أنت متأكد من إزالة $_memberName من الدورة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final result =
                  await widget.cycleCtrl.removeMemberDirect(_userId!);
              final isSuccess = result['status'] == 'success';
              showOverlayToast(
                result['message']?.toString() ??
                    (isSuccess ? 'تم حذف العضو' : 'فشل حذف العضو'),
                isError: !isSuccess,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('إزالة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMemberOwner = _memberRole == 'owner';
    final bool isAdmin = _memberRole == 'admin';
    final bool canEdit =
        widget.isOwner && !widget.isCurrentUser && !isMemberOwner;

    IconData avatarIcon;
    Color avatarBg;
    Color avatarIconColor;
    if (isMemberOwner) {
      avatarIcon = Icons.workspace_premium_rounded;
      avatarBg = Colors.amber.withValues(alpha: 0.15);
      avatarIconColor = Colors.amber.shade700;
    } else if (isAdmin) {
      avatarIcon = Icons.manage_accounts_rounded;
      avatarBg = AppColors.primaryColor.withValues(alpha: 0.15);
      avatarIconColor = AppColors.primaryColor;
    } else {
      avatarIcon = Icons.remove_red_eye_rounded;
      avatarBg = Colors.blueGrey.withValues(alpha: 0.12);
      avatarIconColor = Colors.blueGrey;
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: _isPending
              ? Colors.orange.withValues(alpha: 0.4)
              : isMemberOwner
                  ? Colors.amber.withValues(alpha: 0.3)
                  : (widget.isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.withValues(alpha: 0.15)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: avatarBg,
                child: Icon(avatarIcon, color: avatarIconColor, size: 20.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _memberName,
                            style: TextStyle(
                              color: widget.isDark
                                  ? Colors.white
                                  : Colors.black87,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.isCurrentUser) ...[
                          SizedBox(width: 5.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                  color: AppColors.primaryColor
                                      .withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              'أنت',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (_memberPhone.isNotEmpty)
                      Text(
                        _memberPhone,
                        style: TextStyle(
                          color: widget.isDark
                              ? Colors.white54
                              : Colors.black45,
                          fontSize: 11.sp,
                        ),
                        textDirection: ui.TextDirection.ltr,
                      ),
                  ],
                ),
              ),
              if (_isPending)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'في انتظار القبول',
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600),
                  ),
                )
              else if (isMemberOwner)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'صاحب الدورة',
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.amber.shade700,
                        fontWeight: FontWeight.w600),
                  ),
                )
              else if (isAdmin)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                        color: AppColors.primaryColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'مشرف',
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
                )
              else
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                        color: Colors.blueGrey.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'متابع',
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),

          if (!_isPending && canEdit) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _isUpdatingRole
                      ? Center(
                          child: SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            _RoleChip(
                              label: 'مشرف',
                              role: 'admin',
                              currentRole: _memberRole,
                              isDark: widget.isDark,
                              icon: Icons.manage_accounts_rounded,
                              onTap: () => _changeRole('admin'),
                            ),
                            SizedBox(width: 6.w),
                            _RoleChip(
                              label: 'متابع',
                              role: 'viewer',
                              currentRole: _memberRole,
                              isDark: widget.isDark,
                              icon: Icons.remove_red_eye_rounded,
                              onTap: () => _changeRole('viewer'),
                            ),
                          ],
                        ),
                ),
                SizedBox(width: 8.w),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                        color: Colors.red.withValues(alpha: 0.2)),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.person_remove_rounded,
                        color: Colors.red, size: 18.sp),
                    onPressed: _isRemoving ? null : _confirmRemove,
                    tooltip: 'إزالة العضو',
                    padding: EdgeInsets.all(6.w),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final String role;
  final String currentRole;
  final bool isDark;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.role,
    required this.currentRole,
    required this.isDark,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = currentRole == role;
    return GestureDetector(
      onTap: isSelected ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.12)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.grey[50]),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : (isDark ? Colors.white24 : Colors.grey.shade300),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14.sp,
                color: isSelected
                    ? AppColors.primaryColor
                    : (isDark ? Colors.white38 : Colors.grey[500])),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryColor
                    : (isDark ? Colors.white54 : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
