class Task {
  final int? id;
  final String title;
  final String description;
  final double value;
  final int quantity;
  final bool completed;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.value = 0.0,
    this.quantity = 1,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'value': value,
      'quantity': quantity,
      'completed': completed ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      value: map['value'] ?? 0.0,
      quantity: map['quantity'] ?? 1,
      completed: map['completed'] == 1,
    );
  }
}
