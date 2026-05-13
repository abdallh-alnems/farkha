import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/theme/app_theme.dart';
import 'add_prices_screen.dart';
import 'edit_prices_screen.dart';
import 'delete_prices_screen.dart';

class MainTypesScreen extends StatefulWidget {
  final bool isEditMode;
  final bool isDeleteMode;

  const MainTypesScreen({super.key, this.isEditMode = false, this.isDeleteMode = false});

  @override
  State<MainTypesScreen> createState() => _MainTypesScreenState();
}

class _MainTypesScreenState extends State<MainTypesScreen> {
  List<dynamic> items = [];
  bool isLoading = true;

  Future<void> fetchData() async {
    try {
      final base = dotenv.get('API_HOST');
      final res = await http.get(
        Uri.parse('$base/app/prices/main_types.php'),
        headers: {'Content-Type': 'application/json'},
      );
      if (res.statusCode == 200) {
        final jsonData = json.decode(res.body);
        setState(() {
          items = jsonData['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الأنواع")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : items.isEmpty
              ? const Center(child: Text('لا توجد بيانات', style: TextStyle(fontFamily: 'Cairo')))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Widget target;
                          if (widget.isDeleteMode) {
                            target = DeletePricesScreen(mainId: item['id']);
                          } else if (widget.isEditMode) {
                            target = EditPricesScreen(mainId: item['id']);
                          } else {
                            target = AddPricesScreen(mainId: item['id']);
                          }
                          Navigator.push(context, MaterialPageRoute(builder: (_) => target));
                        },
                        child: Text(item['name']?.toString() ?? 'غير محدد', style: const TextStyle(fontSize: 18)),
                      ),
                    );
                  },
                ),
    );
  }
}
