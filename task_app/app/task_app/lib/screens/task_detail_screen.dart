import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/category_badge.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskArg = ModalRoute.of(context)!.settings.arguments as Task;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final task = provider.tasks.firstWhere(
          (t) => t.id == taskArg.id,
          orElse: () => taskArg,
        );

        final scheduledDt = DateTime.parse(task.scheduledDate);
        final formattedDate = DateFormat('dd/MM/yyyy').format(scheduledDt);

        return Scaffold(
          appBar: AppBar(
            title:
                const Text('Detalhes', style: TextStyle(fontWeight: FontWeight.w700)),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                tooltip: 'Editar',
                onPressed: () {
                  Navigator.pushNamed(context, '/task-form', arguments: task);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    color: Colors.red.shade400),
                tooltip: 'Excluir',
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: const Text('Excluir tarefa'),
                      content:
                          Text('Deseja excluir "${task.title}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.red.shade400),
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
                _StatusBanner(task: task),
                const SizedBox(height: 20),

                _DetailCard(
                  children: [
                    _DetailRow(
                      icon: Icons.tag_rounded,
                      label: 'ID',
                      value: '#${task.id ?? '-'}',
                      valueStyle: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    const Divider(height: 1),
                    _DetailRow(
                      icon: Icons.title_rounded,
                      label: 'Título',
                      value: task.title,
                    ),
                    const Divider(height: 1),
                    _DetailRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Data Prevista',
                      value: formattedDate,
                      valueStyle: TextStyle(
                        color: task.isLate
                            ? Colors.red.shade500
                            : colorScheme.onSurface,
                        fontWeight: task.isLate
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                    const Divider(height: 1),
                    _DetailRowWidget(
                      icon: Icons.label_rounded,
                      label: 'Categoria',
                      child: CategoryBadge(category: task.category),
                    ),
                    const Divider(height: 1),
                    _DetailRow(
                      icon: Icons.star_rounded,
                      label: 'Importante',
                      value: task.important ? 'Sim' : 'Não',
                      iconColor:
                          task.important ? Colors.amber.shade600 : null,
                    ),
                    const Divider(height: 1),
                    _DetailRow(
                      icon: Icons.check_circle_rounded,
                      label: 'Realizada',
                      value: task.completed ? 'Sim' : 'Não',
                      iconColor: task.completed
                          ? Colors.green.shade500
                          : null,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _SectionTitle(label: 'Descrição'),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2)),
                  ),
                  child: Text(
                    task.description.isNotEmpty
                        ? task.description
                        : 'Sem descrição.',
                    style: TextStyle(
                      fontSize: 15,
                      color: task.description.isNotEmpty
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withOpacity(0.4),
                      height: 1.6,
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

                const SizedBox(height: 14),

                CustomButton(
                  label: 'Editar Tarefa',
                  icon: Icons.edit_rounded,
                  width: double.infinity,
                  isOutlined: true,
                  onPressed: () =>
                      Navigator.pushNamed(context, '/task-form', arguments: task),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final Task task;
  const _StatusBanner({required this.task});

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color fgColor;
    final IconData icon;
    final String text;

    if (task.completed) {
      bgColor = Colors.green.shade50;
      fgColor = Colors.green.shade700;
      icon = Icons.check_circle_rounded;
      text = 'Tarefa Concluída';
    } else if (task.isLate) {
      bgColor = Colors.red.shade50;
      fgColor = Colors.red.shade700;
      icon = Icons.warning_rounded;
      text = 'Tarefa Atrasada';
    } else {
      bgColor = Theme.of(context).colorScheme.primaryContainer;
      fgColor = Theme.of(context).colorScheme.primary;
      icon = Icons.pending_rounded;
      text = 'Tarefa Pendente';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: fgColor, size: 22),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: fgColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          if (task.important) ...[
            const Spacer(),
            Icon(Icons.star_rounded,
                color: Colors.amber.shade600, size: 20),
            const SizedBox(width: 4),
            Text('Importante',
                style: TextStyle(
                    color: Colors.amber.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;
  final Color? iconColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: iconColor ?? colorScheme.onSurface.withOpacity(0.45)),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withOpacity(0.6))),
          const Spacer(),
          Text(
            value,
            style: valueStyle ??
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _DetailRowWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _DetailRowWidget({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: colorScheme.onSurface.withOpacity(0.45)),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withOpacity(0.6))),
          const Spacer(),
          child,
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
