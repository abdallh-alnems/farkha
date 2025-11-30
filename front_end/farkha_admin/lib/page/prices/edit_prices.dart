import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../link_api.dart';

class EditPrices extends StatefulWidget {
  final int mainId;

  const EditPrices({super.key, required this.mainId});

  @override
  _EditPricesState createState() => _EditPricesState();
}

class _EditPricesState extends State<EditPrices> {
  List<dynamic> datas = [];
  List<TextEditingController> higherPriceControllers = [];
  List<TextEditingController> lowerPriceControllers = [];
  bool isLoading = true;
  bool isSubmitting = false;
  Map<String, String> myHeaders = getMyHeaders();

  bool get shouldUseSingleInput => widget.mainId == 6 || widget.mainId == 7;

  Future<void> fetchDatas() async {
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
            lowerPriceControllers = shouldUseSingleInput
                ? []
                : List.generate(
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

  Future<void> updatePrices() async {
    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      for (int i = 0; i < datas.length; i++) {
        String higherPrice = higherPriceControllers[i].text.trim();
        String lowerPrice =
            shouldUseSingleInput ? '' : lowerPriceControllers[i].text.trim();

        if (!shouldUseSingleInput) {
          final bool areBothEmpty = higherPrice.isEmpty && lowerPrice.isEmpty;
          final bool isOnlyOneFilled =
              (higherPrice.isEmpty && lowerPrice.isNotEmpty) ||
                  (higherPrice.isNotEmpty && lowerPrice.isEmpty);

          if (areBothEmpty) {
            continue;
          }

          if (isOnlyOneFilled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('يرجى إدخال السعر الأعلى والأدنى معاً.'),
              ),
            );
            setState(() {
              isSubmitting = false;
            });
            return;
          }

          final double? higherValue = double.tryParse(higherPrice);
          final double? lowerValue = double.tryParse(lowerPrice);

          if (higherValue == null || lowerValue == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('يرجى إدخال أرقام صحيحة في الحقول.'),
              ),
            );
            setState(() {
              isSubmitting = false;
            });
            return;
          }

          if (lowerValue > higherValue) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('السعر الأدنى يجب ألا يتجاوز السعر الأعلى.'),
              ),
            );
            setState(() {
              isSubmitting = false;
            });
            return;
          }
        }

        if (higherPrice.isNotEmpty ||
            (!shouldUseSingleInput && lowerPrice.isNotEmpty)) {
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
            Uri.parse(ApiLinks.updatePrices),
            headers: myHeaders,
            body: requestBody,
          );

        

          if (response.statusCode != 200) {
            throw Exception('HTTP ${response.statusCode}: ${response.body}');
          }
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث جميع الأسعار بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تحديث البيانات: $error'),
          backgroundColor: Colors.red,
        ),
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
    fetchDatas();
  }

  @override
  void dispose() {
    for (var controller in higherPriceControllers) {
      controller.dispose();
    }
    for (var controller in lowerPriceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تعديل الأسعار"),
        centerTitle: true,
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: isSubmitting ? null : updatePrices,
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
            tooltip: 'حفظ التعديلات',
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
                                          shouldUseSingleInput
                                              ? TextField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  controller:
                                                      higherPriceControllers[
                                                          index],
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        "السعر: ${data['higher']?.toString() ?? data['lower']?.toString() ?? 'غير محدد'}",
                                                    border:
                                                        const OutlineInputBorder(),
                                                  ),
                                                )
                                              : Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextField(
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        controller:
                                                            higherPriceControllers[
                                                                index],
                                                        decoration:
                                                            InputDecoration(
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
                                                            TextInputType
                                                                .number,
                                                        controller:
                                                            lowerPriceControllers[
                                                                index],
                                                        decoration:
                                                            InputDecoration(
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
