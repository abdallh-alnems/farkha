import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'remote_config_controller.dart';

class RemoteConfigScreen extends StatelessWidget {
  const RemoteConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RemoteConfigController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات التطبيق'),
        actions: [
          IconButton(
            onPressed: controller.fetchConfig,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.parameters.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }
        if (controller.errorMsg.isNotEmpty && controller.parameters.isEmpty) {
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
                  onPressed: controller.fetchConfig,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchConfig,
          color: AppTheme.primary,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (controller.version.isNotEmpty) ...[
                Card(
                  color: AppTheme.surfaceLight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppTheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'آخر تحديث: ${controller.version['updated_at'] ?? '-'}\n'
                            'بواسطة: ${controller.version['updated_by'] ?? '-'}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontFamily: 'Cairo'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ...controller.parameters.map((param) => _buildParamCard(context, controller, param)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildParamCard(BuildContext context, RemoteConfigController controller, Map<String, dynamic> param) {
    final name = param['name'] as String? ?? '';
    final value = param['default_value']?.toString() ?? '';
    final description = param['description']?.toString() ?? '';
    final isVersionKey = name == 'min_required_version';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isVersionKey ? AppTheme.warning.withValues(alpha: 0.5) : AppTheme.border,
          width: isVersionKey ? 1.5 : 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'Cairo',
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _showEditDialog(context, controller, name, value, description),
                  icon: const Icon(Icons.edit, color: AppTheme.primary, size: 20),
                  tooltip: 'تعديل',
                ),
              ],
            ),
            if (isVersionKey) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, color: AppTheme.warning, size: 18),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'تغيير هذا المفتاح يجبر كل المستخدمين على التحديث',
                        style: TextStyle(
                          color: AppTheme.warning,
                          fontSize: 12,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: isVersionKey ? AppTheme.warning : AppTheme.primary,
                ),
              ),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontFamily: 'Cairo'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    RemoteConfigController controller,
    String name,
    String currentValue,
    String description,
  ) {
    final valueCtrl = TextEditingController(text: currentValue);

    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        title: Text('تعديل: $name', style: const TextStyle(fontFamily: 'Cairo', fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: valueCtrl,
              style: const TextStyle(fontFamily: 'Cairo'),
              decoration: const InputDecoration(
                labelText: 'القيمة الجديدة',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () async {
              final newValue = valueCtrl.text.trim();
              if (newValue.isEmpty) return;
              Get.back();
              final ok = await controller.updateParameter(name, newValue);
              if (ok) {
                Get.snackbar(
                  'تم',
                  'تم تحديث $name بنجاح',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.success,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
