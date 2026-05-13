import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/theme/colors.dart';
import '../../../../core/shared/formatters/arabic_to_english_digits_formatter.dart';

class AddMemberTab extends StatelessWidget {
  final bool isDark;
  final bool isOwner;
  final TextEditingController phoneController;
  final bool isSearching;
  final bool isAddingMember;
  final bool isLoadingInvitation;
  final String selectedRole;
  final Map<String, dynamic>? selectedUser;
  final String? resultMessage;
  final bool isResultError;
  final String? invitationCode;
  final String? invitationLink;
  final VoidCallback onSearch;
  final VoidCallback onPickContact;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onAdd;
  final VoidCallback onGenerateInvitation;
  final VoidCallback onCopyLink;

  const AddMemberTab({
    super.key,
    required this.isDark,
    required this.isOwner,
    required this.phoneController,
    required this.isSearching,
    required this.isAddingMember,
    required this.isLoadingInvitation,
    required this.selectedRole,
    required this.selectedUser,
    required this.resultMessage,
    required this.isResultError,
    required this.invitationCode,
    required this.invitationLink,
    required this.onSearch,
    required this.onPickContact,
    required this.onRoleChanged,
    required this.onAdd,
    required this.onGenerateInvitation,
    required this.onCopyLink,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (!isOwner) return const SizedBox.shrink();

    final Color muted = colorScheme.onSurface.withValues(alpha: 0.35);

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'أدخل رقم هاتف المستخدم المسجل في التطبيق',
            style: TextStyle(
              color: muted,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  inputFormatters: [ArabicToEnglishDigitsFormatter()],
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 15.sp,
                    letterSpacing: 2,
                  ),
                  decoration: InputDecoration(
                    hintText: '01xxxxxxxxx',
                    counterText: '',
                    prefixIcon: Icon(Icons.phone_android_rounded,
                        color: muted, size: 20.sp),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                          color: AppColors.primaryColor.withValues(alpha: 0.5)),
                    ),
                  ),
                  onChanged: (val) {
                    if (val.length == 11) onSearch();
                  },
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                icon: Icon(Icons.contacts_rounded,
                    color: muted, size: 22.sp),
                onPressed: onPickContact,
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ],
          ),

          if (isSearching)
            Padding(
              padding: EdgeInsets.all(20.h),
              child: const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryColor, strokeWidth: 2)),
            ),

          if (resultMessage != null) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  isResultError
                      ? Icons.error_outline_rounded
                      : Icons.check_circle_outline_rounded,
                  color: isResultError
                      ? AppColors.errorColor
                      : AppColors.primaryColor,
                  size: 16.sp,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    resultMessage!,
                    style: TextStyle(
                      color: isResultError
                          ? AppColors.errorColor
                          : AppColors.primaryColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (selectedUser != null && !isSearching) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: colorScheme.onSurface
                        .withValues(alpha: 0.06),
                    child: Icon(Icons.person,
                        color: muted, size: 22.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedUser!['name']?.toString() ?? 'بدون اسم',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          selectedUser!['phone']?.toString() ?? '',
                          style: TextStyle(
                            color: muted,
                            fontSize: 11.sp,
                          ),
                          textDirection: ui.TextDirection.ltr,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'اختر الصلاحية',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: _RoleButton(
                    label: 'مشرف',
                    role: 'admin',
                    selectedRole: selectedRole,
                    icon: Icons.manage_accounts_rounded,
                    onTap: () => onRoleChanged('admin'),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _RoleButton(
                    label: 'متابع',
                    role: 'viewer',
                    selectedRole: selectedRole,
                    icon: Icons.remove_red_eye_rounded,
                    onTap: () => onRoleChanged('viewer'),
                  ),
                ),
              ],
            ),
          ],

          if (selectedUser == null && !isSearching) ...[
            SizedBox(height: 12.h),
            if (invitationCode == null)
              OutlinedButton.icon(
                onPressed: isLoadingInvitation ? null : onGenerateInvitation,
                icon: isLoadingInvitation
                    ? SizedBox(
                        width: 14.w,
                        height: 14.w,
                        child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryColor))
                    : Icon(Icons.link_rounded,
                        size: 18.sp, color: AppColors.primaryColor),
                label: Text(
                  isLoadingInvitation ? 'جاري التحميل...' : 'إنشاء رابط دعوة',
                  style: TextStyle(
                      color: AppColors.primaryColor, fontSize: 13.sp),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: AppColors.primaryColor.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              )
            else
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: AppColors.primaryColor, size: 18.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'تم إنشاء الرابط ونسخه للحافظة',
                            style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              invitationLink ?? invitationCode ?? '',
                              style: TextStyle(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                  fontSize: 11.sp),
                              overflow: TextOverflow.ellipsis,
                              textDirection: ui.TextDirection.ltr,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        IconButton(
                          onPressed: onCopyLink,
                          icon: Icon(Icons.copy_rounded,
                              color: AppColors.primaryColor, size: 20.sp),
                          padding: EdgeInsets.all(6.w),
                          constraints: const BoxConstraints(),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                AppColors.primaryColor.withValues(alpha: 0.08),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final String role;
  final String selectedRole;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.role,
    required this.selectedRole,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isSelected = selectedRole == role;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor.withValues(alpha: 0.5)
                : colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18.sp,
                color: isSelected
                    ? AppColors.primaryColor
                    : colorScheme.onSurface.withValues(alpha: 0.35)),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryColor
                    : colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            )
          ],
        ),
      ),
    );
  }
}
