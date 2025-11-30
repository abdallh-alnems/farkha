import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../../link_api.dart';
import 'widgets/markdown_help_dialog.dart';

// Article Detail Model
class EditArticles {
  final String title;
  final String content;

  const EditArticles({
    required this.title,
    required this.content,
  });

  factory EditArticles.fromJson(Map<String, dynamic> json) => EditArticles(
        title: json['title'] as String? ?? '',
        content: json['content'] as String,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
      };

  @override
  String toString() =>
      'EditArticles(title: $title, content: ${content.length} characters)';
}

// Article Detail Response Model
class EditArticlesResponse {
  final String status;
  final String dataSource;
  final EditArticles data;

  const EditArticlesResponse({
    required this.status,
    required this.dataSource,
    required this.data,
  });

  factory EditArticlesResponse.fromJson(Map<String, dynamic> json) =>
      EditArticlesResponse(
        status: json['status'] as String,
        dataSource: json['data_source'] as String,
        data: EditArticles.fromJson(json['data'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'data_source': dataSource,
        'data': data.toJson(),
      };

  @override
  String toString() =>
      'EditArticlesResponse(status: $status, dataSource: $dataSource)';
}

// Article Detail Service
class EditArticlesService {
  static const Duration _timeout = Duration(seconds: 30);

  /// Fetches article detail by ID from the API
  static Future<EditArticlesResponse> fetchEditArticles(int articleId) async {
    try {
      final url = '${ApiLinks.articleDetail}?id=$articleId';

      final response = await http
          .get(
            Uri.parse(url),
            headers: getMyHeaders(),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return EditArticlesResponse.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw EditArticlesException(
          errorData['message'] ?? 'المقال غير موجود أو تم حذفه',
          response.statusCode,
        );
      } else {
        throw EditArticlesException(
          'Failed to load article: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on http.ClientException {
      throw const EditArticlesException(
          'Network error: Unable to connect to server');
    } on FormatException {
      throw const EditArticlesException('Invalid response format from server');
    } catch (e) {
      throw EditArticlesException('Unexpected error: ${e.toString()}');
    }
  }

  /// Updates article by ID with new title and content
  static Future<Map<String, dynamic>> updateArticle({
    required int articleId,
    required String title,
    required String content,
  }) async {
    try {
      // Send data as body like in add.dart
      final requestBody = {
        'id': articleId.toString(),
        'title': title,
        'content': content,
      };

      final response = await http
          .post(
            Uri.parse(ApiLinks.updateArticles),
            headers: getMyHeaders(),
            body: requestBody,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else if (response.statusCode == 302) {
        throw EditArticlesException(
          'Authentication failed or redirect occurred. Please check your credentials.',
          response.statusCode,
        );
      } else {
        throw EditArticlesException(
          'Failed to update article: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on http.ClientException {
      throw const EditArticlesException(
          'Network error: Unable to connect to server');
    } on FormatException {
      throw const EditArticlesException('Invalid response format from server');
    } catch (e) {
      throw EditArticlesException('Unexpected error: ${e.toString()}');
    }
  }
}

class EditArticlesException implements Exception {
  final String message;
  final int? statusCode;

  const EditArticlesException(this.message, [this.statusCode]);

  @override
  String toString() => 'EditArticlesException: $message';
}

// Main Article Detail Screen
class EditArticlesScreen extends StatefulWidget {
  final int articleId;
  final String articleTitle;

  const EditArticlesScreen({
    super.key,
    required this.articleId,
    required this.articleTitle,
  });

  @override
  State<EditArticlesScreen> createState() => _EditArticlesScreenState();
}

class _EditArticlesScreenState extends State<EditArticlesScreen> {
  EditArticles? _editArticles;
  bool _isLoading = false;
  String _errorMessage = '';
  String _dataSource = '';
  bool _isMarkdownView = false;
  bool _isSaving = false;
  late TextEditingController _textController;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _titleController = TextEditingController();
    _titleController.text =
        widget.articleTitle; // Initialize with article title
    _fetchEditArticles();
  }

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _fetchEditArticles() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final EditArticlesResponse response =
          await EditArticlesService.fetchEditArticles(widget.articleId);

      if (response.status == 'success') {
        setState(() {
          _editArticles = response.data;
          _dataSource = response.dataSource;
          _textController.text = response.data.content;
          _titleController.text = response.data.title.isNotEmpty
              ? response.data.title
              : widget.articleTitle;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load article: ${response.status}';
        });
      }
    } on EditArticlesException catch (e) {
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

  Future<void> _refreshEditArticles() async {
    await _fetchEditArticles();
  }

  Future<void> _saveContent() async {
    if (_editArticles == null || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final response = await EditArticlesService.updateArticle(
        articleId: widget.articleId,
        title: _titleController.text, // Use the title from controller
        content: _textController.text,
      );

      if (response['status'] == 'success') {
        setState(() {
          _editArticles = EditArticles(
            title: _titleController.text,
            content: _textController.text,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'تم حفظ التعديلات بنجاح'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.pop(context, true);
      } else {
        throw EditArticlesException(
          response['message'] ?? 'فشل في حفظ التعديلات',
        );
      }
    } on EditArticlesException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: ${e.message}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ غير متوقع: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.articleTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showMarkdownHelpDialog(context),
            tooltip: 'دليل التنسيق',
          ),
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveContent,
            tooltip: _isSaving ? 'جاري الحفظ...' : 'حفظ',
          ),
          IconButton(
            icon: Icon(
              _isMarkdownView ? Icons.preview : Icons.code,
            ),
            onPressed: () {
              setState(() {
                _isMarkdownView = !_isMarkdownView;
              });
            },
            tooltip: _isMarkdownView ? 'معاينة Markdown' : 'تعديل Markdown',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _editArticles == null) {
      return const _LoadingWidget();
    }

    if (_errorMessage.isNotEmpty) {
      return _ErrorWidget(
        errorMessage: _errorMessage,
        onRetry: _refreshEditArticles,
      );
    }

    if (_editArticles == null) {
      return const _EmptyWidget();
    }

    return _ArticleContentWidget(
      editArticles: _editArticles!,
      dataSource: _dataSource,
      onRefresh: _refreshEditArticles,
      isMarkdownView: _isMarkdownView,
      textController: _textController,
      titleController: _titleController,
      articleTitle: widget.articleTitle,
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
            'جاري تحميل المقال...',
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
              'حدث خطأ في تحميل المقال',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('العودة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
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
            'لا يوجد محتوى للمقال',
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

class _ArticleContentWidget extends StatelessWidget {
  final EditArticles editArticles;
  final String dataSource;
  final VoidCallback onRefresh;
  final bool isMarkdownView;
  final TextEditingController textController;
  final TextEditingController titleController;
  final String articleTitle;

  const _ArticleContentWidget({
    required this.editArticles,
    required this.dataSource,
    required this.onRefresh,
    required this.isMarkdownView,
    required this.textController,
    required this.titleController,
    required this.articleTitle,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: isMarkdownView
                  ? _MarkdownRenderer(content: textController.text)
                  : _EditableMarkdownContent(
                      content: editArticles.content,
                      textController: textController,
                      titleController: titleController,
                      articleName: articleTitle,
                    ),
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

class _EditableMarkdownContent extends StatelessWidget {
  final String content;
  final TextEditingController textController;
  final TextEditingController titleController;
  final String articleName;

  const _EditableMarkdownContent({
    required this.content,
    required this.textController,
    required this.titleController,
    required this.articleName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Article Title Field
        TextFormField(
          controller: titleController,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'أدخل عنوان المقال...',
            contentPadding: EdgeInsets.all(12),
            labelText: 'العنوان',
          ),
        ),
        const SizedBox(height: 16),
        // Content Field for Markdown
        TextFormField(
          controller: textController,
          maxLines: null,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 16,
            height: 1.8,
            color: Colors.black87,
          ),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'أدخل محتوى المقال هنا...',
            contentPadding: EdgeInsets.all(12),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}

class _MarkdownRenderer extends StatelessWidget {
  final String content;

  const _MarkdownRenderer({required this.content});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MarkdownBody(
        data: content,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(
            fontSize: 15,
            height: 1.7,
            color: Colors.black87,
          ),
          h1Padding: const EdgeInsets.only(top: 13),
          h2Padding: const EdgeInsets.only(top: 11),
          h3Padding: const EdgeInsets.only(top: 7),
          h1: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          h2: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
          h3: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        builders: {
          'h1': CenterHBuilder(),
          'h2': CenterHBuilder(),
          'h3': CenterHBuilder(),
        },
      ),
    );
  }
}

class CenterHBuilder extends MarkdownElementBuilder {
  @override
  Widget visitText(md.Text text, TextStyle? preferredStyle) {
    return Center(
      child: Text(
        text.text,
        style: preferredStyle,
        textAlign: TextAlign.center,
      ),
    );
  }
}
