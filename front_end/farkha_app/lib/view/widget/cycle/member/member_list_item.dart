import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constant/strings/app_strings.dart';
import '../../../../core/constant/theme/colors.dart';
import '../../../../logic/controller/cycle_controller.dart';
import 'overlay_toast.dart';

class MemberListItem extends StatefulWidget {
  final Map<String, dynamic> member;
  final bool isDark;
  final CycleController cycleCtrl;
  final bool isOwner;
  final bool isCurrentUser;

  const MemberListItem({
    super.key,
    required this.member,
    required this.isDark,
    required this.cycleCtrl,
    required this.isOwner,
    required this.isCurrentUser,
  });

  @override
  State<MemberListItem> createState() => _MemberListItemState();
}

class _MemberListItemState extends State<MemberListItem> {
  bool _isUpdatingRole = false;
  final bool _isRemoving = false;

  String get _memberRole =>
      widget.member['role']?.toString() ?? 'viewer';
  String get _memberName =>
      (widget.member['name'] ?? widget.member['phone'] ?? 'عضو')
          .toString();
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
    final colorScheme = Theme.of(context).colorScheme;
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
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: _isPending
              ? Colors.orange.withValues(alpha: 0.4)
              : isMemberOwner
                  ? Colors.amber.withValues(alpha: 0.3)
                  : colorScheme.onSurface.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: widget.isDark ? 0.15 : 0.04),
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
                child: Icon(avatarIcon,
                    color: avatarIconColor, size: 20.sp),
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
                              color: colorScheme.onSurface,
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
                              borderRadius:
                                  BorderRadius.circular(6.r),
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
                          color: colorScheme.onSurface
                              .withValues(alpha: 0.45),
                          fontSize: 11.sp,
                        ),
                        textDirection: ui.TextDirection.ltr,
                      ),
                  ],
                ),
              ),
              _buildRoleBadge(
                colorScheme: colorScheme,
                isPending: _isPending,
                isMemberOwner: isMemberOwner,
                isAdmin: isAdmin,
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
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            RoleChip(
                              label: 'مشرف',
                              role: 'admin',
                              currentRole: _memberRole,
                              isDark: widget.isDark,
                              icon:
                                  Icons.manage_accounts_rounded,
                              onTap: () => _changeRole('admin'),
                            ),
                            SizedBox(width: 6.w),
                            RoleChip(
                              label: 'متابع',
                              role: 'viewer',
                              currentRole: _memberRole,
                              isDark: widget.isDark,
                              icon:
                                  Icons.remove_red_eye_rounded,
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

  Widget _buildRoleBadge({
    required ColorScheme colorScheme,
    required bool isPending,
    required bool isMemberOwner,
    required bool isAdmin,
  }) {
    if (isPending) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
        ),
        child: Text(
          'في انتظار القبول',
          style: TextStyle(
              fontSize: 10.sp,
              color: Colors.orange,
              fontWeight: FontWeight.w600),
        ),
      );
    } else if (isMemberOwner) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
        ),
        child: Text(
          'صاحب الدورة',
          style: TextStyle(
              fontSize: 10.sp,
              color: Colors.amber.shade700,
              fontWeight: FontWeight.w600),
        ),
      );
    } else if (isAdmin) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
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
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: Colors.blueGrey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          border:
              Border.all(color: Colors.blueGrey.withValues(alpha: 0.5)),
        ),
        child: Text(
          'متابع',
          style: TextStyle(
              fontSize: 10.sp,
              color: Colors.blueGrey,
              fontWeight: FontWeight.w600),
        ),
      );
    }
  }
}

class RoleChip extends StatelessWidget {
  final String label;
  final String role;
  final String currentRole;
  final bool isDark;
  final IconData icon;
  final VoidCallback onTap;

  const RoleChip({
    super.key,
    required this.label,
    required this.role,
    required this.currentRole,
    required this.isDark,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isSelected = currentRole == role;
    return GestureDetector(
      onTap: isSelected ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.12)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : colorScheme.outline.withValues(alpha: 0.3),
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
                    : colorScheme.onSurface.withValues(alpha: 0.4)),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryColor
                    : colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
