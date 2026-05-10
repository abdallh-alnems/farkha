import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/api/admin_api.dart';
import '../../core/theme/app_theme.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<dynamic> categories = [];
  List<dynamic> types = [];
  int? selectedCategoryId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await AdminApi.get('/admin/categories/list.php');
      setState(() => categories = res['data'] ?? []);
      if (selectedCategoryId != null) await _loadTypes();
    } catch (_) {}
    setState(() => isLoading = false);
  }

  Future<void> _loadTypes() async {
    if (selectedCategoryId == null) return;
    try {
      final res = await AdminApi.post('/admin/types/list.php', {'category_id': selectedCategoryId});
      setState(() => types = res['data'] ?? []);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الفئات والأنواع'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            const Text('الفئات', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                            const Spacer(),
                            IconButton(
                              onPressed: () => _addCategory(),
                              icon: const Icon(Icons.add, size: 20),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (_, i) {
                            final c = categories[i] as Map<String, dynamic>;
                            final isSelected = selectedCategoryId == c['id'];
                            return ListTile(
                              selected: isSelected,
                              selectedTileColor: AppTheme.primary.withValues(alpha: 0.1),
                              title: Text(c['name'] ?? '-', style: const TextStyle(fontFamily: 'Cairo')),
                              subtitle: Text('${c['types_count'] ?? 0} نوع', style: const TextStyle(fontSize: 11)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, size: 18, color: AppTheme.accent),
                                onPressed: () => _deleteCategory(c['id'] as int),
                              ),
                              onTap: () {
                                setState(() => selectedCategoryId = c['id'] as int);
                                _loadTypes();
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, color: AppTheme.border),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            const Text('الأنواع', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                            const Spacer(),
                            if (selectedCategoryId != null)
                              IconButton(
                                onPressed: () => _addType(),
                                icon: const Icon(Icons.add, size: 20),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: types.isEmpty
                            ? const Center(child: Text('اختر فئة', style: TextStyle(fontFamily: 'Cairo', color: AppTheme.textSecondary)))
                            : ListView.builder(
                                itemCount: types.length,
                                itemBuilder: (_, i) {
                                  final t = types[i] as Map<String, dynamic>;
                                  return ListTile(
                                    title: Text(t['name'] ?? '-', style: const TextStyle(fontFamily: 'Cairo')),
                                    subtitle: Text('ID: ${t['id']}', style: const TextStyle(fontSize: 11)),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, size: 18, color: AppTheme.accent),
                                      onPressed: () => _deleteType(t['id'] as int),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _addCategory() {
    final ctrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        title: const Text('إضافة فئة', style: TextStyle(fontFamily: 'Cairo')),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'اسم الفئة')),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.isEmpty) return;
              Get.back();
              try {
                await AdminApi.post('/admin/categories/add.php', {'name': ctrl.text});
                _load();
              } on AdminApiException catch (e) {
                Get.snackbar('خطأ', e.message, snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _addType() {
    final ctrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        title: const Text('إضافة نوع', style: TextStyle(fontFamily: 'Cairo')),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'اسم النوع')),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.isEmpty) return;
              Get.back();
              try {
                await AdminApi.post('/admin/types/add.php', {'name': ctrl.text, 'category_id': selectedCategoryId});
                _loadTypes();
              } on AdminApiException catch (e) {
                Get.snackbar('خطأ', e.message, snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(int id) async {
    try {
      await AdminApi.post('/admin/categories/delete.php', {'id': id});
      if (selectedCategoryId == id) {
        setState(() { selectedCategoryId = null; types = []; });
      }
      _load();
    } on AdminApiException catch (e) {
      Get.snackbar('خطأ', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _deleteType(int id) async {
    try {
      await AdminApi.post('/admin/types/delete.php', {'id': id});
      _loadTypes();
    } on AdminApiException catch (e) {
      Get.snackbar('خطأ', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
