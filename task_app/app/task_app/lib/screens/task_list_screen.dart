import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../widgets/custom_button.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minhas Tarefas',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.task_alt_rounded, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Nenhuma tarefa cadastrada.',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  CustomButton(
                    label: 'Nova Tarefa',
                    icon: Icons.add,
                    onPressed: () => Navigator.pushNamed(context, '/task-form'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadTasks,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: provider.tasks.length,
              itemBuilder: (context, index) {
                final task = provider.tasks[index];
                return _TaskListItem(
                  task: task,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/task-detail',
                    arguments: task,
                  ),
                  onDelete: () {
                    if (task.id != null) provider.deleteTask(task.id!);
                  },
                  onToggleImportant: () => provider.updateTask(
                    task.copyWith(important: !task.important),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/task-form'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova Tarefa'),
      ),
    );
  }
}

class _TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleImportant;

  const _TaskListItem({
    required this.task,
    required this.onTap,
    required this.onDelete,
    required this.onToggleImportant,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          task.completed
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: task.completed ? Colors.green : colorScheme.primary,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration:
                task.completed ? TextDecoration.lineThrough : null,
            color: task.completed
                ? colorScheme.onSurface.withOpacity(0.45)
                : null,
          ),
        ),
        subtitle: Text(
          '${task.category} · ${task.scheduledDate}',
          style: TextStyle(
            color: task.isLate && !task.completed
                ? Colors.red.shade400
                : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                task.important ? Icons.star_rounded : Icons.star_border_rounded,
                color: task.important ? Colors.amber.shade600 : Colors.grey,
              ),
              onPressed: onToggleImportant,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
