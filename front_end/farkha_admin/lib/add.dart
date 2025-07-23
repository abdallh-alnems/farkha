import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'link_api.dart';

class AddPrices extends StatefulWidget {
  final int mainId;

  const AddPrices({super.key, required this.mainId});

  @override
  _AddPricesState createState() => _AddPricesState();
}

class _AddPricesState extends State<AddPrices> {
  List<dynamic> eggTypes = [];
  List<TextEditingController> controllers = [];
  bool isLoading = true;
  bool isSubmitting = false;
  Map<String, String> myHeaders = getMyHeaders();

  Future<void> fetchEggTypes() async {
    try {
      final response = await http.post(
        Uri.parse(ApiLinks.getLastPrices),
        headers: myHeaders,
        body: {'type': widget.mainId.toString()},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          eggTypes = jsonData['data'];
          controllers = List.generate(
            eggTypes.length,
            (index) => TextEditingController(),
          );
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      setState(() {
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
      for (int i = 0; i < eggTypes.length; i++) {
        String price = controllers[i].text.trim();
        if (price.isNotEmpty) {
          final response = await http.post(
            Uri.parse(ApiLinks.add),
            headers: myHeaders,
            body: {
              'price': price,
              'type_id': eggTypes[i]['type_id'].toString()
            },
          );

          if (response.statusCode != 200) {
            throw Exception(
                'Failed to submit price for type ${eggTypes[i]['type_id']}');
          }
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة جميع الأسعار بنجاح')),
      );
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء إرسال البيانات.')),
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
    fetchEggTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("اضافة السعر"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        eggTypes.isEmpty
                            ? const Center(child: Text('لا توجد بيانات'))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: eggTypes.length,
                                itemBuilder: (context, index) {
                                  final eggType = eggTypes[index];
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      controller: controllers[index],
                                      decoration: InputDecoration(
                                        labelText:
                                            "${eggType['type']} : ${eggType['price'].toString()}",
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : submitPrices,
                    child: isSubmitting
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text('اضافة الأسعار'),
                  ),
                ),
              ],
            ),
    );
  }
}
