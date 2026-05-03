class Task {
  int? id;
  String title;
  String description;
  String scheduledDate; // Armazenada  "yyyy-MM-dd"
  bool important;
  bool completed;
  String category; // Atributo extra: categoria da tarefa

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.scheduledDate,
    this.important = false,
    this.completed = false,
    this.category = 'Geral',
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      scheduledDate: map['scheduledDate'] as String,
      important: (map['important'] as int) == 1,
      completed: (map['completed'] as int) == 1,
      category: map['category'] as String? ?? 'Geral',
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'scheduledDate': scheduledDate,
      'important': important ? 1 : 0,
      'completed': completed ? 1 : 0,
      'category': category,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  bool get isLate {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final scheduled = DateTime.parse(scheduledDate);
    return !completed && scheduled.isBefore(todayDate);
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? scheduledDate,
    bool? important,
    bool? completed,
    String? category,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      important: important ?? this.important,
      completed: completed ?? this.completed,
      category: category ?? this.category,
    );
  }

  static const List<String> categories = [
    'Geral',
    'Trabalho',
    'Pessoal',
    'Estudos',
    'Saúde',
    'Finanças',
  ];
}
