import 'package:flutter/material.dart';
import '../../core/api/admin_api.dart';
import '../../core/theme/app_theme.dart';

class DeletePricesScreen extends StatefulWidget {
  final int mainId;
  const DeletePricesScreen({super.key, required this.mainId});

  @override
  State<DeletePricesScreen> createState() => _DeletePricesScreenState();
}

class _DeletePricesScreenState extends State<DeletePricesScreen> {
  List<dynamic> datas = [];
  bool isLoading = true;
  bool isDeleting = false;

  bool get singleDisplay => widget.mainId == 6 || widget.mainId == 7;

  Future<void> fetchData() async {
    try {
      final res = await AdminApi.post('/admin/prices/today.php', {'type': widget.mainId.toString()});
      setState(() { datas = res['data'] ?? []; isLoading = false; });
    } catch (_) {
      setState(() { datas = []; isLoading = false; });
    }
  }

  Future<void> deletePrice(int typeId, String name) async {
    if (isDeleting) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف سعر "$name"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(_, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => isDeleting = true);
    try {
      await AdminApi.post('/admin/prices/delete.php', {'type': typeId});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم حذف "$name" بنجاح'), backgroundColor: Colors.green));
        await fetchData();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => isDeleting = false);
    }
  }

  @override
  void initState() { super.initState(); fetchData(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("حذف الأسعار")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              itemCount: datas.length,
              itemBuilder: (context, i) {
                final d = datas[i];
                final name = d['name']?.toString() ?? 'غير محدد';
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 7),
                        singleDisplay
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(8)),
                                child: Text(d['higher']?.toString() ?? d['lower']?.toString() ?? '-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              )
                            : Row(
                                children: [
                                  Expanded(child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(8)),
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const Text("الأعلى", style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                      Text(d['higher']?.toString() ?? '-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ]),
                                  )),
                                  const SizedBox(width: 15),
                                  Expanded(child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(8)),
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const Text("الأدنى", style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                      Text(d['lower']?.toString() ?? '-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ]),
                                  )),
                                ],
                              ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isDeleting ? null : () => deletePrice(d['id'], name),
                            icon: const Icon(Icons.delete),
                            label: Text(isDeleting ? 'جاري الحذف...' : 'حذف السعر'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent, foregroundColor: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
