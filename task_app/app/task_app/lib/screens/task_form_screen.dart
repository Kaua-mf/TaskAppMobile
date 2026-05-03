import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../widgets/custom_button.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  bool _important = false;
  String _category = 'Geral';
  bool _isSaving = false;
  bool _isEditMode = false;
  Task? _editTask;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Task && _editTask == null) {
      _editTask = args;
      _isEditMode = true;
      _titleController.text = args.title;
      _descriptionController.text = args.description;
      _selectedDate = DateTime.parse(args.scheduledDate);
      _important = args.important;
      _category = args.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Selecione a data prevista',
      confirmText: 'Confirmar',
      cancelText: 'Cancelar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, selecione uma data.'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final provider = context.read<TaskProvider>();
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    try {
      if (_isEditMode && _editTask != null) {
        await provider.updateTask(
          _editTask!.copyWith(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            scheduledDate: dateStr,
            important: _important,
            category: _category,
          ),
        );
        if (mounted) {
          _showSuccessSnack('Tarefa atualizada!');
          Navigator.pop(context);
        }
      } else {
        await provider.addTask(Task(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          scheduledDate: dateStr,
          important: _important,
          category: _category,
        ));
        if (mounted) {
          _showSuccessSnack('Tarefa criada!');
          Navigator.pop(context);
        }
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSuccessSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded,
              color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(msg),
        ]),
        backgroundColor: Colors.green.shade500,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formattedDate = _selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Editar Tarefa' : 'Nova Tarefa',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _FieldLabel(label: 'Título *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration(
                context,
                hint: 'Ex: Estudar Flutter',
                icon: Icons.title_rounded,
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'O título é obrigatório.';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            _FieldLabel(label: 'Descrição'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: _inputDecoration(
                context,
                hint: 'Descreva os detalhes da tarefa...',
                icon: Icons.description_rounded,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 20),

            _FieldLabel(label: 'Data Prevista *'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 15),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedDate != null
                        ? colorScheme.primary.withOpacity(0.5)
                        : colorScheme.outline.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 20,
                      color: _selectedDate != null
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      formattedDate ?? 'Selecionar data',
                      style: TextStyle(
                        fontSize: 15,
                        color: formattedDate != null
                            ? colorScheme.onSurface
                            : colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurface.withOpacity(0.35),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            _FieldLabel(label: 'Categoria'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: colorScheme.outline.withOpacity(0.4), width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _category,
                  isExpanded: true,
                  icon: const Icon(Icons.expand_more_rounded),
                  items: Task.categories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Row(
                              children: [
                                Icon(_categoryIcon(cat), size: 18,
                                    color: colorScheme.primary),
                                const SizedBox(width: 10),
                                Text(cat),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _category = v);
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            _SwitchTile(
              icon: Icons.star_rounded,
              iconColor: Colors.amber.shade600,
              label: 'Tarefa Importante',
              subtitle: 'Destacar esta tarefa na lista',
              value: _important,
              onChanged: (v) => setState(() => _important = v),
            ),

            if (_isEditMode) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 18,
                        color: colorScheme.secondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Para marcar como realizada, acesse a tela de detalhes.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            CustomButton(
              label: _isEditMode ? 'Salvar Alterações' : 'Criar Tarefa',
              icon: _isEditMode ? Icons.save_rounded : Icons.add_circle_outline_rounded,
              width: double.infinity,
              isLoading: _isSaving,
              onPressed: _save,
            ),

            const SizedBox(height: 14),

            CustomButton(
              label: 'Cancelar',
              width: double.infinity,
              isOutlined: true,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: colorScheme.surfaceVariant.withOpacity(0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Trabalho':
        return Icons.work_rounded;
      case 'Pessoal':
        return Icons.person_rounded;
      case 'Estudos':
        return Icons.school_rounded;
      case 'Saúde':
        return Icons.favorite_rounded;
      case 'Finanças':
        return Icons.attach_money_rounded;
      default:
        return Icons.label_rounded;
    }
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
        letterSpacing: 0.3,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: value
            ? iconColor.withOpacity(0.06)
            : colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? iconColor.withOpacity(0.25) : colorScheme.outline.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: value ? iconColor : colorScheme.onSurface.withOpacity(0.4)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        onChanged: onChanged,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
