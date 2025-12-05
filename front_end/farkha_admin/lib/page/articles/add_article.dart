import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../../link_api.dart';
import 'widgets/markdown_help_dialog.dart';

// Add Article Screen
class AddArticleScreen extends StatefulWidget {
  const AddArticleScreen({super.key});

  @override
  State<AddArticleScreen> createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends State<AddArticleScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isSaving = false;
  bool _isMarkdownView = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _addArticle() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال عنوان المقال'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال محتوى المقال'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final response = await _addArticleService(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'تم إضافة المقال بنجاح'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true); // إرجاع true للإشارة إلى نجاح الإضافة
      } else {
        throw Exception(
          response['message'] ?? 'فشل في إضافة المقال',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: ${e.toString()}'),
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

  /// Adds a new article with title and content
  Future<Map<String, dynamic>> _addArticleService({
    required String title,
    required String content,
  }) async {
    try {
      final requestBody = {
        'title': title,
        'content': content,
      };

     

      final response = await http
          .post(
            Uri.parse(ApiLinks.addArticles),
            headers: getMyHeaders(),
            body: requestBody,
          )
          .timeout(const Duration(seconds: 30));

     

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else if (response.statusCode == 302) {
        throw Exception(
          'Authentication failed or redirect occurred. Please check your credentials.',
        );
      } else {
        throw Exception(
          'Failed to add article: ${response.statusCode}',
        );
      }
    } on http.ClientException {
      throw Exception('Network error: Unable to connect to server');
    } on FormatException {
      throw Exception('Invalid response format from server');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إضافة مقال جديد',
          style: TextStyle(
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
            onPressed: _isSaving ? null : _addArticle,
            tooltip: _isSaving ? 'جاري الحفظ...' : 'حفظ المقال',
          ),
        ],
      ),
      body: _isMarkdownView ? _buildMarkdownPreview() : _buildEditForm(),
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title Field
          TextFormField(
            controller: _titleController,
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
          // Content Field
          TextFormField(
            controller: _contentController,
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
              labelText: 'المحتوى',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          // Save Button
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _addArticle,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.add),
            label: Text(_isSaving ? 'جاري الحفظ...' : 'إضافة المقال'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title Preview
          if (_titleController.text.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _titleController.text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Content Preview
          if (_contentController.text.isNotEmpty)
            Directionality(
              textDirection: TextDirection.rtl,
              child: MarkdownBody(
                data: _contentController.text,
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
            )
          else
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(
                child: Text(
                  'لا يوجد محتوى للمعاينة',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
        ],
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
