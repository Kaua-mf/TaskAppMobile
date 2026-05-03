import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/category_badge.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          final nextTask = provider.nextUpcomingTask;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.surface,
                  colorScheme.secondaryContainer.withOpacity(0.4),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.08),

                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 28),

                    Text(
                      'Bem-vindo!',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Organize suas tarefas e\nalcance seus objetivos.',
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurface.withOpacity(0.6),
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: size.height * 0.06),

                    if (nextTask != null) ...[
                      Text(
                        'PRÓXIMA TAREFA',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _NextTaskCard(task: nextTask),
                    ] else if (!provider.isLoading) ...[
                      _EmptyNextTask(),
                    ],

                    const Spacer(),

                    if (provider.tasks.isNotEmpty)
                      _StatsRow(provider: provider),

                    const SizedBox(height: 24),

                    CustomButton(
                      label: 'Ver Minhas Tarefas',
                      icon: Icons.list_alt_rounded,
                      width: double.infinity,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/tasks'),
                    ),

                    const SizedBox(height: 14),

                    CustomButton(
                      label: 'Nova Tarefa',
                      icon: Icons.add_rounded,
                      width: double.infinity,
                      isOutlined: true,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/task-form'),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NextTaskCard extends StatelessWidget {
  final Task task;
  const _NextTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final scheduledDt = DateTime.parse(task.scheduledDate);
    final formattedDate = DateFormat('dd/MM/yyyy').format(scheduledDt);

    final daysLeft = scheduledDt
        .difference(DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day))
        .inDays;

    final String daysText;
    if (daysLeft < 0) {
      daysText = '${daysLeft.abs()} dia(s) atrasada';
    } else if (daysLeft == 0) {
      daysText = 'Vence hoje!';
    } else {
      daysText = 'Vence em $daysLeft dia(s)';
    }

    final bool isUrgent = daysLeft <= 1;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUrgent
              ? Colors.orange.shade300
              : colorScheme.outline.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isUrgent ? Colors.orange : colorScheme.primary)
                .withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (task.important)
                Icon(Icons.star_rounded,
                    color: Colors.amber.shade600, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CategoryBadge(category: task.category, small: true),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isUrgent
                      ? Colors.orange.shade50
                      : colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isUrgent
                          ? Icons.warning_amber_rounded
                          : Icons.calendar_today_rounded,
                      size: 13,
                      color: isUrgent
                          ? Colors.orange.shade700
                          : colorScheme.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      daysText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isUrgent
                            ? Colors.orange.shade700
                            : colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_month_rounded,
                  size: 14,
                  color: colorScheme.onSurface.withOpacity(0.45)),
              const SizedBox(width: 5),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withOpacity(0.55),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyNextTask extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: colorScheme.outline.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.inbox_rounded,
              color: colorScheme.onSurface.withOpacity(0.35), size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Nenhuma tarefa pendente.\nCrie uma nova tarefa!',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.5),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final TaskProvider provider;
  const _StatsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        _StatItem(
          label: 'Total',
          value: provider.tasks.length,
          color: colorScheme.primary,
          icon: Icons.list_rounded,
        ),
        const SizedBox(width: 10),
        _StatItem(
          label: 'Concluídas',
          value: provider.completedTasks.length,
          color: Colors.green.shade500,
          icon: Icons.check_rounded,
        ),
        const SizedBox(width: 10),
        _StatItem(
          label: 'Atrasadas',
          value: provider.lateTasks.length,
          color: Colors.red.shade400,
          icon: Icons.warning_rounded,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              '$value',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: color),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurface.withOpacity(0.55),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
