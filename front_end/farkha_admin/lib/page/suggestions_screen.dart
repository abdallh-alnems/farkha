import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../link_api.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  _SuggestionsScreenState createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  List<dynamic> suggestions = [];
  bool isLoading = true;
  Map<String, String> myHeaders = getMyHeaders();

  String formatDate(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return '';
    }
    // Extract date only (remove time part)
    // Format: "2025-11-25 19:57:48" -> "2025-11-25"
    final parts = dateTimeString.split(' ');
    return parts.isNotEmpty ? parts[0] : dateTimeString;
  }

  Future<void> fetchSuggestions() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(ApiLinks.suggestions),
        headers: myHeaders,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success' && jsonData['data'] != null) {
          setState(() {
            suggestions = jsonData['data'] ?? [];
            isLoading = false;
          });
        } else {
          setState(() {
            suggestions = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          suggestions = [];
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        suggestions = [];
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الاقتراحات"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: fetchSuggestions,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث البيانات',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : suggestions.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد اقتراحات',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = suggestions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              suggestion['suggestions_text']?.toString() ??
                                  'لا يوجد نص',
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  formatDate(suggestion['date']?.toString()),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
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
    );
  }
}
