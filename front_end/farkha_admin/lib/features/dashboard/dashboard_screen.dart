import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/kpi_card.dart';
import '../../core/api/admin_api.dart';
import '../../core/routes/app_routes.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final adminInfo = AdminApi.getAdminInfo();

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          IconButton(
            onPressed: controller.fetchOverview,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
          IconButton(
            onPressed: () async {
              await AdminApi.logout();
              Get.offAllNamed(AppRoutes.login);
            },
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      drawer: _buildDrawer(adminInfo),
      body: Obx(() {
        if (controller.isLoading.value && controller.overview.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }
        if (controller.errorMsg.isNotEmpty && controller.overview.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppTheme.accent),
                const SizedBox(height: 12),
                Text(controller.errorMsg.value,
                    style: const TextStyle(color: AppTheme.textSecondary, fontFamily: 'Cairo')),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: controller.fetchOverview,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        final data = controller.overview;
        return RefreshIndicator(
          onRefresh: controller.fetchOverview,
          color: AppTheme.primary,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Obx(() {
                if (!controller.isMaintenanceEnabled.value) return const SizedBox.shrink();
                return _buildMaintenanceBanner();
              }),
              _buildKpiGrid(data),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDrawer(Future<Map<String, dynamic>?> adminInfo) {
    return Drawer(
      child: FutureBuilder<Map<String, dynamic>?>(
        future: adminInfo,
        builder: (context, snapshot) {
          final admin = snapshot.data;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: AppTheme.primaryDark),
                accountName: Text(
                  admin?['display_name'] ?? admin?['username'] ?? 'أدمن',
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                accountEmail: Text(
                  admin?['role'] ?? '',
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.white),
                ),
              ),
              _drawerItem(Icons.dashboard, 'لوحة التحكم', AppRoutes.dashboard),
              _drawerItem(Icons.tune, 'إعدادات التطبيق', AppRoutes.remoteConfig),
              _drawerItem(Icons.article, 'المقالات', AppRoutes.articles),
              _drawerItem(Icons.people, 'المستخدمون', AppRoutes.users),
              _drawerItem(Icons.devices, 'الأجهزة', AppRoutes.devices),
              _drawerItem(Icons.agriculture, 'الدورات', AppRoutes.cycles),
              _drawerItem(Icons.category, 'الفئات والأنواع', AppRoutes.categories),
              _drawerItem(Icons.notifications, 'الإشعارات', AppRoutes.notifications),
              _drawerItem(Icons.star, 'التقييمات', AppRoutes.reviews),
              _drawerItem(Icons.settings, 'النظام', AppRoutes.system),
              _drawerItem(Icons.checklist_rounded, 'قائمة المهام', AppRoutes.todo),
              _drawerItem(Icons.admin_panel_settings, 'إدارة الحسابات', AppRoutes.admins),
              const Divider(color: AppTheme.border),
              ListTile(
                leading: const Icon(Icons.logout, color: AppTheme.accent),
                title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', color: AppTheme.accent)),
                onTap: () async {
                  await AdminApi.logout();
                  Get.offAllNamed(AppRoutes.login);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontFamily: 'Cairo')),
      onTap: () {
        Get.back();
        if (Get.currentRoute != route) {
          Get.toNamed(route);
        }
      },
    );
  }

  Widget _buildMaintenanceBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.5), width: 1.5),
      ),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.remoteConfig),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.power_settings_new, color: AppTheme.accent, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'التطبيق متوقف حالياً',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Cairo',
                      color: AppTheme.accent,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'اضغط للانتقال إلى إعدادات التطبيق',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppTheme.accent, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiGrid(Map<String, dynamic> data) {
    final users = data['users'] as Map<String, dynamic>? ?? {};
    final cycles = data['cycles'] as Map<String, dynamic>? ?? {};
    final devices = data['devices'] as Map<String, dynamic>? ?? {};
    final reviews = data['reviews'] as Map<String, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الملخص',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            KpiCard(
              title: 'إجمالي المستخدمين',
              value: _fmt(users['total']),
              icon: Icons.people,
              subtitle: '+${_fmt(users['new_7d'])} هذا الأسبوع',
              onTap: () => Get.toNamed(AppRoutes.users),
            ),
            KpiCard(
              title: 'الدورات النشطة',
              value: _fmt(cycles['total_active']),
              icon: Icons.agriculture,
              color: AppTheme.success,
              subtitle: '${_fmt(cycles['created_7d'])} جديدة',
              onTap: () => Get.toNamed(AppRoutes.cycles),
            ),
            KpiCard(
              title: 'الأجهزة النشطة',
              value: _fmt(devices['active_7d']),
              icon: Icons.devices,
              color: Colors.teal,
              subtitle: '${_fmt(devices['total'])} إجمالي',
              onTap: () => Get.toNamed(AppRoutes.devices),
            ),
            KpiCard(
              title: 'تقييم التطبيق',
              value: _fmtDouble(reviews['app_avg']),
              icon: Icons.star,
              color: Colors.amber,
              subtitle: '${_fmt(reviews['app_total'])} تقييم',
              onTap: () => Get.toNamed(AppRoutes.reviews),
            ),
          ],
        ),
      ],
    );
  }

  String _fmt(dynamic v) {
    if (v == null) return '0';
    final n = (v as num).toInt();
    return n.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  String _fmtDouble(dynamic v) {
    if (v == null) return '0.0';
    return (v as num).toStringAsFixed(1);
  }
}
