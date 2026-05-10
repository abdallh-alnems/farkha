import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/api/admin_api.dart';
import '../../core/theme/app_theme.dart';

class EditArticleScreen extends StatefulWidget {
  final int articleId;
  final String articleTitle;
  const EditArticleScreen({super.key, required this.articleId, required this.articleTitle});

  @override
  State<EditArticleScreen> createState() => _EditArticleScreenState();
}

class _EditArticleScreenState extends State<EditArticleScreen> {
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  bool isLoading = true;
  bool isSaving = false;
  bool isPreview = false;
  String errorMsg = '';

  @override
  void initState() {
    super.initState();
    titleCtrl.text = widget.articleTitle;
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { isLoading = true; errorMsg = ''; });
    try {
      final base = dotenv.get('API_HOST');
      final res = await http.get(Uri.parse('$base/app/articles/detail.php?id=${widget.articleId}'));
      final data = json.decode(res.body);
      if (data['status'] == 'success' && data['data'] != null) {
        setState(() {
          titleCtrl.text = data['data']['title'] ?? widget.articleTitle;
          contentCtrl.text = data['data']['content'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() { errorMsg = 'المقال غير موجود'; isLoading = false; });
      }
    } catch (e) {
      setState(() { errorMsg = e.toString(); isLoading = false; });
    }
  }

  Future<void> _save() async {
    if (titleCtrl.text.trim().isEmpty || contentCtrl.text.trim().isEmpty) return;
    setState(() => isSaving = true);
    try {
      await AdminApi.post('/admin/articles/update.php', {
        'id': widget.articleId,
        'title': titleCtrl.text.trim(),
        'content': contentCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ التعديلات'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.articleTitle),
        actions: [
          IconButton(
            icon: Icon(isPreview ? Icons.edit : Icons.preview),
            onPressed: () => setState(() => isPreview = !isPreview),
          ),
          IconButton(
            icon: isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save),
            onPressed: isSaving ? null : _save,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : errorMsg.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(errorMsg, style: const TextStyle(color: AppTheme.accent)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _fetch, child: const Text('إعادة المحاولة')),
                    ],
                  ),
                )
              : isPreview
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: MarkdownBody(data: contentCtrl.text, selectable: true),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: titleCtrl,
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(labelText: 'العنوان'),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: contentCtrl,
                            maxLines: null,
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(labelText: 'المحتوى', alignLabelWithHint: true),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
