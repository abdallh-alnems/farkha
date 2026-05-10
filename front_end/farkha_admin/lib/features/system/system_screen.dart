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
  String? _filterAction;
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;
  int _auditPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  static const _actionLabels = <String, String>{
    'auth.login': 'تسجيل دخول',
    'auth.logout': 'تسجيل خروج',
    'admin.create': 'إنشاء أدمن',
    'admin.update': 'تعديل أدمن',
    'user.delete': 'حذف مستخدم',
    'user.notify': 'إرسال إشعار لمستخدم',
    'cycle.hard_delete': 'حذف دورة نهائياً',
    'cycle.soft_delete': 'حذف دورة',
    'cycle.force_close': 'إغلاق دورة بالقوة',
    'cycle.restore': 'استعادة دورة',
    'notification.send_all': 'إرسال إشعار للجميع',
    'notification.send_user': 'إرسال إشعار لمستخدم',
    'notification.send_topic': 'إرسال إشعار لموضوع',
    'remote_config.update': 'تعديل إعداد',
    'remote_config.delete': 'حذف إعداد',
    'cache.clear': 'مسح الكاش',
    'db.sql_select': 'استعلام قاعدة بيانات',
    'article.add': 'إضافة مقال',
    'article.update': 'تعديل مقال',
    'category.add': 'إضافة فئة',
    'category.update': 'تعديل فئة',
    'category.delete': 'حذف فئة',
    'type.add': 'إضافة نوع',
    'type.update': 'تعديل نوع',
    'type.delete': 'حذف نوع',
  };

  static const _actionColors = <String, Color>{
    'auth.': Colors.blue,
    'admin.': Colors.purple,
    'user.': Colors.red,
    'cycle.': Colors.orange,
    'notification.': Colors.teal,
    'remote_config.': Colors.indigo,
    'cache.': Colors.grey,
    'db.': Colors.brown,
    'article.': Colors.green,
    'category.': Colors.cyan,
    'type.': Colors.pink,
  };

  static const _targetLabels = <String, String>{
    'admin_user': 'أدمن',
    'user': 'مستخدم',
    'cycle': 'دورة',
    'broadcast': 'جميع المستخدمين',
    'topic': 'موضوع',
    'article': 'مقال',
    'category': 'فئة',
    'type': 'نوع',
    'remote_config_param': 'إعداد',
    'cache': 'كاش',
    'sql': 'استعلام',
  };

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
      _auditPage = 1;
      _hasMore = true;
      auditLog = [];
      await _loadAuditLog();
    } catch (_) {}
    setState(() => isLoading = false);
  }

  Future<void> _loadAuditLog() async {
    try {
      final body = <String, dynamic>{
        'page': _auditPage,
        'page_size': 30,
      };
      if (_filterAction != null) body['action'] = _filterAction;
      if (_filterDateFrom != null) body['date_from'] = _filterDateFrom!.toIso8601String().split('T').first;
      if (_filterDateTo != null) body['date_to'] = _filterDateTo!.toIso8601String().split('T').first;

      final res = await AdminApi.post('/admin/audit/list.php', body);
      final items = res['data']?['items'] as List<dynamic>? ?? [];
      final total = res['data']?['total'] as int? ?? 0;

      setState(() {
        if (_auditPage == 1) {
          auditLog = items;
        } else {
          auditLog.addAll(items);
        }
        _hasMore = auditLog.length < total;
        _isLoadingMore = false;
      });
    } catch (_) {
      setState(() => _isLoadingMore = false);
    }
  }

  void _loadMore() {
    if (_isLoadingMore || !_hasMore) return;
    _auditPage++;
    _isLoadingMore = true;
    _loadAuditLog();
  }

  Color _getActionColor(String action) {
    for (final entry in _actionColors.entries) {
      if (action.startsWith(entry.key)) return entry.value;
    }
    return AppTheme.primary;
  }

  IconData _getActionIcon(String action) {
    if (action.startsWith('auth.')) return action.contains('login') ? Icons.login : Icons.logout;
    if (action.startsWith('admin.')) return Icons.admin_panel_settings;
    if (action.startsWith('user.')) return action.contains('delete') ? Icons.person_remove : Icons.person;
    if (action.startsWith('cycle.')) return Icons.agriculture;
    if (action.startsWith('notification.')) return Icons.notifications;
    if (action.startsWith('remote_config.')) return Icons.tune;
    if (action.startsWith('cache.')) return Icons.delete_sweep;
    if (action.startsWith('db.')) return Icons.storage;
    if (action.startsWith('article.')) return Icons.article;
    if (action.startsWith('category.')) return Icons.category;
    if (action.startsWith('type.')) return Icons.label;
    return Icons.history;
  }

  String _relativeTime(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
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
    return Column(
      children: [
        _buildAuditFilters(),
        Expanded(
          child: auditLog.isEmpty
              ? const Center(
                  child: Text('لا توجد عمليات', style: TextStyle(fontFamily: 'Cairo', color: AppTheme.textSecondary, fontSize: 16)),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (notif) {
                    if (notif.metrics.pixels >= notif.metrics.maxScrollExtent - 200) _loadMore();
                    return false;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: auditLog.length + (_hasMore ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == auditLog.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary))),
                        );
                      }
                      return _buildAuditItem(auditLog[i] as Map<String, dynamic>);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAuditFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        children: [
          ActionChip(
            avatar: const Icon(Icons.filter_list, size: 16),
            label: Text(
              _filterAction != null ? (_actionLabels[_filterAction] ?? _filterAction!) : 'النوع',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: _filterAction != null ? Colors.white : AppTheme.textPrimary),
            ),
            backgroundColor: _filterAction != null ? AppTheme.primary : AppTheme.surfaceLight,
            onPressed: _showActionFilter,
          ),
          ActionChip(
            avatar: const Icon(Icons.calendar_today, size: 16),
            label: Text(
              _hasDateFilter
                  ? _dateFilterLabel
                  : 'التاريخ',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: _hasDateFilter ? Colors.white : AppTheme.textPrimary),
            ),
            backgroundColor: _hasDateFilter ? AppTheme.primary : AppTheme.surfaceLight,
            onPressed: _showDateFilter,
          ),
          if (_filterAction != null || _hasDateFilter)
            ActionChip(
              avatar: const Icon(Icons.clear, size: 16),
              label: const Text('إعادة تعيين', style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
              backgroundColor: AppTheme.accent.withValues(alpha: 0.1),
              onPressed: () {
                _filterAction = null;
                _filterDateFrom = null;
                _filterDateTo = null;
                _auditPage = 1;
                auditLog = [];
                _loadAuditLog();
              },
            ),
        ],
      ),
    );
  }

  bool get _hasDateFilter => _filterDateFrom != null || _filterDateTo != null;

  String get _dateFilterLabel {
    final from = _filterDateFrom;
    final to = _filterDateTo;
    if (from != null && to != null) return '${from.day}/${from.month} - ${to.day}/${to.month}';
    if (from != null) return 'من ${from.day}/${from.month}';
    if (to != null) return 'حتى ${to.day}/${to.month}';
    return 'التاريخ';
  }

  Widget _buildAuditItem(Map<String, dynamic> a) {
    final action = a['action'] ?? '';
    final color = _getActionColor(action);
    final icon = _getActionIcon(action);
    final label = _actionLabels[action] ?? action;
    final targetType = _targetLabels[a['target_type']] ?? a['target_type'] ?? '';
    final targetId = a['target_id'] ?? '';
    final admin = a['admin_username'] ?? '—';
    final time = _relativeTime(a['created_at']);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showAuditDetail(a),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          admin,
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey.shade600),
                        ),
                        if (targetType.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '$targetType${targetId.isNotEmpty ? ' #$targetId' : ''}',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.grey.shade600),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                time,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAuditDetail(Map<String, dynamic> a) {
    final action = a['action'] ?? '';
    final label = _actionLabels[action] ?? action;
    final targetType = _targetLabels[a['target_type']] ?? a['target_type'] ?? '';
    final payload = a['payload'];
    final color = _getActionColor(action);

    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        title: Row(
          children: [
            Icon(_getActionIcon(action), color: color, size: 24),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 16, color: color)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('الأدمن', a['admin_username'] ?? '—'),
              _detailRow('الهدف', targetType.isNotEmpty ? '$targetType ${a['target_id'] ?? ''}' : '—'),
              _detailRow('IP', a['ip'] ?? '—'),
              _detailRow('الوقت', a['created_at'] ?? '—'),
              if (payload != null) ...[
                const SizedBox(height: 8),
                const Text('التفاصيل:', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    payload.toString(),
                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Get.back(), child: const Text('إغلاق'))],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showActionFilter() {
    final categories = <String, List<String>>{};
    for (final action in _actionLabels.keys) {
      final prefix = action.split('.').first;
      categories.putIfAbsent(prefix, () => []).add(action);
    }

    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        title: const Text('تصفية حسب النوع', style: TextStyle(fontFamily: 'Cairo')),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('الكل', style: TextStyle(fontFamily: 'Cairo')),
                onTap: () {
                  _filterAction = null;
                  Get.back();
                  _auditPage = 1;
                  auditLog = [];
                  _loadAuditLog();
                },
              ),
              ...categories.entries.expand((cat) => [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    _categoryLabel(cat.key),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getActionColor('${cat.key}.'),
                    ),
                  ),
                ),
                ...cat.value.map((action) => ListTile(
                  dense: true,
                  title: Text(_actionLabels[action]!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                  trailing: _filterAction == action ? const Icon(Icons.check, color: AppTheme.primary, size: 18) : null,
                  onTap: () {
                    _filterAction = action;
                    Get.back();
                    _auditPage = 1;
                    auditLog = [];
                    _loadAuditLog();
                  },
                )),
              ]),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Get.back(), child: const Text('إغلاق'))],
      ),
    );
  }

  String _categoryLabel(String prefix) {
    switch (prefix) {
      case 'auth': return 'المصادقة';
      case 'admin': return 'إدارة الحسابات';
      case 'user': return 'المستخدمون';
      case 'cycle': return 'الدورات';
      case 'notification': return 'الإشعارات';
      case 'remote_config': return 'الإعدادات';
      case 'cache': return 'الكاش';
      case 'db': return 'قاعدة البيانات';
      case 'article': return 'المقالات';
      case 'category': return 'الفئات';
      case 'type': return 'الأنواع';
      default: return prefix;
    }
  }

  void _showDateFilter() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      _filterDateFrom = picked.start;
      _filterDateTo = picked.end;
      _auditPage = 1;
      auditLog = [];
      _loadAuditLog();
    }
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
