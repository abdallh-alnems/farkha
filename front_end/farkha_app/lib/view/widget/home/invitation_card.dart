import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../core/constant/theme/colors.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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

// ─────────────────────────────────────────────────────────────
// Single invite card
// ─────────────────────────────────────────────────────────────

class _InviteSingleCard extends StatelessWidget {
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
      default: // member
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
    final meta = _roleMeta(role, isDark);

    final cardBg =
        isDark ? AppColors.darkSurfaceColor : Colors.white;
    final borderColor =
        isDark ? AppColors.darkOutlineColor : AppColors.lightOutlineColor;
    final titleColor =
        isDark ? Colors.white : const Color(0xFF1A2D42);
    final subtitleColor =
        isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    final dividerColor =
        isDark ? AppColors.darkOutlineColor : Colors.grey.shade100;
    final iconBg = isDark
        ? AppColors.darkPrimaryColor.withValues(alpha: 0.12)
        : AppColors.primaryColor.withValues(alpha: 0.08);
    final iconColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;
    final rejectBg =
        isDark ? AppColors.darkSurfaceElevatedColor : Colors.grey.shade100;
    final rejectColor =
        isDark ? Colors.grey.shade300 : Colors.grey.shade600;
    final acceptBg =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;
    final acceptFg = isDark ? AppColors.darkBackGroundColor : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : AppColors.primaryColor.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                // أيقونة الدورة
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.egg_alt_rounded,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                // اسم الدورة + المدعو
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cycleName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                          fontFamily: 'Cairo',
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'دعوة من: $ownerName',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: subtitleColor,
                          fontFamily: 'Cairo',
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // شارة الصلاحية
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: meta.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(meta.icon, size: 13, color: meta.color),
                      const SizedBox(width: 4),
                      Text(
                        meta.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: meta.color,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ────────────────────────────────────────
          Divider(height: 1, thickness: 1, color: dividerColor),

          // ── Actions ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // رفض
                _ActionButton(
                  label: 'رفض',
                  icon: Icons.close_rounded,
                  fgColor: rejectColor,
                  bgColor: rejectBg,
                  onTap: () async {
                    final result = await controller.respondToInvitation(
                        cycleId, 'reject');
                    if (result != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(result['message'].toString())),
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
                // قبول
                _ActionButton(
                  label: 'قبول',
                  icon: Icons.check_rounded,
                  fgColor: acceptFg,
                  bgColor: acceptBg,
                  onTap: () async {
                    final result = await controller.respondToInvitation(
                        cycleId, 'accept');
                    if (result != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(result['message'].toString())),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Action button
// ─────────────────────────────────────────────────────────────

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
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: fgColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: fgColor,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Role metadata
// ─────────────────────────────────────────────────────────────

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
