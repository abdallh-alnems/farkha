import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'admins_controller.dart';

class AdminsScreen extends StatelessWidget {
  const AdminsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الحسابات'),
        actions: [
          IconButton(
            onPressed: controller.fetchAdmins,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.admins.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        }
        if (controller.errorMsg.isNotEmpty && controller.admins.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppTheme.accent),
                const SizedBox(height: 12),
                Text(controller.errorMsg.value,
                    style: const TextStyle(color: AppTheme.textSecondary, fontFamily: 'Cairo')),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: controller.fetchAdmins, child: const Text('إعادة المحاولة')),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAdmins,
          color: AppTheme.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.admins.length,
            itemBuilder: (context, index) {
              final admin = controller.admins[index];
              return _AdminCard(admin: admin, controller: controller);
            },
          ),
        );
      }),
      floatingActionButton: Obx(() {
        if (!controller.isSuperAdmin.value) return const SizedBox.shrink();
        return FloatingActionButton(
          onPressed: () => _showCreateDialog(context, controller),
          backgroundColor: AppTheme.primary,
          child: const Icon(Icons.person_add, color: Colors.white),
        );
      }),
    );
  }

  void _showCreateDialog(BuildContext context, AdminsController controller) {
    final formKey = GlobalKey<FormState>();
    Get.dialog(
      Dialog(
        backgroundColor: AppTheme.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'إنشاء حساب جديد',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: controller.usernameCtrl,
                  style: const TextStyle(fontFamily: 'Cairo'),
                  decoration: const InputDecoration(
                    labelText: 'اسم المستخدم',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controller.displayNameCtrl,
                  style: const TextStyle(fontFamily: 'Cairo'),
                  decoration: const InputDecoration(
                    labelText: 'الاسم المعروض (اختياري)',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controller.passwordCtrl,
                  obscureText: true,
                  style: const TextStyle(fontFamily: 'Cairo'),
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) => v == null || v.length < 6 ? '6 أحرف على الأقل' : null,
                ),
                const SizedBox(height: 16),
                Obx(() => _RoleSelector(
                      selectedRole: controller.selectedRole.value,
                      onChanged: controller.selectedRole.call,
                    )),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                          side: const BorderSide(color: AppTheme.border),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            controller.createAdmin();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('إنشاء'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final Map<String, dynamic> admin;
  final AdminsController controller;

  const _AdminCard({required this.admin, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isActive = admin['is_active'] == true || admin['is_active'] == 1;
    final role = admin['role'] as String? ?? 'readonly';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _roleColor(role).withValues(alpha: 0.15),
                  child: Icon(Icons.admin_panel_settings, color: _roleColor(role)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        admin['display_name'] ?? admin['username'] ?? '',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${admin['username'] ?? ''}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _RoleChip(role: role),
                    const SizedBox(height: 4),
                    if (admin['last_login_at'] != null)
                      Text(
                        _formatDate(admin['last_login_at']),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                  ],
                ),
              ],
            ),
            Obx(() {
              if (!controller.isSuperAdmin.value) return const SizedBox.shrink();
              return Column(
                children: [
                  const SizedBox(height: 12),
                  const Divider(color: AppTheme.border, height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              'نشط',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: isActive ? AppTheme.success : AppTheme.accent,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch.adaptive(
                              value: isActive,
                              activeThumbColor: AppTheme.success,
                              onChanged: (v) => controller.toggleActive(admin, v),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showRoleDialog(context, admin),
                        icon: const Icon(Icons.shield_outlined, size: 20),
                        tooltip: 'تغيير الصلاحية',
                        color: AppTheme.primary,
                      ),
                      IconButton(
                        onPressed: () => _showResetPasswordDialog(context, admin),
                        icon: const Icon(Icons.key, size: 20),
                        tooltip: 'إعادة تعيين كلمة المرور',
                        color: AppTheme.warning,
                      ),
                    ],
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showRoleDialog(BuildContext context, Map<String, dynamic> admin) {
    final roles = ['readonly', 'admin', 'superadmin'];
    final labels = {
      'readonly': 'قراءة فقط',
      'admin': 'أدمن',
      'superadmin': 'سوبر أدمن',
    };

    Get.dialog(
      Dialog(
        backgroundColor: AppTheme.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تغيير صلاحية ${admin['display_name']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 16),
              ...roles.map((r) => ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    leading: Radio<String>(
                      value: r,
                      // ignore: deprecated_member_use
                      groupValue: admin['role'],
                      activeColor: AppTheme.primary,
                      // ignore: deprecated_member_use
                      onChanged: (v) {
                        Get.back();
                        if (v != null && v != admin['role']) {
                          controller.changeRole(admin, v);
                        }
                      },
                    ),
                    title: Text(
                      labels[r] ?? r,
                      style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.textPrimary),
                    ),
                    trailing: _RoleChip(role: r, small: true),
                    onTap: () {
                      Get.back();
                      if (r != admin['role']) {
                        controller.changeRole(admin, r);
                      }
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, Map<String, dynamic> admin) {
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      Dialog(
        backgroundColor: AppTheme.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إعادة تعيين كلمة مرور ${admin['display_name']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passCtrl,
                  obscureText: true,
                  style: const TextStyle(fontFamily: 'Cairo'),
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور الجديدة',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) => v == null || v.length < 6 ? '6 أحرف على الأقل' : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                          side: const BorderSide(color: AppTheme.border),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            controller.resetPassword(admin, passCtrl.text);
                          }
                        },
                        child: const Text('حفظ'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr.toString());
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'superadmin':
        return AppTheme.accent;
      case 'admin':
        return AppTheme.primary;
      default:
        return AppTheme.success;
    }
  }
}

class _RoleChip extends StatelessWidget {
  final String role;
  final bool small;

  const _RoleChip({required this.role, this.small = false});

  @override
  Widget build(BuildContext context) {
    final labels = {
      'readonly': 'قراءة فقط',
      'admin': 'أدمن',
      'superadmin': 'سوبر أدمن',
    };
    final colors = {
      'readonly': AppTheme.success,
      'admin': AppTheme.primary,
      'superadmin': AppTheme.accent,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 6 : 10, vertical: small ? 2 : 4),
      decoration: BoxDecoration(
        color: (colors[role] ?? AppTheme.primary).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(small ? 6 : 8),
        border: Border.all(color: (colors[role] ?? AppTheme.primary).withValues(alpha: 0.3)),
      ),
      child: Text(
        labels[role] ?? role,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: small ? 10 : 11,
          fontWeight: FontWeight.bold,
          color: colors[role] ?? AppTheme.primary,
        ),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onChanged;

  const _RoleSelector({required this.selectedRole, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = [
      ('readonly', 'قراءة فقط', 'عرض البيانات فقط', AppTheme.success),
      ('admin', 'أدمن', 'إدارة المحتوى والأسعار', AppTheme.primary),
      ('superadmin', 'سوبر أدمن', 'صلاحيات كاملة + إنشاء حسابات', AppTheme.accent),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الصلاحية',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...options.map((opt) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: selectedRole == opt.$1 ? opt.$4.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selectedRole == opt.$1 ? opt.$4 : AppTheme.border,
                ),
              ),
              child: RadioListTile<String>(
                value: opt.$1,
                // ignore: deprecated_member_use
                groupValue: selectedRole,
                // ignore: deprecated_member_use
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
                activeColor: opt.$4,
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: Text(
                  opt.$2,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: selectedRole == opt.$1 ? opt.$4 : AppTheme.textPrimary,
                  ),
                ),
                subtitle: Text(
                  opt.$3,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            )),
      ],
    );
  }
}
