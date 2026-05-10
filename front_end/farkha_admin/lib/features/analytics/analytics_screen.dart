import 'package:flutter/material.dart';
import '../../core/api/admin_api.dart';
import '../../core/theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<dynamic> analyticsData = [];
  bool isLoading = true;
  String selectedPeriod = '7days';

  final Map<int, String> toolsNames = {
    1: 'FCR', 2: 'ADG', 3: 'كثافة الفراخ', 4: 'استهلاك العلف اليومي',
    5: 'استهلاك العلف الكلي', 6: 'الوزن حسب العمر', 7: 'الحرارة حسب العمر',
    8: 'ساعات الإضاءة', 9: 'الشفاطات', 10: 'التحصينات', 11: 'المقالات',
    12: 'الأمراض', 13: 'متطلبات التسمين', 14: 'دراسة جدوى', 15: 'تكلفة الإنتاج',
    16: 'تكلفة العلف/طائر', 17: 'تكلفة العلف/كيلو', 18: 'ربح/طائر',
    19: 'ROI', 20: 'النفوق', 21: 'الوزن الإجمالي', 22: 'الإيرادات',
    23: 'استهلاك الماء', 24: 'الطقس',
  };

  final List<Map<String, String>> periods = [
    {'value': '7days', 'label': 'آخر 7 أيام'},
    {'value': '30days', 'label': 'آخر 30 يوم'},
    {'value': '1year', 'label': 'آخر سنة'},
    {'value': 'alltime', 'label': 'كل الأوقات'},
  ];

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      final res = await AdminApi.post('/analytics/tools_analytics.php', {'period': selectedPeriod});
      setState(() {
        analyticsData = res['data']?['data'] ?? [];
        isLoading = false;
      });
    } catch (_) {
      setState(() { analyticsData = []; isLoading = false; });
    }
  }

  String fmtNum(int n) => n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  void initState() { super.initState(); fetchData(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إحصائيات الأدوات"),
        actions: [IconButton(onPressed: fetchData, icon: const Icon(Icons.refresh))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: selectedPeriod,
              decoration: const InputDecoration(labelText: 'اختر الفترة الزمنية'),
              items: periods.map((p) => DropdownMenuItem(value: p['value'], child: Text(p['label']!))).toList(),
              onChanged: (v) { if (v != null) { setState(() => selectedPeriod = v); fetchData(); } },
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : analyticsData.isEmpty
                    ? const Center(child: Text('لا توجد بيانات', style: TextStyle(fontFamily: 'Cairo')))
                    : ListView.builder(
                        itemCount: analyticsData.length,
                        itemBuilder: (_, i) {
                          final d = analyticsData[i];
                          final toolId = d['tool_id'] as int;
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  fmtNum(d['total_usage']),
                                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Align(alignment: Alignment.centerRight, child: Text(toolsNames[toolId] ?? 'أداة $toolId')),
                              subtitle: Align(alignment: Alignment.centerRight, child: Text('رقم الأداة: $toolId', style: TextStyle(color: Colors.grey[600], fontSize: 12))),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
