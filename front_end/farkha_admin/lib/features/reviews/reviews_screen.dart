import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/api/admin_api.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import 'reviews_filter_sheet.dart';
import 'unstar_dialog.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> appReviews = [];
  List<dynamic> cycleFeedbacks = [];
  bool isLoading = true;

  String? _platform;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool _hasFilter = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _load();
  }

  Map<String, dynamic> _buildFilter() {
    final f = <String, dynamic>{'page': 1, 'page_size': 50};
    if (_platform != null) f['platform'] = _platform!;
    if (_dateFrom != null) f['date_from'] = '${_dateFrom!.year}-${_dateFrom!.month.toString().padLeft(2, '0')}-${_dateFrom!.day.toString().padLeft(2, '0')}';
    if (_dateTo != null) f['date_to'] = '${_dateTo!.year}-${_dateTo!.month.toString().padLeft(2, '0')}-${_dateTo!.day.toString().padLeft(2, '0')}';
    return f;
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final filter = _buildFilter();
      final res1 = await AdminApi.post('/admin/reviews/app_list.php', filter);
      appReviews = res1['data']?['items'] ?? [];
      final res2 = await AdminApi.post('/admin/reviews/cycle_feedbacks_list.php', filter);
      cycleFeedbacks = res2['data']?['items'] ?? [];
    } catch (_) {}
    setState(() => isLoading = false);
  }

  Future<void> _toggleStar(String type, int id, bool starred) async {
    if (starred) {
      final confirm = await showUnstarDialog(context);
      if (!confirm) return;
    }
    try {
      await AdminApi.post('/admin/reviews/toggle_star.php', {'type': type, 'id': id});
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقييمات'),
        actions: [
          IconButton(
            onPressed: _openFilter,
            icon: Badge(
              isLabelVisible: _hasFilter,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'تصفية',
          ),
          IconButton(
            onPressed: () {
              final route = _tabController.index == 0 ? AppRoutes.starredAppReviews : AppRoutes.starredCycleReviews;
              Get.toNamed(route);
            },
            icon: const Icon(Icons.bookmark_outline),
            tooltip: 'التقييمات المميزة',
          ),
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
        bottom: TabBar(controller: _tabController, tabs: const [
          Tab(text: 'تقييمات التطبيق'),
          Tab(text: 'تقييمات الدورات'),
        ]),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(appReviews, isAppReview: true, type: 'app'),
                _buildList(cycleFeedbacks, isAppReview: false, type: 'cycle'),
              ],
            ),
    );
  }

  Widget _buildList(List<dynamic> items, {required bool isAppReview, required String type}) {
    if (items.isEmpty) {
      return const Center(child: Text('لا توجد تقييمات', style: TextStyle(fontFamily: 'Cairo')));
    }
    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final r = items[i] as Map<String, dynamic>;
          final id = r['id'] as int;
          final starred = (r['is_starred'] ?? 0) == 1;
          return starred
              ? _buildStarredCard(r, id, type, isAppReview)
              : _buildNormalCard(r, id, type, isAppReview);
        },
      ),
    );
  }

  Widget _buildNormalCard(Map<String, dynamic> r, int id, String type, bool isAppReview) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(r, id, type),
            if (r['issue'] != null) ...[
              const SizedBox(height: 6),
              Text('المشكلة: ${r['issue']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
            ],
            if (r['suggestion'] != null) ...[
              const SizedBox(height: 4),
              Text('اقتراح: ${r['suggestion']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppTheme.primary)),
            ],
            const SizedBox(height: 4),
            _buildMeta(r, isAppReview),
          ],
        ),
      ),
    );
  }

  Widget _buildStarredCard(Map<String, dynamic> r, int id, String type, bool isAppReview) {
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
            _buildHeader(r, id, type),
            if (r['issue'] != null) ...[
              const SizedBox(height: 6),
              Text('المشكلة: ${r['issue']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.white)),
            ],
            if (r['suggestion'] != null) ...[
              const SizedBox(height: 4),
              Text('اقتراح: ${r['suggestion']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppTheme.primary)),
            ],
            const SizedBox(height: 4),
            _buildMeta(r, isAppReview),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> r, int id, String type) {
    final starred = (r['is_starred'] ?? 0) == 1;
    return Row(
      children: [
        ...List.generate(5, (s) => Icon(
          s < (r['rating'] ?? 0) ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        )),
        const SizedBox(width: 6),
        if (starred)
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
          icon: Icon(
            starred ? Icons.bookmark : Icons.bookmark_outline,
            color: starred ? AppTheme.primary : AppTheme.textSecondary,
            size: 22,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => _toggleStar(type, id, starred),
          tooltip: starred ? 'إزالة التمييز' : 'تمييز التقييم',
        ),
        const SizedBox(width: 8),
        Text(r['user_name'] ?? '-', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildMeta(Map<String, dynamic> r, bool isAppReview) {
    return Text(
      '${r['created_at'] ?? '-'}${isAppReview && r['platform'] != null ? ' • ${r['platform']}' : ''}${isAppReview && r['app_version'] != null ? ' • v${r['app_version']}' : ''}',
      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
    );
  }
}
