import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../widgets/custom_button.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskArg = ModalRoute.of(context)!.settings.arguments as Task;

    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final task = provider.tasks.firstWhere(
          (t) => t.id == taskArg.id,
          orElse: () => taskArg,
        );

        final formattedDate =
            DateFormat('dd/MM/yyyy').format(DateTime.parse(task.scheduledDate));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalhes da Tarefa',
                style: TextStyle(fontWeight: FontWeight.w700)),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/task-form',
                  arguments: task,
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    color: Colors.red.shade400),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Excluir tarefa'),
                      content: Text('Deseja excluir "${task.title}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text('Excluir'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && task.id != null) {
                    await provider.deleteTask(task.id!);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: #${task.id}',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 4),
                Text(task.title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      label: Text(task.category),
                      avatar: const Icon(Icons.label_rounded, size: 16),
                    ),
                    if (task.important)
                      Chip(
                        label: const Text('Importante'),
                        avatar: Icon(Icons.star_rounded,
                            size: 16, color: Colors.amber.shade600),
                        backgroundColor: Colors.amber.shade50,
                      ),
                    Chip(
                      label:
                          Text(task.completed ? 'Concluída' : task.isLate ? 'Atrasada' : 'Pendente'),
                      avatar: Icon(
                        task.completed
                            ? Icons.check_circle
                            : task.isLate
                                ? Icons.warning
                                : Icons.pending,
                        size: 16,
                        color: task.completed
                            ? Colors.green
                            : task.isLate
                                ? Colors.red
                                : Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(children: [
                  const Icon(Icons.calendar_today_rounded, size: 16),
                  const SizedBox(width: 8),
                  Text('Data prevista: $formattedDate',
                      style: TextStyle(
                        color: task.isLate ? Colors.red : null,
                        fontWeight:
                            task.isLate ? FontWeight.w700 : FontWeight.normal,
                      )),
                ]),
                const SizedBox(height: 20),

                const Text('Descrição',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    task.description.isNotEmpty
                        ? task.description
                        : 'Sem descrição.',
                    style: TextStyle(
                      color: task.description.isNotEmpty
                          ? null
                          : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                CustomButton(
                  label: task.completed
                      ? 'Desfazer Realização'
                      : 'Marcar como Realizada',
                  icon: task.completed
                      ? Icons.undo_rounded
                      : Icons.check_circle_outline_rounded,
                  backgroundColor: task.completed
                      ? Colors.grey.shade500
                      : Colors.green.shade500,
                  width: double.infinity,
                  onPressed: () => provider.toggleCompleted(task),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
