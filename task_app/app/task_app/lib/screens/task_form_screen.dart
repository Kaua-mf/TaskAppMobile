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
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) return;
    setState(() => _isSaving = true);

    final provider = context.read<TaskProvider>();
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    try {
      if (_isEditMode && _editTask != null) {
        await provider.updateTask(_editTask!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          scheduledDate: dateStr,
          important: _important,
          category: _category,
        ));
      } else {
        await provider.addTask(Task(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          scheduledDate: dateStr,
          important: _important,
          category: _category,
        ));
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Tarefa' : 'Nova Tarefa',
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Título obrigatório'
                  : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description_rounded),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade400)),
              leading: const Icon(Icons.calendar_month_rounded),
              title: Text(_selectedDate == null
                  ? 'Selecionar data *'
                  : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_rounded),
              ),
              items: Task.categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Tarefa Importante'),
              secondary: Icon(Icons.star_rounded,
                  color:
                      _important ? Colors.amber.shade600 : Colors.grey),
              value: _important,
              onChanged: (v) => setState(() => _important = v),
            ),

            const SizedBox(height: 24),

            CustomButton(
              label: _isEditMode ? 'Salvar Alterações' : 'Criar Tarefa',
              icon: _isEditMode ? Icons.save_rounded : Icons.add_circle_outline_rounded,
              width: double.infinity,
              isLoading: _isSaving,
              onPressed: _save,
            ),
            const SizedBox(height: 12),
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
}
