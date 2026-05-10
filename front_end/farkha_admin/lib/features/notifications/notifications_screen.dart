import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/api/admin_api.dart';
import '../../core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final titleCtrl = TextEditingController();
  final bodyCtrl = TextEditingController();
  final userIdCtrl = TextEditingController();
  final topicCtrl = TextEditingController();
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    titleCtrl.dispose();
    bodyCtrl.dispose();
    userIdCtrl.dispose();
    topicCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'للجميع'),
            Tab(text: 'لمستخدم'),
            Tab(text: 'لموضوع'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildForm(() => _send('all')),
          _buildForm(() => _send('user'), extraField: _userIdField()),
          _buildForm(() => _send('topic'), extraField: _topicField()),
        ],
      ),
    );
  }

  Widget _buildForm(VoidCallback onSend, {Widget? extraField}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleCtrl,
            maxLength: 60,
            decoration: const InputDecoration(labelText: 'العنوان', counterStyle: TextStyle(color: AppTheme.textSecondary)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: bodyCtrl,
            maxLines: 4,
            maxLength: 200,
            decoration: const InputDecoration(labelText: 'النص', counterStyle: TextStyle(color: AppTheme.textSecondary)),
          ),
          if (extraField != null) ...[const SizedBox(height: 12), extraField],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isSending ? null : onSend,
              child: isSending
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('إرسال'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userIdField() => TextField(
        controller: userIdCtrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'رقم المستخدم (ID)'),
      );

  Widget _topicField() => TextField(
        controller: topicCtrl,
        decoration: const InputDecoration(labelText: 'اسم الموضوع (Topic)'),
      );

  Future<void> _send(String type) async {
    if (titleCtrl.text.isEmpty) {
      Get.snackbar('خطأ', 'أدخل العنوان', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => isSending = true);
    try {
      if (type == 'all') {
        await AdminApi.post('/admin/notifications/send_all_users.php', {
          'title': titleCtrl.text, 'body': bodyCtrl.text,
        });
      } else if (type == 'user') {
        await AdminApi.post('/admin/notifications/send_to_user.php', {
          'user_id': int.tryParse(userIdCtrl.text) ?? 0,
          'title': titleCtrl.text, 'body': bodyCtrl.text,
        });
      } else {
        await AdminApi.post('/admin/notifications/send_topic.php', {
          'topic': topicCtrl.text,
          'title': titleCtrl.text, 'body': bodyCtrl.text,
        });
      }
      Get.snackbar('تم', 'تم إرسال الإشعار بنجاح', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppTheme.success, colorText: Colors.white);
      titleCtrl.clear();
      bodyCtrl.clear();
    } on AdminApiException catch (e) {
      Get.snackbar('خطأ', e.message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => isSending = false);
    }
  }
}
