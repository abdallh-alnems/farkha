import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/theme/app_theme.dart';
import 'add_article_screen.dart';
import 'edit_article_screen.dart';

class Article {
  final int id;
  final String title;
  const Article({required this.id, required this.title});
  factory Article.fromJson(Map<String, dynamic> json) => Article(id: json['id'] as int, title: json['title'] as String);
}

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  List<Article> articles = [];
  bool isLoading = false;
  String errorMsg = '';

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { isLoading = true; errorMsg = ''; });
    try {
      final base = dotenv.get('API_HOST');
      final res = await http.get(Uri.parse('$base/app/articles/list.php'));
      final data = json.decode(res.body);
      setState(() {
        articles = (data['data'] as List?)?.map((e) => Article.fromJson(e)).toList() ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() { errorMsg = e.toString(); isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المقالات'),
        actions: [
          IconButton(onPressed: _fetch, icon: const Icon(Icons.refresh)),
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddArticleScreen()));
              if (result == true) _fetch();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : errorMsg.isNotEmpty
              ? Center(child: Text(errorMsg, style: const TextStyle(color: AppTheme.accent)))
              : articles.isEmpty
                  ? const Center(child: Text('لا توجد مقالات', style: TextStyle(fontFamily: 'Cairo')))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: articles.length,
                      itemBuilder: (_, i) {
                        final a = articles[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(a.title, style: const TextStyle(fontFamily: 'Cairo')),
                            onTap: () async {
                              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => EditArticleScreen(articleId: a.id, articleTitle: a.title)));
                              if (result == true) _fetch();
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
