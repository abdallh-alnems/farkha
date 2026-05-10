import 'dart:async';

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

        final maintenanceEnabled = _getParamValue(controller, 'maintenance_enabled') == 'true';

        return RefreshIndicator(
          onRefresh: controller.fetchConfig,
          color: AppTheme.primary,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildMaintenanceCard(context, controller, maintenanceEnabled),
              const SizedBox(height: 20),
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
              ...controller.parameters
                  .where((p) => ((p['name'] as String?) ?? '') != 'maintenance_enabled')
                  .map((param) => _buildParamCard(context, controller, param)),
            ],
          ),
        );
      }),
    );
  }

  String _getParamValue(RemoteConfigController controller, String name) {
    try {
      final param = controller.parameters.firstWhere(
        (p) => (p['name'] as String?) == name,
      );
      return param['default_value']?.toString() ?? 'false';
    } catch (_) {
      return 'false';
    }
  }

  Widget _buildMaintenanceCard(BuildContext context, RemoteConfigController controller, bool isEnabled) {
    final cardColor = isEnabled
        ? AppTheme.accent.withValues(alpha: 0.12)
        : AppTheme.surfaceLight;
    final borderColor = isEnabled
        ? AppTheme.accent.withValues(alpha: 0.6)
        : AppTheme.border;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isEnabled ? 2 : 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isEnabled
                      ? AppTheme.accent.withValues(alpha: 0.2)
                      : AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isEnabled ? Icons.power_settings_new : Icons.check_circle_outline,
                  color: isEnabled ? AppTheme.accent : AppTheme.success,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnabled ? 'التطبيق متوقف' : 'التطبيق يعمل',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        fontFamily: 'Cairo',
                        color: isEnabled ? AppTheme.accent : AppTheme.success,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEnabled
                          ? 'تطبيق فرخة متوقف حالياً عن جميع المستخدمين'
                          : 'جميع المستخدمين يمكنهم استخدام التطبيق',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isEnabled,
                activeTrackColor: AppTheme.accent,
                onChanged: (v) => _onMaintenanceToggle(context, controller, v),
              ),
            ],
          ),
          if (isEnabled) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.accent, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'عند إيقاف التطبيق لن يتمكن أي مستخدم من استخدامه حتى تقوم بإعادة تشغيله',
                      style: TextStyle(
                        color: AppTheme.accent,
                        fontSize: 11,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onMaintenanceToggle(BuildContext context, RemoteConfigController controller, bool value) async {
    final confirmed = await Get.dialog<bool>(
      _CountdownConfirmDialog(isEnabling: value),
      barrierDismissible: false,
    );

    if (confirmed != true) return;

    Get.dialog(
      const _LoadingDialog(),
      barrierDismissible: false,
    );

    final ok = await controller.updateParameter('maintenance_enabled', value.toString());

    Get.back();

    if (ok) {
      Get.snackbar(
        'تم',
        value ? 'تم إيقاف التطبيق' : 'تم تشغيل التطبيق',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: value ? AppTheme.accent : AppTheme.success,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
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

class _LoadingDialog extends StatelessWidget {
  const _LoadingDialog();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: AppTheme.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppTheme.primary),
              SizedBox(height: 16),
              Text(
                'جاري التحديث...',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountdownConfirmDialog extends StatefulWidget {
  final bool isEnabling;
  const _CountdownConfirmDialog({required this.isEnabling});

  @override
  State<_CountdownConfirmDialog> createState() => _CountdownConfirmDialogState();
}

class _CountdownConfirmDialogState extends State<_CountdownConfirmDialog> {
  int _seconds = 3;
  Timer? _timer;
  bool _canConfirm = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isEnabling) {
      _canConfirm = true;
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _seconds--;
        if (_seconds <= 0) {
          _canConfirm = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceLight,
      title: Row(
        children: [
          Icon(
            widget.isEnabling ? Icons.warning_amber : Icons.check_circle,
            color: widget.isEnabling ? AppTheme.accent : AppTheme.success,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            widget.isEnabling ? 'إيقاف التطبيق؟' : 'تشغيل التطبيق؟',
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Text(
        widget.isEnabling
            ? 'هل أنت متأكد؟ سيتم إيقاف تطبيق فرخة فوراً لجميع المستخدمين.\n\nهذا الإجراء لا يمكن التراجع عنه إلا من هنا.'
            : 'هل تريد إعادة تشغيل التطبيق؟ سيعمل بشكل طبيعي لجميع المستخدمين.',
        style: const TextStyle(fontFamily: 'Cairo'),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
        ),
        ElevatedButton(
          onPressed: _canConfirm ? () => Get.back(result: true) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isEnabling ? AppTheme.accent : AppTheme.success,
            disabledBackgroundColor: AppTheme.accent.withValues(alpha: 0.3),
          ),
          child: Text(
            _canConfirm
                ? (widget.isEnabling ? 'إيقاف' : 'تشغيل')
                : '${widget.isEnabling ? 'إيقاف' : 'تشغيل'} ($_seconds)',
            style: const TextStyle(fontFamily: 'Cairo', color: Colors.white),
          ),
        ),
      ],
    );
  }
}
