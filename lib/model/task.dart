class Task {
  int? id;
  String title;
  String description;
  bool completed;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.completed = false,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'completed': completed ? 1 : 0,
  };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'],
    title: map['title'],
    description: map['description'],
    completed: map['completed'] == 1,
  );
}
