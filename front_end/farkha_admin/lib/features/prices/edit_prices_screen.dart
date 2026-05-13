import 'package:flutter/material.dart';
import '../../core/api/admin_api.dart';
import '../../core/theme/app_theme.dart';

class EditPricesScreen extends StatefulWidget {
  final int mainId;
  const EditPricesScreen({super.key, required this.mainId});

  @override
  State<EditPricesScreen> createState() => _EditPricesScreenState();
}

class _EditPricesScreenState extends State<EditPricesScreen> {
  List<dynamic> datas = [];
  List<TextEditingController> higherCtrls = [];
  List<TextEditingController> lowerCtrls = [];
  bool isLoading = true;
  bool isSubmitting = false;

  bool get singleInput => widget.mainId == 6 || widget.mainId == 7;

  Future<void> fetchData() async {
    try {
      final res = await AdminApi.post('/admin/prices/today.php', {'type': widget.mainId.toString()});
      setState(() {
        datas = res['data'] ?? [];
        higherCtrls = List.generate(datas.length, (_) => TextEditingController());
        lowerCtrls = singleInput ? [] : List.generate(datas.length, (_) => TextEditingController());
        isLoading = false;
      });
    } catch (_) {
      setState(() { datas = []; isLoading = false; });
    }
  }

  Future<void> updatePrices() async {
    if (isSubmitting) return;
    setState(() => isSubmitting = true);
    try {
      for (int i = 0; i < datas.length; i++) {
        final h = higherCtrls[i].text.trim();
        final l = singleInput ? '' : lowerCtrls[i].text.trim();
        if (!singleInput) {
          if (h.isEmpty && l.isEmpty) continue;
          if (h.isEmpty || l.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إدخال السعر الأعلى والأدنى معاً.')));
            setState(() => isSubmitting = false);
            return;
          }
          final hv = double.tryParse(h), lv = double.tryParse(l);
          if (hv == null || lv == null) { setState(() => isSubmitting = false); return; }
          if (lv > hv) { setState(() => isSubmitting = false); return; }
        }
        if (h.isNotEmpty || (!singleInput && l.isNotEmpty)) {
          final body = <String, dynamic>{'type': datas[i]['id']};
          if (h.isNotEmpty) body['higher'] = h;
          if (l.isNotEmpty) body['lower'] = l;
          await AdminApi.post('/admin/prices/update.php', body);
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث الأسعار بنجاح'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  void initState() { super.initState(); fetchData(); }

  @override
  void dispose() {
    for (var c in higherCtrls) c.dispose();
    for (var c in lowerCtrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تعديل الأسعار"),
        actions: [
          IconButton(
            onPressed: isSubmitting ? null : updatePrices,
            icon: isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              itemCount: datas.length,
              itemBuilder: (context, i) {
                final d = datas[i];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d['name']?.toString() ?? 'غير محدد', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 7),
                        singleInput
                            ? TextField(
                                keyboardType: TextInputType.number,
                                controller: higherCtrls[i],
                                decoration: InputDecoration(labelText: "السعر: ${d['higher'] ?? d['lower'] ?? '-'}"),
                              )
                            : Row(
                                children: [
                                  Expanded(child: TextField(keyboardType: TextInputType.number, controller: higherCtrls[i], decoration: InputDecoration(labelText: "الأعلى: ${d['higher'] ?? '-'}"))),
                                  const SizedBox(width: 15),
                                  Expanded(child: TextField(keyboardType: TextInputType.number, controller: lowerCtrls[i], decoration: InputDecoration(labelText: "الأدنى: ${d['lower'] ?? '-'}"))),
                                ],
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
