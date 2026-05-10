import 'package:flutter/material.dart';
import '../../core/api/admin_api.dart';
import '../../core/theme/app_theme.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    try {
      final res1 = await AdminApi.post('/admin/reviews/app_list.php', {'page': 1, 'page_size': 50});
      appReviews = res1['data']?['items'] ?? [];
      final res2 = await AdminApi.post('/admin/reviews/cycle_feedbacks_list.php', {'page': 1, 'page_size': 50});
      cycleFeedbacks = res2['data']?['items'] ?? [];
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
        title: const Text('التقييمات'),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
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
                _buildList(appReviews, isAppReview: true),
                _buildList(cycleFeedbacks, isAppReview: false),
              ],
            ),
    );
  }

  Widget _buildList(List<dynamic> items, {required bool isAppReview}) {
    if (items.isEmpty) return const Center(child: Text('لا توجد تقييمات', style: TextStyle(fontFamily: 'Cairo')));
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) {
        final r = items[i] as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ...List.generate(5, (s) => Icon(s < (r['rating'] ?? 0) ? Icons.star : Icons.star_border, color: Colors.amber, size: 18)),
                    const Spacer(),
                    Text(r['user_name'] ?? '-', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
                if (r['issue'] != null) ...[
                  const SizedBox(height: 6),
                  Text('المشكلة: ${r['issue']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                ],
                if (r['suggestion'] != null) ...[
                  const SizedBox(height: 4),
                  Text('اقتراح: ${r['suggestion']}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppTheme.primary)),
                ],
                const SizedBox(height: 4),
                Text(
                  '${r['created_at'] ?? '-'}${isAppReview && r['platform'] != null ? ' • ${r['platform']}' : ''}${isAppReview && r['app_version'] != null ? ' • v${r['app_version']}' : ''}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
