import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../link_api.dart';

class AddPrices extends StatefulWidget {
  final int mainId;

  const AddPrices({super.key, required this.mainId});

  @override
  _AddPricesState createState() => _AddPricesState();
}

class _AddPricesState extends State<AddPrices> {
  List<dynamic> datas = [];
  List<TextEditingController> higherPriceControllers = [];
  List<TextEditingController> lowerPriceControllers = [];
  bool isLoading = true;
  bool isSubmitting = false;
  Map<String, String> myHeaders = getMyHeaders();

  Future<void> fetchdatas() async {
    try {
      final response = await http.post(
        Uri.parse(ApiLinks.getLastPrices),
        headers: myHeaders,
        body: {'type': widget.mainId.toString()},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success' && jsonData['data'] != null) {
          setState(() {
            datas = jsonData['data'];
            higherPriceControllers = List.generate(
              datas.length,
              (index) => TextEditingController(),
            );
            lowerPriceControllers = List.generate(
              datas.length,
              (index) => TextEditingController(),
            );
            isLoading = false;
          });
        } else {
          setState(() {
            datas = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          datas = [];
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        datas = [];
        isLoading = false;
      });
    }
  }

  Future<void> submitPrices() async {
    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      for (int i = 0; i < datas.length; i++) {
        String higherPrice = higherPriceControllers[i].text.trim();
        String lowerPrice = lowerPriceControllers[i].text.trim();

        if (higherPrice.isNotEmpty || lowerPrice.isNotEmpty) {
          final requestBody = <String, String>{
            'type': datas[i]['id'].toString(),
          };

          if (higherPrice.isNotEmpty) {
            requestBody['higher'] = higherPrice;
          }

          if (lowerPrice.isNotEmpty) {
            requestBody['lower'] = lowerPrice;
          }

          final response = await http.post(
            Uri.parse(ApiLinks.add),
            headers: myHeaders,
            body: requestBody,
          );

          if (response.statusCode != 200) {
            throw Exception('HTTP ${response.statusCode}: ${response.body}');
          }
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة جميع الأسعار بنجاح')),
      );
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إرسال البيانات: $error')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchdatas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("اضافة السعر"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: isSubmitting ? null : submitPrices,
            icon: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save),
            tooltip: 'حفظ الأسعار',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        datas.isEmpty
                            ? const Center(child: Text('لا توجد بيانات'))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: datas.length,
                                itemBuilder: (context, index) {
                                  final data = datas[index];
                                  return Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['name']?.toString() ??
                                                'غير محدد',
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 7),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  controller:
                                                      higherPriceControllers[
                                                          index],
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        "السعر الأعلى: ${data['higher']?.toString() ?? 'غير محدد'}",
                                                    border:
                                                        const OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 15),
                                              Expanded(
                                                child: TextField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  controller:
                                                      lowerPriceControllers[
                                                          index],
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        "السعر الأدنى: ${data['lower']?.toString() ?? 'غير محدد'}",
                                                    border:
                                                        const OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
