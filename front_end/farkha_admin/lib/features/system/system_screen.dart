import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/api/admin_api.dart';
import '../../core/theme/app_theme.dart';

class SystemScreen extends StatefulWidget {
  const SystemScreen({super.key});

  @override
  State<SystemScreen> createState() => _SystemScreenState();
}

class _SystemScreenState extends State<SystemScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> tables = [];
  List<dynamic> auditLog = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final res1 = await AdminApi.get('/admin/db/schema.php');
      tables = res1['data'] ?? [];
      final res2 = await AdminApi.post('/admin/audit/list.php', {'page': 1, 'page_size': 50});
      auditLog = res2['data']?['items'] ?? [];
    } catch (_) {}
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('النظام'),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
        bottom: TabBar(controller: _tabController, tabs: const [
          Tab(text: 'قاعدة البيانات'),
          Tab(text: 'سجل العمليات'),
          Tab(text: 'الكاش'),
        ]),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDbTab(),
                _buildAuditTab(),
                _buildCacheTab(),
              ],
            ),
    );
  }

  Widget _buildDbTab() {
    return ListView.builder(
      itemCount: tables.length,
      itemBuilder: (_, i) {
        final t = tables[i] as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          child: ListTile(
            title: Text(t['name'] ?? '-', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14)),
            trailing: Text(
              '${t['row_count'] ?? 0} صف',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppTheme.textSecondary),
            ),
            onTap: () => _previewTable(t['name'] as String),
          ),
        );
      },
    );
  }

  Widget _buildAuditTab() {
    return ListView.builder(
      itemCount: auditLog.length,
      itemBuilder: (_, i) {
        final a = auditLog[i] as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          child: ListTile(
            title: Text(a['action'] ?? '-', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
            subtitle: Text(
              '${a['admin_username'] ?? '-'} • ${a['target_type'] ?? ''} ${a['target_id'] ?? ''}\n${a['created_at'] ?? '-'}',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppTheme.textSecondary),
            ),
            trailing: const Icon(Icons.history, color: AppTheme.primary, size: 20),
          ),
        );
      },
    );
  }

  Widget _buildCacheTab() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              try {
                await AdminApi.post('/admin/cache/clear.php');
                Get.snackbar('تم', 'تم مسح الكاش بنجاح', snackPosition: SnackPosition.BOTTOM);
              } on AdminApiException catch (e) {
                Get.snackbar('خطأ', e.message, snackPosition: SnackPosition.BOTTOM);
              }
            },
            icon: const Icon(Icons.delete_sweep),
            label: const Text('مسح الكاش'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
          ),
        ],
      ),
    );
  }

  void _previewTable(String tableName) async {
    try {
      final res = await AdminApi.post('/admin/db/table_preview.php', {
        'table': tableName,
        'limit': 20,
        'offset': 0,
      });
      final rows = res['data']?['rows'] as List<dynamic>? ?? [];
      if (rows.isEmpty) {
        Get.snackbar('فارغ', 'لا توجد بيانات في هذا الجدول', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      Get.dialog(
        AlertDialog(
          backgroundColor: AppTheme.surfaceLight,
          title: Text(tableName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16)),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: rows.length,
              itemBuilder: (_, i) {
                final row = rows[i] as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      row.entries.map((e) => '${e.key}: ${e.value}').join(' | '),
                      style: const TextStyle(fontSize: 11, fontFamily: 'Cairo'),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [TextButton(onPressed: () => Get.back(), child: const Text('إغلاق'))],
        ),
      );
    } on AdminApiException catch (e) {
      Get.snackbar('خطأ', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
