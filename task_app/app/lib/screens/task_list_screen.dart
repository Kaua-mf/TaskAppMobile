import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../widgets/task_card.dart';
import '../widgets/custom_button.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  static const _tabs = [
    ('Todas', Icons.list_alt_rounded),
    ('Importantes', Icons.star_rounded),
    ('Concluídas', Icons.check_circle_rounded),
    ('Pendentes', Icons.pending_rounded),
    ('Atrasadas', Icons.warning_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Minhas Tarefas',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.home_rounded),
              tooltip: 'Início',
              onPressed: () => Navigator.pushNamed(context, '/welcome'),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            tabs: _tabs
                .map((t) => Tab(
                      child: Row(
                        children: [
                          Icon(t.$2, size: 16),
                          const SizedBox(width: 6),
                          Text(t.$1),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        body: Consumer<TaskProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              children: [
                _TaskTabView(tasks: provider.tasks, provider: provider),
                _TaskTabView(
                    tasks: provider.importantTasks, provider: provider),
                _TaskTabView(
                    tasks: provider.completedTasks, provider: provider),
                _TaskTabView(tasks: provider.pendingTasks, provider: provider),
                _TaskTabView(tasks: provider.lateTasks, provider: provider),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () =>
              Navigator.pushNamed(context, '/task-form'),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Nova Tarefa',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _TaskTabView extends StatelessWidget {
  final List<Task> tasks;
  final TaskProvider provider;

  const _TaskTabView({required this.tasks, required this.provider});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      onRefresh: provider.loadTasks,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 80),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(
            task: task,
            onTap: () {
              Navigator.pushNamed(context, '/task-detail', arguments: task);
            },
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
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_alt_rounded,
                size: 56,
                color: colorScheme.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma tarefa aqui',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione novas tarefas clicando\nno botão abaixo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.55), height: 1.5),
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Nova Tarefa',
              icon: Icons.add_rounded,
              onPressed: () => Navigator.pushNamed(context, '/task-form'),
            ),
          ],
        ),
      ),
    );
  }
}
