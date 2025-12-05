import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../link_api.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<dynamic> analyticsData = [];
  bool isLoading = true;
  String selectedPeriod = '7days';
  Map<String, String> myHeaders = getMyHeaders();

  // خريطة أسماء الأدوات
  final Map<int, String> toolsNames = {
    1: 'FCR',
    2: 'ADG',
    3: 'كثافة الفراخ',
    4: 'استهلاك العلف اليومي',
    5: 'استهلاك العلف الكلي',
    6: 'الوزن حسب العمر',
    7: 'درجة الحرارة حسب العمر',
    8: 'ساعات الإضلام',
    9: 'تشغيل الشفاطات',
    10: 'جدول التحصينات',
    11: 'مقالات',
    12: 'الأمراض',
    13: 'متطلبات فراخ التسمين',
    14: 'دراسة جدوى',
    15: 'تكلفة إنتاج الفراخ',
    16: 'تكلفة العلف لكل طائر',
    17: 'تكلفة العلف لكل كيلو وزن',
    18: 'الربح الصافي للطائر',
    19: 'ROI',
    20: 'نسبة النفوق',
    21: 'الوزن الإجمالي',
    22: 'إجمالي الإيرادات',
  };

  final List<Map<String, String>> periods = [
    {'value': '7days', 'label': 'آخر 7 أيام'},
    {'value': '30days', 'label': 'آخر 30 يوم'},
    {'value': '1year', 'label': 'آخر سنة'},
    {'value': 'alltime', 'label': 'كل الأوقات'},
  ];

  String getToolName(int toolId) {
    return toolsNames[toolId] ?? 'أداة غير معروفة';
  }

  String formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]},',
        );
  }

  Future<void> fetchAnalyticsData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiLinks.toolsAnalytics),
        headers: myHeaders,
        body: {'period': selectedPeriod},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success' && jsonData['data'] != null) {
          setState(() {
            analyticsData = jsonData['data']['data'] ?? [];
            isLoading = false;
          });
        } else {
          setState(() {
            analyticsData = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          analyticsData = [];
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        analyticsData = [];
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAnalyticsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إحصائيات الأدوات"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: fetchAnalyticsData,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث البيانات',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: selectedPeriod,
              decoration: const InputDecoration(
                labelText: 'اختر الفترة الزمنية',
                border: OutlineInputBorder(),
              ),
              items: periods.map((period) {
                return DropdownMenuItem<String>(
                  value: period['value'],
                  child: Text(period['label']!),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedPeriod = newValue;
                  });
                  fetchAnalyticsData();
                }
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : analyticsData.isEmpty
                    ? const Center(child: Text('لا توجد بيانات'))
                    : ListView.builder(
                        itemCount: analyticsData.length,
                        itemBuilder: (context, index) {
                          final data = analyticsData[index];
                          final toolId = data['tool_id'] as int;
                          final toolName = getToolName(toolId);

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  formatNumber(data['total_usage']),
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Align(
                                alignment: Alignment.centerRight,
                                child: Text(toolName),
                              ),
                              subtitle: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'رقم الأداة: $toolId',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
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
