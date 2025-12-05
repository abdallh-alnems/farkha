import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'prices/prices_screen.dart';
import 'analytics_screen.dart';
import 'articles/articles_list.dart';
import 'suggestions_screen.dart';
import '../link_api.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void deleteCache(BuildContext context) async {
    final response = await http.post(
      Uri.parse(ApiLinks.deleteCash),
      headers: getMyHeaders(),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم مسح الكاش بنجاح')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في مسح الكاش')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          ElevatedButton(
            onPressed: () => deleteCache(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("مسح الكاش"),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PricesScreen(),
                ),
              ),
              child: const Text("الاسعار"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ArticlesListScreen(),
                ),
              ),
              child: const Text("المقالات"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnalyticsScreen(),
                ),
              ),
              child: const Text("احصائيات الادوات"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SuggestionsScreen(),
                ),
              ),
              child: const Text("الاقتراحات"),
            ),
          ],
        ),
      ),
    );
  }
}
