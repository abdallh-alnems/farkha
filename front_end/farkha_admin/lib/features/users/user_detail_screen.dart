import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/api/admin_api.dart';
import '../../core/theme/app_theme.dart';
import 'users_controller.dart';

class UserDetailScreen extends StatefulWidget {
  final int userId;
  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await AdminApi.post('/admin/users/detail.php', {'user_id': widget.userId});
      setState(() => data = res['data'] as Map<String, dynamic>?);
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
        title: Text(data?['user']?['name'] ?? 'مستخدم'),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'notify', child: Text('إرسال إشعار')),
              const PopupMenuItem(value: 'delete', child: Text('حذف المستخدم', style: TextStyle(color: AppTheme.accent))),
            ],
            onSelected: (v) {
              if (v == 'notify') _showNotifyDialog();
              if (v == 'delete') _confirmDelete();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'معلومات'),
            Tab(text: 'الأجهزة'),
            Tab(text: 'الدورات'),
            Tab(text: 'التقييمات'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(),
                _buildDevicesTab(),
                _buildCyclesTab(),
                _buildReviewsTab(),
              ],
            ),
    );
  }

  Widget _buildInfoTab() {
    final user = data?['user'] as Map<String, dynamic>? ?? {};
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoRow('الاسم', user['name']),
        _infoRow('الهاتف', user['phone'] ?? 'غير محدد'),
        _infoRow('Firebase UID', user['firebase_uid']),
        _infoRow('تاريخ التسجيل', _formatDate(user['created_at'])),
      ],
    );
  }

  Widget _buildDevicesTab() {
    final devices = data?['devices'] as List<dynamic>? ?? [];
    if (devices.isEmpty) return const Center(child: Text('لا توجد أجهزة', style: TextStyle(fontFamily: 'Cairo')));
    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (_, i) {
        final d = devices[i] as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: Icon(
              d['platform'] == 'ios' ? Icons.phone_iphone : Icons.phone_android,
              color: AppTheme.primary,
            ),
            title: Text(d['platform'] ?? '-', style: const TextStyle(fontFamily: 'Cairo')),
            subtitle: Text('آخر نشاط: ${d['last_active'] ?? '-'}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
          ),
        );
      },
    );
  }

  Widget _buildCyclesTab() {
    final cycles = data?['cycles'] as List<dynamic>? ?? [];
    if (cycles.isEmpty) return const Center(child: Text('لا توجد دورات', style: TextStyle(fontFamily: 'Cairo')));
    return ListView.builder(
      itemCount: cycles.length,
      itemBuilder: (_, i) {
        final c = cycles[i] as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            title: Text(c['name'] ?? '-', style: const TextStyle(fontFamily: 'Cairo')),
            subtitle: Text('${c['role'] ?? '-'} • ${c['chick_count'] ?? 0} فرخة', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
            trailing: c['end_date_raw'] != null
                ? const Icon(Icons.check_circle, color: AppTheme.success, size: 20)
                : c['deleted_at'] != null
                    ? const Icon(Icons.delete, color: AppTheme.accent, size: 20)
                    : const Icon(Icons.circle, color: AppTheme.primary, size: 12),
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    final reviews = data?['reviews'] as List<dynamic>? ?? [];
    if (reviews.isEmpty) return const Center(child: Text('لا توجد تقييمات', style: TextStyle(fontFamily: 'Cairo')));
    return ListView.builder(
      itemCount: reviews.length,
      itemBuilder: (_, i) {
        final r = reviews[i] as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            title: Row(
              children: [
                ...List.generate(5, (s) => Icon(
                  s < (r['rating'] ?? 0) ? Icons.star : Icons.star_border,
                  color: Colors.amber, size: 16,
                )),
              ],
            ),
            subtitle: Text(r['issue'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
          ),
        );
      },
    );
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '-';
    try {
      final utc = DateTime.parse(raw.toString()).toUtc();
      final cairo = utc.add(const Duration(hours: 2));
      return '${DateFormat('yyyy/MM/dd – hh:mm a', 'ar').format(cairo)} (توقيت مصر)';
    } catch (_) {
      return raw.toString();
    }
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontFamily: 'Cairo', fontSize: 13)),
          ),
          Expanded(
            child: Text(value?.toString() ?? '-', style: const TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  void _showNotifyDialog() {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        title: const Text('إرسال إشعار', style: TextStyle(fontFamily: 'Cairo')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'العنوان')),
            const SizedBox(height: 8),
            TextField(controller: bodyCtrl, decoration: const InputDecoration(labelText: 'النص'), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.isEmpty) return;
              Get.back();
              final ok = await Get.find<UsersController>()
                  .sendNotification(widget.userId, titleCtrl.text, bodyCtrl.text);
              if (ok) Get.snackbar('تم', 'تم إرسال الإشعار', snackPosition: SnackPosition.BOTTOM);
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        title: const Text('حذف المستخدم', style: TextStyle(fontFamily: 'Cairo', color: AppTheme.accent)),
        content: const Text('هل أنت متأكد؟ هذا الإجراء لا يمكن التراجع عنه.', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            onPressed: () async {
              Get.back();
              final ok = await Get.find<UsersController>().deleteUser(widget.userId);
              if (ok) {
                Get.snackbar('تم', 'تم حذف المستخدم', snackPosition: SnackPosition.BOTTOM);
                Get.back();
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
