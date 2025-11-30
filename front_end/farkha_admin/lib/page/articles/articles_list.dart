import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../link_api.dart';
import 'edit_articles.dart';
import 'add_article.dart';

// Article Model
class Article {
  final int id;
  final String title;

  const Article({
    required this.id,
    required this.title,
  });

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        id: json['id'] as int,
        title: json['title'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Article && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Article(id: $id, title: $title)';
}

// Articles List Response Model
class ArticlesListResponse {
  final String status;
  final String dataSource;
  final List<Article> data;

  const ArticlesListResponse({
    required this.status,
    required this.dataSource,
    required this.data,
  });

  factory ArticlesListResponse.fromJson(Map<String, dynamic> json) =>
      ArticlesListResponse(
        status: json['status'] as String,
        dataSource: json['data_source'] as String,
        data: (json['data'] as List)
            .map((item) => Article.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'data_source': dataSource,
        'data': data.map((article) => article.toJson()).toList(),
      };

  @override
  String toString() =>
      'ArticlesListResponse(status: $status, dataSource: $dataSource, data: ${data.length} articles)';
}

// Articles Service
class ArticlesService {
  static const Duration _timeout = Duration(seconds: 30);

  /// Fetches the list of articles from the API
  static Future<ArticlesListResponse> fetchArticlesList() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiLinks.articlesList),
            headers: getMyHeaders(),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ArticlesListResponse.fromJson(jsonData);
      } else {
        throw ArticlesException(
          'Failed to load articles: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on http.ClientException {
      throw const ArticlesException(
          'Network error: Unable to connect to server');
    } on FormatException {
      throw const ArticlesException('Invalid response format from server');
    } catch (e) {
      throw ArticlesException('Unexpected error: ${e.toString()}');
    }
  }
}

class ArticlesException implements Exception {
  final String message;
  final int? statusCode;

  const ArticlesException(this.message, [this.statusCode]);

  @override
  String toString() => 'ArticlesException: $message';
}

// Main Articles List Screen
class ArticlesListScreen extends StatefulWidget {
  const ArticlesListScreen({super.key});

  @override
  State<ArticlesListScreen> createState() => _ArticlesListScreenState();
}

class _ArticlesListScreenState extends State<ArticlesListScreen> {
  List<Article> _articles = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _dataSource = '';

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final ArticlesListResponse response =
          await ArticlesService.fetchArticlesList();

      if (response.status == 'success') {
        setState(() {
          _articles = response.data;
          _dataSource = response.dataSource;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load articles: ${response.status}';
        });
      }
    } on ArticlesException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshArticles() async {
    await _fetchArticles();
  }

  void _navigateToAddArticle() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddArticleScreen(),
      ),
    );

    // إذا تم إضافة مقال بنجاح، أعد تحميل القائمة
    if (result == true) {
      _fetchArticles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'قائمة المقالات',
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddArticle,
            tooltip: 'إضافة مقال جديد',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _articles.isEmpty) {
      return const _LoadingWidget();
    }

    if (_errorMessage.isNotEmpty) {
      return _ErrorWidget(
        errorMessage: _errorMessage,
        onRetry: _refreshArticles,
      );
    }

    if (_articles.isEmpty) {
      return const _EmptyWidget();
    }

    return _ArticlesListWidget(
      articles: _articles,
      dataSource: _dataSource,
      onRefresh: _refreshArticles,
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'جاري تحميل المقالات...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorWidget({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ في تحميل البيانات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'لا توجد مقالات متاحة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticlesListWidget extends StatelessWidget {
  final List<Article> articles;
  final String dataSource;
  final VoidCallback onRefresh;

  const _ArticlesListWidget({
    required this.articles,
    required this.dataSource,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: Column(
        children: [
          if (dataSource.isNotEmpty)
            _DataSourceIndicator(dataSource: dataSource),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final Article article = articles[index];
                return _ArticleCard(article: article);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DataSourceIndicator extends StatelessWidget {
  final String dataSource;

  const _DataSourceIndicator({required this.dataSource});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.blue.shade50,
      child: Center(
        child: Text(
          dataSource == 'cache'
              ? 'البيانات من الذاكرة المؤقتة'
              : 'البيانات من قاعدة البيانات',
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;

  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _onArticleTap(context, article),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  article.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onArticleTap(BuildContext context, Article article) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditArticlesScreen(
          articleId: article.id,
          articleTitle: article.title,
        ),
      ),
    );

    // إذا تم تعديل المقال بنجاح، أعد تحميل القائمة
    if (result == true) {
      // نحتاج للوصول للـ parent widget لإعادة التحميل
      if (context.mounted) {
        // البحث عن الـ parent state لإعادة التحميل
        final parentState =
            context.findAncestorStateOfType<_ArticlesListScreenState>();
        parentState?._fetchArticles();
      }
    }
  }
}
