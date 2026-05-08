import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/theme.dart';
import '../../../logic/controller/cycle_controller.dart';

class InvitationCard extends StatelessWidget {
  const InvitationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final CycleController controller = Get.isRegistered<CycleController>()
        ? Get.find<CycleController>()
        : Get.put(CycleController());

    return Obx(() {
      if (controller.invitations.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 4.h),
        child: Column(
          children: controller.invitations.map((invitation) {
            final String cycleName =
                (invitation['cycle_name'] ?? 'دورة غير معروفة').toString();
            final String ownerName =
                (invitation['inviter_name'] ?? 'مستخدم').toString();
            final int cycleId =
                int.tryParse(invitation['cycle_id'].toString()) ?? 0;
            final String role = (invitation['role'] ?? 'member').toString();

            return _InviteSingleCard(
              key: ValueKey(cycleId),
              cycleName: cycleName,
              ownerName: ownerName,
              cycleId: cycleId,
              role: role,
              controller: controller,
            );
          }).toList(),
        ),
      );
    });
  }
}

class _InviteSingleCard extends StatefulWidget {
  final String cycleName;
  final String ownerName;
  final int cycleId;
  final String role;
  final CycleController controller;

  const _InviteSingleCard({
    super.key,
    required this.cycleName,
    required this.ownerName,
    required this.cycleId,
    required this.role,
    required this.controller,
  });

  @override
  State<_InviteSingleCard> createState() => _InviteSingleCardState();
}

class _InviteSingleCardState extends State<_InviteSingleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  _RoleMeta _roleMeta(String role, bool isDark) {
    switch (role) {
      case 'admin':
        return _RoleMeta(
          label: 'مشرف',
          icon: Icons.admin_panel_settings_rounded,
          color: const Color(0xFFE67E22),
          bg: isDark ? const Color(0xFF3D2000) : const Color(0xFFFFF3E0),
        );
      case 'viewer':
        return _RoleMeta(
          label: 'متابع',
          icon: Icons.visibility_rounded,
          color: isDark ? const Color(0xFF4DD0E1) : const Color(0xFF0097A7),
          bg: isDark ? const Color(0xFF002B30) : const Color(0xFFE0F7FA),
        );
      case 'owner':
        return _RoleMeta(
          label: 'مالك',
          icon: Icons.star_rounded,
          color: isDark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2),
          bg: isDark ? const Color(0xFF2A0040) : const Color(0xFFF3E5F5),
        );
      default:
        return _RoleMeta(
          label: 'عضو',
          icon: Icons.person_rounded,
          color: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
          bg: isDark ? const Color(0xFF002810) : const Color(0xFFE8F5E9),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final meta = _roleMeta(widget.role, isDark);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _animController,
        child: Container(
          margin: EdgeInsets.only(bottom: 8.h),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 8.h),
                child: Row(
                  children: [
                    Container(
                      width: 38.w,
                      height: 38.h,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.egg_alt_rounded,
                        color: colorScheme.primary,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.cycleName,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'دعوة من: ${widget.ownerName}',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: meta.bg,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(meta.icon, size: 13.sp, color: meta.color),
                          SizedBox(width: 4.w),
                          Text(
                            meta.label,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: meta.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: colorScheme.outline.withValues(alpha: 0.15)),
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 7.h, 12.w, 7.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _ActionButton(
                      label: 'رفض',
                      icon: Icons.close_rounded,
                      fgColor: colorScheme.onSurface.withValues(alpha: 0.6),
                      bgColor: colorScheme.surfaceContainerHighest,
                      onTap: () async {
                        final result = await widget.controller
                            .respondToInvitation(widget.cycleId, 'reject');
                        if (result != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result['message'].toString())),
                          );
                        }
                      },
                    ),
                    SizedBox(width: 8.w),
                    _ActionButton(
                      label: 'قبول',
                      icon: Icons.check_rounded,
                      fgColor: colorScheme.onPrimary,
                      bgColor: colorScheme.primary,
                      onTap: () async {
                        final result = await widget.controller
                            .respondToInvitation(widget.cycleId, 'accept');
                        if (result != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result['message'].toString())),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color fgColor;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.fgColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15.sp, color: fgColor),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: fgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleMeta {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;

  const _RoleMeta({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
  });
}
