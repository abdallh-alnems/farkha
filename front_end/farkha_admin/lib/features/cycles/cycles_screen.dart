import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'cycles_controller.dart';

class CyclesScreen extends StatelessWidget {
  const CyclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CyclesController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              'الدورات (${controller.totalCount.value})',
              style: const TextStyle(fontFamily: 'Cairo'),
            )),
        actions: [
          IconButton(
            onPressed: () => controller.fetchCycles(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Obx(() => Row(
                  children: ['all', 'active', 'closed', 'deleted'].map((s) {
                    final labels = {'all': 'الكل', 'active': 'نشطة', 'closed': 'مغلقة', 'deleted': 'محذوفة'};
                    final isActive = controller.statusFilter.value == s;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ChoiceChip(
                        label: Text(labels[s]!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                        selected: isActive,
                        onSelected: (_) => controller.setFilter(s),
                        selectedColor: AppTheme.primary.withValues(alpha: 0.3),
                      ),
                    );
                  }).toList(),
                )),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.cycles.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
              }
              return ListView.builder(
                itemCount: controller.cycles.length,
                itemBuilder: (context, index) {
                  final c = controller.cycles[index];
                  final isDeleted = c['deleted_at'] != null;
                  final isClosed = c['end_date_raw'] != null;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isDeleted
                            ? AppTheme.accent.withValues(alpha: 0.15)
                            : isClosed
                                ? AppTheme.warning.withValues(alpha: 0.15)
                                : AppTheme.success.withValues(alpha: 0.15),
                        child: Icon(
                          isDeleted ? Icons.delete : isClosed ? Icons.lock : Icons.agriculture,
                          color: isDeleted ? AppTheme.accent : isClosed ? AppTheme.warning : AppTheme.success,
                          size: 20,
                        ),
                      ),
                      title: Text(c['name'] ?? '-', style: const TextStyle(fontFamily: 'Cairo')),
                      subtitle: Text(
                        '${c['owner_name'] ?? '-'} • ${c['start_date_raw'] ?? '-'}',
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (_) => [
                          if (!isClosed && !isDeleted) const PopupMenuItem(value: 'close', child: Text('إغلاق إجباري')),
                          if (!isDeleted) const PopupMenuItem(value: 'soft_delete', child: Text('حذف ناعم')),
                          if (isDeleted) const PopupMenuItem(value: 'hard_delete', child: Text('حذف نهائي', style: TextStyle(color: AppTheme.accent))),
                        ],
                        onSelected: (v) async {
                          if (v == 'close') {
                            final ok = await controller.forceClose(c['id'] as int, DateTime.now().toIso8601String().split('T').first);
                            if (ok) Get.snackbar('تم', 'تم إغلاق الدورة', snackPosition: SnackPosition.BOTTOM);
                          }
                          if (v == 'soft_delete') {
                            final ok = await controller.softDelete(c['id'] as int);
                            if (ok) Get.snackbar('تم', 'تم حذف الدورة', snackPosition: SnackPosition.BOTTOM);
                          }
                          if (v == 'hard_delete') {
                            final ok = await controller.hardDelete(c['id'] as int);
                            if (ok) Get.snackbar('تم', 'تم الحذف نهائياً', snackPosition: SnackPosition.BOTTOM);
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
