import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../link_api.dart';

class DeletePrices extends StatefulWidget {
  final int mainId;

  const DeletePrices({super.key, required this.mainId});

  @override
  _DeletePricesState createState() => _DeletePricesState();
}

class _DeletePricesState extends State<DeletePrices> {
  List<dynamic> datas = [];
  bool isLoading = true;
  bool isDeleting = false;
  Map<String, String> myHeaders = getMyHeaders();

  bool get shouldUseSingleDisplay => widget.mainId == 6 || widget.mainId == 7;

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

  Future<void> deletePrice(int priceId, String priceName) async {
    if (isDeleting) return;

    // تأكيد الحذف
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف سعر "$priceName"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmDelete != true) return;

    setState(() {
      isDeleting = true;
    });

    try {
      final requestBody = <String, String>{
        'type': priceId.toString(),
      };

    

      final response = await http.post(
        Uri.parse(ApiLinks.deletePrices),
        headers: myHeaders,
        body: requestBody,
      );

     

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف سعر "$priceName" بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        // إعادة تحميل البيانات
        await fetchDatas();
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء حذف السعر: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isDeleting = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDatas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("حذف الأسعار"),
        centerTitle: true,
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
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
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 7),
                                          shouldUseSingleDisplay
                                              ? Container(
                                                  width: double.infinity,
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade300,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        "السعر",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      Text(
                                                        data['higher']
                                                                ?.toString() ??
                                                            data['lower']
                                                                ?.toString() ??
                                                            'غير محدد',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .grey.shade100,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          border: Border.all(
                                                            color: Colors.grey
                                                                .shade300,
                                                          ),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "السعر الأعلى",
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                            Text(
                                                              data['higher']
                                                                      ?.toString() ??
                                                                  'غير محدد',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 15),
                                                    Expanded(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .grey.shade100,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          border: Border.all(
                                                            color: Colors.grey
                                                                .shade300,
                                                          ),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "السعر الأدنى",
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                            Text(
                                                              data['lower']
                                                                      ?.toString() ??
                                                                  'غير محدد',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          const SizedBox(height: 10),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: isDeleting
                                                  ? null
                                                  : () => deletePrice(
                                                      data['id'],
                                                      data['name']
                                                              ?.toString() ??
                                                          'غير محدد'),
                                              icon: isDeleting
                                                  ? const SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors.white),
                                                      ),
                                                    )
                                                  : const Icon(Icons.delete),
                                              label: Text(isDeleting
                                                  ? 'جاري الحذف...'
                                                  : 'حذف السعر'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.red.shade700,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                              ),
                                            ),
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
