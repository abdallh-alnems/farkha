import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import 'devices_controller.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DevicesController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('الأجهزة (${controller.total})')),
        actions: [
          IconButton(
            onPressed: controller.fetchDevices,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.devices.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        }
        if (controller.errorMsg.isNotEmpty && controller.devices.isEmpty) {
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
                  onPressed: controller.fetchDevices,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchDevices,
          color: AppTheme.primary,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatsCards(controller),
              const SizedBox(height: 16),
              _buildSearchField(controller),
              const SizedBox(height: 12),
              _buildPeriodFilter(controller),
              const SizedBox(height: 12),
              _buildPlatformFilter(controller),
              const SizedBox(height: 16),
              _buildDeviceList(controller),
              _buildPagination(controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatsCards(DevicesController controller) {
    return Obx(() {
      final s = controller.stats;
      if (s.isEmpty) return const SizedBox.shrink();
      return Row(
        children: [
          _statChip('الكل', _fmt(s['total']), Icons.devices, AppTheme.primary),
          const SizedBox(width: 8),
          _statChip('نشطة 7 أيام', _fmt(s['active_7d']), Icons.check_circle, AppTheme.success),
          const SizedBox(width: 8),
          _statChip('Android', _fmt(s['android']), Icons.phone_android, Colors.green),
          const SizedBox(width: 8),
          _statChip('iOS', _fmt(s['ios']), Icons.phone_iphone, Colors.blue),
        ],
      );
    });
  }

  Widget _statChip(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'Cairo',
                  )),
              Text(label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppTheme.textSecondary,
                    fontFamily: 'Cairo',
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(DevicesController controller) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'بحث بالاسم أو رقم الهاتف...',
        prefixIcon: Icon(Icons.search),
      ),
      onSubmitted: controller.search,
    );
  }

  Widget _buildPeriodFilter(DevicesController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'فترة النشاط',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.periods.map((p) {
                final selected = controller.selectedPeriod.value == p.$1;
                return ChoiceChip(
                  label: Text(p.$2),
                  selected: selected,
                  onSelected: (_) => controller.setPeriod(p.$1),
                  selectedColor: AppTheme.primary.withValues(alpha: 0.3),
                  backgroundColor: AppTheme.surfaceLight,
                  labelStyle: TextStyle(
                    fontFamily: 'Cairo',
                    color: selected ? AppTheme.primary : AppTheme.textSecondary,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: selected ? AppTheme.primary : AppTheme.border,
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  Widget _buildPlatformFilter(DevicesController controller) {
    return Obx(() {
      final current = controller.selectedPlatform.value;
      return Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: const Text('الكل'),
            selected: current.isEmpty,
            onSelected: (_) => controller.setPlatform(''),
            selectedColor: AppTheme.primary.withValues(alpha: 0.3),
            backgroundColor: AppTheme.surfaceLight,
            labelStyle: TextStyle(
              fontFamily: 'Cairo',
              color: current.isEmpty ? AppTheme.primary : AppTheme.textSecondary,
              fontWeight: current.isEmpty ? FontWeight.bold : FontWeight.normal,
            ),
            side: BorderSide(color: current.isEmpty ? AppTheme.primary : AppTheme.border),
          ),
          ChoiceChip(
            avatar: const Icon(Icons.phone_android, size: 16, color: Colors.green),
            label: const Text('Android'),
            selected: current == 'android',
            onSelected: (_) => controller.setPlatform('android'),
            selectedColor: AppTheme.primary.withValues(alpha: 0.3),
            backgroundColor: AppTheme.surfaceLight,
            labelStyle: TextStyle(
              fontFamily: 'Cairo',
              color: current == 'android' ? AppTheme.primary : AppTheme.textSecondary,
              fontWeight: current == 'android' ? FontWeight.bold : FontWeight.normal,
            ),
            side: BorderSide(color: current == 'android' ? AppTheme.primary : AppTheme.border),
          ),
          ChoiceChip(
            avatar: const Icon(Icons.phone_iphone, size: 16, color: Colors.blue),
            label: const Text('iOS'),
            selected: current == 'ios',
            onSelected: (_) => controller.setPlatform('ios'),
            selectedColor: AppTheme.primary.withValues(alpha: 0.3),
            backgroundColor: AppTheme.surfaceLight,
            labelStyle: TextStyle(
              fontFamily: 'Cairo',
              color: current == 'ios' ? AppTheme.primary : AppTheme.textSecondary,
              fontWeight: current == 'ios' ? FontWeight.bold : FontWeight.normal,
            ),
            side: BorderSide(color: current == 'ios' ? AppTheme.primary : AppTheme.border),
          ),
        ],
      );
    });
  }

  Widget _buildDeviceList(DevicesController controller) {
    return Obx(() {
      if (controller.devices.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('لا توجد أجهزة',
                style: TextStyle(color: AppTheme.textSecondary, fontFamily: 'Cairo')),
          ),
        );
      }

      return Column(
        children: controller.devices.map((d) {
          final isIos = d['platform'] == 'ios';
          final lastActive = d['last_active'] ?? '-';
          final userName = d['user_name'] ?? 'محذوف';
          final userPhone = d['user_phone'];
          final isActive7d = _isWithinDays(d['last_active'], 7);

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: (isIos ? Colors.blue : Colors.green).withValues(alpha: 0.15),
                child: Icon(
                  isIos ? Icons.phone_iphone : Icons.phone_android,
                  color: isIos ? Colors.blue : Colors.green,
                  size: 22,
                ),
              ),
              title: Row(
                children: [
                  Flexible(
                    child: Text(
                      userName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                  if (userPhone != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      userPhone,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Text(
                'آخر نشاط: $lastActive',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isActive7d ? AppTheme.success : AppTheme.warning).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isActive7d ? 'نشط' : 'خامل',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isActive7d ? AppTheme.success : AppTheme.warning,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: d['user_id'] != null
                  ? () => Get.toNamed(
                        AppRoutes.userDetail.replaceAll(':id', '${d['user_id']}'),
                      )
                  : null,
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildPagination(DevicesController controller) {
    return Obx(() {
      if (controller.totalPages.value <= 1) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: controller.currentPage.value > 1
                  ? () => controller.fetchDevices(page: controller.currentPage.value - 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
            Text(
              '${controller.currentPage} / ${controller.totalPages}',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            IconButton(
              onPressed: controller.currentPage.value < controller.totalPages.value
                  ? () => controller.fetchDevices(page: controller.currentPage.value + 1)
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
          ],
        ),
      );
    });
  }

  bool _isWithinDays(dynamic dateStr, int days) {
    if (dateStr == null) return false;
    try {
      final d = DateTime.parse(dateStr.toString());
      return d.isAfter(DateTime.now().subtract(Duration(days: days)));
    } catch (_) {
      return false;
    }
  }

  String _fmt(dynamic v) {
    if (v == null) return '0';
    final n = (v as num).toInt();
    return n.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}
