import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'todo_controller.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TodoController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة المهام'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        if (controller.todos.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.checklist_rounded, size: 72, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                const SizedBox(height: 16),
                const Text(
                  'لا توجد مهام بعد',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'اضغط + لإضافة مهمة جديدة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        final doneCount = controller.todos.where((e) => e.isDone).length;
        final totalCount = controller.todos.length;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '$doneCount / $totalCount مكتمل',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: totalCount == 0 ? 0 : doneCount / totalCount,
                        backgroundColor: AppTheme.border,
                        color: AppTheme.primary,
                        minHeight: 6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex--;
                  final item = controller.todos.removeAt(oldIndex);
                  controller.todos.insert(newIndex, item);
                },
                itemCount: controller.todos.length,
                itemBuilder: (context, index) {
                  final todo = controller.todos[index];
                  return Dismissible(
                    key: ValueKey(todo.id),
                    direction: DismissDirection.startToEnd,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: AppTheme.accent,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => controller.deleteTodo(todo.id),
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: GestureDetector(
                          onTap: () => controller.toggleDone(todo.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: todo.isDone ? AppTheme.primary : Colors.transparent,
                              border: Border.all(
                                color: todo.isDone ? AppTheme.primary : AppTheme.border,
                                width: 2,
                              ),
                            ),
                            child: todo.isDone
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                        ),
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: todo.isDone ? AppTheme.textSecondary : AppTheme.textPrimary,
                            decoration: todo.isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => _showEditSheet(context, controller, todo),
                        ),
                        onTap: () => controller.toggleDone(todo.id),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, controller),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddDialog(BuildContext context, TodoController controller) {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        title: const Text('مهمة جديدة', style: TextStyle(fontFamily: 'Cairo')),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'أدخل المهمة...',
            prefixIcon: Icon(Icons.checklist_rounded),
          ),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) {
              controller.addTodo(v.trim());
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                controller.addTodo(ctrl.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, TodoController controller, TodoItem todo) {
    final ctrl = TextEditingController(text: todo.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        title: const Text('تعديل المهمة', style: TextStyle(fontFamily: 'Cairo')),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'أدخل المهمة...',
            prefixIcon: Icon(Icons.checklist_rounded),
          ),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) {
              controller.updateTodo(todo.id, v.trim());
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                controller.updateTodo(todo.id, ctrl.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
