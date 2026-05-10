import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/api/admin_api.dart';

class AddArticleScreen extends StatefulWidget {
  const AddArticleScreen({super.key});

  @override
  State<AddArticleScreen> createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends State<AddArticleScreen> {
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  bool isSaving = false;
  bool isPreview = false;

  @override
  void dispose() {
    titleCtrl.dispose();
    contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (titleCtrl.text.trim().isEmpty || contentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل العنوان والمحتوى'), backgroundColor: Colors.red));
      return;
    }
    setState(() => isSaving = true);
    try {
      await AdminApi.post('/admin/articles/add.php', {'title': titleCtrl.text.trim(), 'content': contentCtrl.text.trim()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة المقال'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة مقال'),
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
      body: isPreview
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
