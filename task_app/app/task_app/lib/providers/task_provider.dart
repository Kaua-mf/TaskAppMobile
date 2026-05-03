import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../database/database_helper.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;

  List<Task> get importantTasks =>
      _tasks.where((t) => t.important).toList();

  List<Task> get completedTasks =>
      _tasks.where((t) => t.completed).toList();

  List<Task> get pendingTasks =>
      _tasks.where((t) => !t.completed).toList();

  List<Task> get lateTasks =>
      _tasks.where((t) => t.isLate).toList();

  Task? get nextUpcomingTask {
    final pending = _tasks
        .where((t) => !t.completed)
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return pending.isNotEmpty ? pending.first : null;
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await DatabaseHelper.instance.getAllTasks();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    final id = await DatabaseHelper.instance.insertTask(task);
    _tasks.add(task.copyWith(id: id));
    _sortTasks();
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await DatabaseHelper.instance.updateTask(task);
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      _tasks[idx] = task;
      _sortTasks();
    }
    notifyListeners();
  }

  Future<void> deleteTask(int id) async {
    await DatabaseHelper.instance.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> toggleCompleted(Task task) async {
    await updateTask(task.copyWith(completed: !task.completed));
  }

  void _sortTasks() {
    _tasks.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }
}
