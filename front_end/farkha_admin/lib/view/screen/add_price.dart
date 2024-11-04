import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../link_api.dart';
import '../widget/text_form.dart';

class AddPrice extends StatefulWidget {
  const AddPrice({super.key});

  @override
  _AddPriceState createState() => _AddPriceState();
}

class _AddPriceState extends State<AddPrice> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for each field
  final TextEditingController _frakhAbid = TextEditingController();
  final TextEditingController _frakhSaso = TextEditingController();
  final TextEditingController _katkotAbid = TextEditingController();
  final TextEditingController _katkotSaso = TextEditingController();
  final TextEditingController _bydAhmar = TextEditingController();
  final TextEditingController _bydAbid = TextEditingController();
  final TextEditingController _bydBilde = TextEditingController();
  final TextEditingController _3lafBide = TextEditingController();
  final TextEditingController _3lafNime = TextEditingController();
  final TextEditingController _3lafNihe = TextEditingController();
  final TextEditingController _3lafBideNime = TextEditingController();
  final TextEditingController _3lafByad14 = TextEditingController();
  final TextEditingController _3lafByad16 = TextEditingController();
  final TextEditingController _3lafByad18 = TextEditingController();

  // Add prices
// Add prices
Future _addPrices() async {
  try {
    Uri uri = Uri.parse(ApiLinks.add);

    // List to store fields that have values
    List<Map<String, String>> pricesToSubmit = [];

    // Check each field and add to the list if not empty
    if (_frakhAbid.text.isNotEmpty) {
      pricesToSubmit.add({'price': _frakhAbid.text, 'id_type': "1"});
    }
    if (_frakhSaso.text.isNotEmpty) {
      pricesToSubmit.add({'price': _frakhSaso.text, 'id_type': "2"});
    }
    if (_katkotAbid.text.isNotEmpty) {
      pricesToSubmit.add({'price': _katkotAbid.text, 'id_type': "3"});
    }
    if (_katkotSaso.text.isNotEmpty) {
      pricesToSubmit.add({'price': _katkotSaso.text, 'id_type': "4"});
    }
    if (_bydAhmar.text.isNotEmpty) {
      pricesToSubmit.add({'price': _bydAhmar.text, 'id_type': "5"});
    }
    if (_bydAbid.text.isNotEmpty) {
      pricesToSubmit.add({'price': _bydAbid.text, 'id_type': "6"});
    }
    if (_bydBilde.text.isNotEmpty) {
      pricesToSubmit.add({'price': _bydBilde.text, 'id_type': "7"});
    }
    if (_3lafBide.text.isNotEmpty) {
      pricesToSubmit.add({'price': _3lafBide.text, 'id_type': "8"});
    }
    if (_3lafNime.text.isNotEmpty) {
      pricesToSubmit.add({'price': _3lafNime.text, 'id_type': "9"});
    }
    if (_3lafNihe.text.isNotEmpty) {
      pricesToSubmit.add({'price': _3lafNihe.text, 'id_type': "10"});
    }
    if (_3lafBideNime.text.isNotEmpty) {
      pricesToSubmit.add({'price': _3lafBideNime.text, 'id_type': "11"});
    }
    if (_3lafByad14.text.isNotEmpty) {
      pricesToSubmit.add({'price': _3lafByad14.text, 'id_type': "12"});
    }
    if (_3lafByad16.text.isNotEmpty) {
      pricesToSubmit.add({'price': _3lafByad16.text, 'id_type': "13"});
    }
    if (_3lafByad18.text.isNotEmpty) {
      pricesToSubmit.add({'price': _3lafByad18.text, 'id_type': "14"});
    }

    // Ensure at least one field is filled before submission
    if (pricesToSubmit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب ادخال سعر واحد على الأقل')),
      );
      return;
    }
    String securityKey = dotenv.get("SECURITY_KEY");
    String securityUser = dotenv.get("SECURITY_USER");
     String basicAuth = 'Basic ${base64Encode(utf8.encode('$securityUser:$securityKey'))}';
    Map<String, String> myheaders = {'authorization': basicAuth};
    for (var priceData in pricesToSubmit) {
      final response = await http.post(
        uri,
        body: priceData,
         headers: myheaders,
         // Send each price and its type
      );

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('هناك خطأ في الإرسال')),
        );
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم اضافة الأسعار بنجاح')),
    );
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('حدث خطأ أثناء إضافة الأسعار')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("اضافة سعر جديد"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextForm(price: _frakhAbid, hint: "فرخ ابيض"),
                  TextForm(price: _frakhSaso, hint: "فرخ ساسو"),
                  TextForm(price: _katkotAbid, hint: "كتكوت ابيض"),
                  TextForm(price: _katkotSaso, hint: "كتكوت ساسو"),
                  TextForm(price: _bydAhmar, hint: "بيض احمر"),
                  TextForm(price: _bydAbid, hint: "بيض ابيض"),
                  TextForm(price: _bydBilde, hint: "بيض بلدي"),
                  TextForm(price: _3lafBide, hint: "علف بادي"),
                  TextForm(price: _3lafNime, hint: "علف نامي"),
                  TextForm(price: _3lafNihe, hint: "علف ناهي"),
                  TextForm(price: _3lafBideNime, hint: "علف بادي نامي"),
                  TextForm(price: _3lafByad14, hint: "علف بياض 14"),
                  TextForm(price: _3lafByad16, hint: "علف بياض 16"),
                  TextForm(price: _3lafByad18, hint: "علف بياض 18"),
                  const SizedBox(height: 16.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _addPrices();
                        }
                      },
                      child: const Text('اضافة'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
