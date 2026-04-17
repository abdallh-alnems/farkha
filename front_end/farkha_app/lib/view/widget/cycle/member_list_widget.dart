import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/services/initialization.dart';

class MemberListWidget extends StatelessWidget {
  const MemberListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final CycleController controller = Get.isRegistered<CycleController>()
        ? Get.find<CycleController>()
        : Get.put(CycleController());
    final MyServices myServices = Get.find<MyServices>();
    final String currentUserPhone =
        myServices.getStorage.read<String>('user_phone') ?? '';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final List<dynamic> members =
          (controller.currentCycle['members'] as List?) ?? [];
      final bool isOwner = controller.currentCycle['is_owner'] == true;

      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceColor : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    color: isDark
                        ? AppColors.darkPrimaryColor
                        : AppColors.primaryColor,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'أعضاء الدورة',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const Spacer(),
                  if (isOwner)
                    IconButton(
                      icon: const Icon(Icons.person_add_alt_1),
                      onPressed: () =>
                          _showAddMemberDialog(context, controller),
                      color: AppColors.primaryColor,
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (members.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: const Center(
                  child: Text(
                    'لا يوجد أعضاء آخرين في هذه الدورة',
                    style:
                        TextStyle(fontFamily: 'Cairo', color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: members.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, indent: 70),
                itemBuilder: (context, index) {
                  final Map<String, dynamic> member =
                      Map<String, dynamic>.from(
                          members[index] as Map);
                  final bool isPending = member['status'] == 'pending';
                  final String memberRole =
                      member['role']?.toString() ?? 'member';
                  final String memberPhone =
                      member['phone']?.toString() ?? '';
                  final bool isCurrentUser =
                      currentUserPhone.isNotEmpty &&
                          memberPhone == currentUserPhone;
                  final bool isMemberOwner = memberRole == 'owner';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isPending
                          ? Colors.orange.withValues(alpha: 0.2)
                          : (isDark
                              ? AppColors.darkSurfaceElevatedColor
                              : AppColors.secondaryColor.withValues(alpha: 0.3)),
                      child: Icon(
                        isMemberOwner ? Icons.stars : Icons.person,
                        color: isMemberOwner
                            ? Colors.amber
                            : (isDark
                                ? Colors.white70
                                : AppColors.primaryColor),
                      ),
                    ),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(
                            (member['name'] ??
                                    member['phone'] ??
                                    'عضو')
                                .toString(),
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                  color:
                                      AppColors.primaryColor.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              'أنت',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: isDark
                                    ? AppColors.darkPrimaryColor
                                    : AppColors.primaryColor,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      _getRoleLabel(memberRole),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        color: isMemberOwner
                            ? Colors.amber.shade700
                            : Colors.grey,
                      ),
                    ),
                    trailing: isPending
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              'في انتظار القبول',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.orange,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          )
                        : (isOwner && !isCurrentUser && !isMemberOwner)
                            ? _buildMemberActionMenu(
                                context, member, controller)
                            : null,
                  );
                },
              ),
            if (!isOwner)
              Padding(
                padding: EdgeInsets.all(16.w),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onPressed: () =>
                        _confirmLeaveCycle(context, controller),
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('مغادرة الدورة',
                        style: TextStyle(fontFamily: 'Cairo')),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'owner':
        return 'صاحب الدورة';
      case 'admin':
        return 'مشرف';
      case 'viewer':
        return 'مشاهد';
      default:
        return 'عضو';
    }
  }

  Widget _buildMemberActionMenu(
    BuildContext context,
    Map<String, dynamic> member,
    CycleController controller,
  ) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'remove') {
          _confirmRemoveMember(context, member, controller);
        } else if (value == 'change_role') {
          _showChangeRoleDialog(context, member, controller);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          value: 'change_role',
          child: Row(
            children: [
              const Icon(Icons.manage_accounts_outlined,
                  color: Colors.blueGrey),
              SizedBox(width: 8.w),
              const Text('تغيير الدور',
                  style: TextStyle(fontFamily: 'Cairo')),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'remove',
          child: Row(
            children: [
              const Icon(Icons.person_remove_outlined, color: Colors.red),
              SizedBox(width: 8.w),
              const Text('حذف من الدورة',
                  style:
                      TextStyle(fontFamily: 'Cairo', color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _showChangeRoleDialog(
    BuildContext context,
    Map<String, dynamic> member,
    CycleController controller,
  ) {
    final String memberName =
        (member['name'] ?? member['phone'] ?? 'العضو').toString();
    final String currentRole = member['role']?.toString() ?? 'member';
    final int? userId = member['id'] is int
        ? member['id'] as int
        : int.tryParse(member['id']?.toString() ?? '');

    if (userId == null) return;

    final roles = [
      {'value': 'admin', 'label': 'مشرف', 'icon': Icons.admin_panel_settings_outlined},
      {'value': 'viewer', 'label': 'مشاهد', 'icon': Icons.visibility_outlined},
      {'value': 'member', 'label': 'عضو عادي', 'icon': Icons.person_outline},
    ];

    Get.dialog<void>(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'تغيير دور $memberName',
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: roles
              .where((r) => r['value'] != currentRole)
              .map(
                (role) => ListTile(
                  leading:
                      Icon(role['icon'] as IconData, color: AppColors.primaryColor),
                  title: Text(
                    role['label'].toString(),
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  onTap: () async {
                    Get.back<void>();
                    final result = await controller.updateMemberRole(
                      targetUserId: userId,
                      newRole: role['value'].toString(),
                    );
                    if (result != null && result['status'] == 'success') {
                      Get.snackbar(
                        'تم',
                        'تم تغيير دور $memberName إلى ${role['label']}',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    } else {
                      Get.snackbar(
                        'خطأ',
                        result?['message']?.toString() ??
                            'فشل تغيير الدور',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(
      BuildContext context, CycleController controller) {
    final TextEditingController phoneController = TextEditingController();

    Get.dialog<void>(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text('إضافة عضو جديد',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'سيتم إرسال دعوة للمستخدم، عليه قبولها للانضمام للدورة.',
              style: TextStyle(
                  fontSize: 13, color: Colors.grey, fontFamily: 'Cairo'),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone),
                hintText: 'رقم الهاتف',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back<void>(),
              child:
                  const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor),
            onPressed: () async {
              if (phoneController.text.isNotEmpty) {
                Get.back<void>();
                await controller.addMemberByPhone(phoneController.text);
              }
            },
            child: const Text('إرسال دعوة',
                style:
                    TextStyle(color: Colors.white, fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveMember(
    BuildContext context,
    Map<String, dynamic> member,
    CycleController controller,
  ) {
    final String memberName =
        (member['name'] ?? member['phone'] ?? 'هذا العضو').toString();
    final int? userId = member['id'] is int
        ? member['id'] as int
        : int.tryParse(member['id']?.toString() ?? '');

    Get.defaultDialog<void>(
      title: 'حذف عضو',
      middleText: 'هل أنت متأكد من حذف $memberName من الدورة؟',
      textConfirm: 'حذف',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back<void>();
        if (userId != null) {
          controller.removeMember(userId);
        }
      },
    );
  }

  void _confirmLeaveCycle(
      BuildContext context, CycleController controller) {
    Get.defaultDialog<void>(
      title: 'مغادرة الدورة',
      middleText: 'هل أنت متأكد من رغبتك في مغادرة هذه الدورة؟',
      textConfirm: 'مغادرة',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back<void>();
        controller.leaveCycle();
      },
    );
  }
}
