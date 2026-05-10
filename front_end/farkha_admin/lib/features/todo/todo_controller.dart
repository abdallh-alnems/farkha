import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoItem {
  final String id;
  String title;
  bool isDone;
  final DateTime createdAt;

  TodoItem({
    required this.id,
    required this.title,
    this.isDone = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isDone': isDone,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        id: json['id'] as String,
        title: json['title'] as String,
        isDone: json['isDone'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class TodoController extends GetxController {
  static const _key = 'admin_todo_list';
  final todos = <TodoItem>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    isLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      todos.value = list.map((e) => TodoItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    isLoading.value = false;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(todos.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  Future<void> addTodo(String title) async {
    final item = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
    );
    todos.insert(0, item);
    await _save();
  }

  Future<void> toggleDone(String id) async {
    final index = todos.indexWhere((e) => e.id == id);
    if (index != -1) {
      todos[index].isDone = !todos[index].isDone;
      todos.refresh();
      await _save();
    }
  }

  Future<void> deleteTodo(String id) async {
    todos.removeWhere((e) => e.id == id);
    await _save();
  }

  Future<void> updateTodo(String id, String title) async {
    final index = todos.indexWhere((e) => e.id == id);
    if (index != -1) {
      todos[index].title = title;
      todos.refresh();
      await _save();
    }
  }
}
