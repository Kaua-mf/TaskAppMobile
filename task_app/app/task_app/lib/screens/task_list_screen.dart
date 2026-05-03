import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<Task> _tasks = [
    Task(
      id: 1,
      title: 'Estudar Flutter',
      description: 'Revisar widgets e navegação',
      scheduledDate: '2025-05-10',
    ),
    Task(
      id: 2,
      title: 'Fazer compras',
      description: 'Supermercado da semana',
      scheduledDate: '2025-05-08',
      important: true,
    ),
  ];

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _toggleCompleted(int index) {
    setState(() {
      _tasks[index].completed = !_tasks[index].completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minhas Tarefas',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: _tasks.isEmpty
          ? const Center(child: Text('Nenhuma tarefa cadastrada.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Checkbox(
                      value: task.completed,
                      onChanged: (_) => _toggleCompleted(index),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text(task.scheduledDate),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (task.important)
                          Icon(Icons.star_rounded,
                              color: Colors.amber.shade600),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteTask(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.pushNamed(context, '/task-form');
          if (newTask is Task) {
            setState(() {
              _tasks.add(newTask.copyWith(id: _tasks.length + 1));
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

extension TaskCopy on Task {
  Task copyWith({int? id}) {
    return Task(
      id: id ?? this.id,
      title: title,
      description: description,
      scheduledDate: scheduledDate,
      important: important,
      completed: completed,
    );
  }
}
