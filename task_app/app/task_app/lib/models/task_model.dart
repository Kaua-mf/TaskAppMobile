class Task {
  int? id;
  String title;
  String description;
  String scheduledDate;
  bool important;
  bool completed;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.scheduledDate,
    this.important = false,
    this.completed = false,
  });
}
