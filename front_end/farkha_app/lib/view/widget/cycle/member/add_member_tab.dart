import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/theme/colors.dart';

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
    if (!isOwner) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'أدخل رقم هاتف المستخدم المسجل في التطبيق',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
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
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15.sp,
                    letterSpacing: 2,
                  ),
                  decoration: InputDecoration(
                    hintText: '01xxxxxxxxx',
                    counterText: '',
                    prefixIcon: Icon(Icons.phone_android_rounded,
                        color: AppColors.primaryColor, size: 20.sp),
                    filled: true,
                    fillColor: isDark ? Colors.black12 : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                          color: AppColors.primaryColor.withValues(alpha: 0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                          color: AppColors.primaryColor.withValues(alpha: 0.1)),
                    ),
                  ),
                  onChanged: (val) {
                    if (val.length == 11) onSearch();
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: IconButton(
                  icon: Icon(Icons.contacts_rounded,
                      color: AppColors.primaryColor, size: 22.sp),
                  onPressed: onPickContact,
                ),
              ),
            ],
          ),

          if (isSearching)
            Padding(
              padding: EdgeInsets.all(20.h),
              child: const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryColor)),
            ),

          if (resultMessage != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isResultError
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    isResultError
                        ? Icons.error_outline
                        : Icons.check_circle_outline,
                    color: isResultError ? Colors.red : Colors.green,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      resultMessage!,
                      style: TextStyle(
                        color: isResultError ? Colors.red : Colors.green,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (selectedUser != null && !isSearching) ...[
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22.r,
                    backgroundColor: AppColors.primaryColor,
                    child: Icon(Icons.person,
                        color: Colors.white, size: 24.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedUser!['name']?.toString() ?? 'بدون اسم',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          selectedUser!['phone']?.toString() ?? '',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 12.sp,
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
              'اختر الصلاحية للمستخدم',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
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
                    isDark: isDark,
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
                    isDark: isDark,
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
                        child: CircularProgressIndicator(
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
                      color: AppColors.primaryColor.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              )
            else
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: Colors.green, size: 18.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'تم إنشاء رابط الدعوة',
                        style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onCopyLink,
                      icon: Icon(Icons.copy_rounded,
                          size: 15.sp, color: Colors.green.shade600),
                      label: Text(
                        'نسخ',
                        style: TextStyle(
                            color: Colors.green.shade600, fontSize: 11.sp),
                      ),
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 6.w)),
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
  final bool isDark;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.role,
    required this.selectedRole,
    required this.isDark,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedRole == role;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : (isDark ? Colors.white24 : Colors.grey[300]!),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18.sp,
                color: isSelected
                    ? AppColors.primaryColor
                    : (isDark ? Colors.white54 : Colors.grey[500])),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryColor
                    : (isDark ? Colors.white70 : Colors.grey[600]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
