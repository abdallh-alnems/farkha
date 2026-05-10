import 'package:flutter/material.dart';
import '../../core/api/admin_api.dart';
import '../../core/theme/app_theme.dart';
import 'reviews_filter_sheet.dart';
import 'unstar_dialog.dart';

class StarredReviewsScreen extends StatefulWidget {
  final String type;
  const StarredReviewsScreen({super.key, required this.type});

  @override
  State<StarredReviewsScreen> createState() => _StarredReviewsScreenState();
}

class _StarredReviewsScreenState extends State<StarredReviewsScreen> {
  List<dynamic> items = [];
  bool isLoading = true;

  String? _platform;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool _hasFilter = false;

  bool get isApp => widget.type == 'app';
  String get title => isApp ? 'التقييمات المميزة - التطبيق' : 'التقييمات المميزة - الدورات';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Map<String, dynamic> _buildFilter() {
    final f = <String, dynamic>{'page': 1, 'page_size': 100, 'starred_only': '1'};
    if (_platform != null) f['platform'] = _platform!;
    if (_dateFrom != null) f['date_from'] = '${_dateFrom!.year}-${_dateFrom!.month.toString().padLeft(2, '0')}-${_dateFrom!.day.toString().padLeft(2, '0')}';
    if (_dateTo != null) f['date_to'] = '${_dateTo!.year}-${_dateTo!.month.toString().padLeft(2, '0')}-${_dateTo!.day.toString().padLeft(2, '0')}';
    return f;
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final endpoint = isApp ? '/admin/reviews/app_list.php' : '/admin/reviews/cycle_feedbacks_list.php';
      final res = await AdminApi.post(endpoint, _buildFilter());
      items = res['data']?['items'] ?? [];
    } catch (_) {}
    setState(() => isLoading = false);
  }

  Future<void> _toggleStar(int id) async {
    final confirm = await showUnstarDialog(context);
    if (!confirm) return;
    try {
      await AdminApi.post('/admin/reviews/toggle_star.php', {'type': widget.type, 'id': id});
      await _load();
    } catch (_) {}
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ReviewsFilterSheet(
        platform: _platform,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        onApply: (platform, dateFrom, dateTo) {
          _platform = platform;
          _dateFrom = dateFrom;
          _dateTo = dateTo;
          _hasFilter = platform != null || dateFrom != null || dateTo != null;
          _load();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: _openFilter,
            icon: Badge(
              isLabelVisible: _hasFilter,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'تصفية',
          ),
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : items.isEmpty
              ? const Center(child: Text('لا توجد تقييمات مميزة', style: TextStyle(fontFamily: 'Cairo')))
              : RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final r = items[i] as Map<String, dynamic>;
                      final id = r['id'] as int;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primary.withValues(alpha: 0.15),
                              AppTheme.primary.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ...List.generate(5, (s) => Icon(s < (r['rating'] ?? 0) ? Icons.star : Icons.star_border, color: Colors.amber, size: 18)),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.bookmark, color: AppTheme.primary, size: 13),
                                        SizedBox(width: 2),
                                        Text('مميز', style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.bookmark, color: AppTheme.primary, size: 22),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _toggleStar(id),
                                    tooltip: 'إزالة التمييز',
                                  ),
                                  const SizedBox(width: 8),
                                  Text(r['user_name'] ?? '-', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                ],
                              ),
                              if (r['issue'] != null) ...[
                                const SizedBox(height: 6),
                                Text('المشكلة: ${r['issue']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white)),
                              ],
                              if (r['suggestion'] != null) ...[
                                const SizedBox(height: 4),
                                Text('اقتراح: ${r['suggestion']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppTheme.primary)),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                '${r['created_at'] ?? '-'}${isApp && r['platform'] != null ? ' • ${r['platform']}' : ''}${isApp && r['app_version'] != null ? ' • v${r['app_version']}' : ''}',
                                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
