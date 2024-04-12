class Todo {
  int id;
  String title;
  bool done;

  Todo._({
    required this.id,
    required this.title,
    required this.done,
  });

  factory Todo.build(String title) {
    return Todo._(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      done: false,
    );
  }

  factory Todo.fromJSON(Map<String, dynamic> json) {
    return Todo._(
      id: json['id'],
      title: json['title'],
      done: json['done'],
    );
  }

  Map toJson() => {
    'id': id,
    'title': title,
    'done': done,
  };
}
