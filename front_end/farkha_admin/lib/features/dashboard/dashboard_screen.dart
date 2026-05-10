import 'package:fl_chart/fl_chart.dart';
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
              _buildKpiGrid(data),
              const SizedBox(height: 24),
              _buildTimelineCharts(data),
              const SizedBox(height: 24),
              _buildTopTools(data),
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
              _drawerItem(Icons.attach_money, 'الأسعار', AppRoutes.prices),
              _drawerItem(Icons.article, 'المقالات', AppRoutes.articles),
              _drawerItem(Icons.people, 'المستخدمون', AppRoutes.users),
              _drawerItem(Icons.agriculture, 'الدورات', AppRoutes.cycles),
              _drawerItem(Icons.category, 'الفئات والأنواع', AppRoutes.categories),
              _drawerItem(Icons.notifications, 'الإشعارات', AppRoutes.notifications),
              _drawerItem(Icons.star, 'التقييمات', AppRoutes.reviews),
              _drawerItem(Icons.analytics, 'الإحصائيات', AppRoutes.analytics),
              _drawerItem(Icons.settings, 'النظام', AppRoutes.system),
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

  Widget _buildKpiGrid(Map<String, dynamic> data) {
    final users = data['users'] as Map<String, dynamic>? ?? {};
    final cycles = data['cycles'] as Map<String, dynamic>? ?? {};
    final devices = data['devices'] as Map<String, dynamic>? ?? {};
    final tools = data['tools'] as Map<String, dynamic>? ?? {};
    final reviews = data['reviews'] as Map<String, dynamic>? ?? {};
    final prices = data['prices'] as Map<String, dynamic>? ?? {};

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
            ),
            KpiCard(
              title: 'الدورات النشطة',
              value: _fmt(cycles['total_active']),
              icon: Icons.agriculture,
              color: AppTheme.success,
              subtitle: '${_fmt(cycles['created_7d'])} جديدة',
            ),
            KpiCard(
              title: 'الأجهزة النشطة',
              value: _fmt(devices['active_7d']),
              icon: Icons.devices,
              color: Colors.teal,
              subtitle: '${_fmt(devices['total'])} إجمالي',
            ),
            KpiCard(
              title: 'استخدام الأدوات (اليوم)',
              value: _fmt(tools['usage_today']),
              icon: Icons.build,
              color: Colors.orange,
              subtitle: '${_fmt(tools['usage_7d'])} الأسبوع',
            ),
            KpiCard(
              title: 'تقييم التطبيق',
              value: _fmtDouble(reviews['app_avg']),
              icon: Icons.star,
              color: Colors.amber,
              subtitle: '${_fmt(reviews['app_total'])} تقييم',
            ),
            KpiCard(
              title: 'سجلات الأسعار',
              value: _fmt(prices['total_records']),
              icon: Icons.attach_money,
              subtitle: '${_fmt(prices['updated_today'])} اليوم',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineCharts(Map<String, dynamic> data) {
    final timeline = data['timeline_30d'] as Map<String, dynamic>? ?? {};
    final usersTimeline = (timeline['users'] as List<dynamic>? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .toList();
    final cyclesTimeline = (timeline['cycles'] as List<dynamic>? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'آخر 30 يوم',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('مستخدمون جدد', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppTheme.textSecondary)),
                    const SizedBox(width: 16),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('دورات جديدة', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (v) => FlLine(color: AppTheme.border.withValues(alpha: 0.3), strokeWidth: 1),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (v, _) => Text(
                              v.toInt().toString(),
                              style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontFamily: 'Cairo'),
                            ),
                          ),
                        ),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _toSpots(usersTimeline),
                          isCurved: true,
                          color: AppTheme.primary,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.primary.withValues(alpha: 0.1),
                          ),
                        ),
                        LineChartBarData(
                          spots: _toSpots(cyclesTimeline),
                          isCurved: true,
                          color: AppTheme.success,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.success.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopTools(Map<String, dynamic> data) {
    final tools = data['tools'] as Map<String, dynamic>? ?? {};
    final topToday = tools['top_today'] as List<dynamic>? ?? [];

    if (topToday.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'أكثر الأدوات استخداماً اليوم',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 12),
        ...topToday.map<Widget>((item) {
          final tool = item as Map<String, dynamic>;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                child: Text(
                  '${tool['tool_id']}',
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              title: Text(
                _toolName(tool['tool_id'] as int),
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              trailing: Text(
                _fmt(tool['usage_count']),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  List<FlSpot> _toSpots(List<Map<String, dynamic>> data) {
    return data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value['c'] as num?)?.toDouble() ?? 0);
    }).toList();
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

  String _toolName(int id) {
    const names = {
      1: 'FCR', 2: 'ADG', 3: 'كثافة الفراخ', 4: 'استهلاك العلف اليومي',
      5: 'استهلاك العلف الكلي', 6: 'الوزن حسب العمر', 7: 'الحرارة حسب العمر',
      8: 'ساعات الإضاءة', 9: 'الشفاطات', 10: 'التحصينات', 11: 'المقالات',
      12: 'الأمراض', 13: 'متطلبات التسمين', 14: 'دراسة جدوى', 15: 'تكلفة الإنتاج',
      16: 'تكلفة العلف/طائر', 17: 'تكلفة العلف/كيلو', 18: 'ربح/طائر',
      19: 'ROI', 20: 'النفوق', 21: 'الوزن الإجمالي', 22: 'الإيرادات',
      23: 'استهلاك الماء', 24: 'الطقس',
    };
    return names[id] ?? 'أداة $id';
  }
}
