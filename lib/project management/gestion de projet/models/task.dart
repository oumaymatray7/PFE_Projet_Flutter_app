import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String id;
  String name;
  String assignedTo;
  DateTime dueDate;
  bool isCompleted;
  List<SubTask> subtasks;

  Task({
    required this.id,
    required this.name,
    required this.assignedTo,
    required this.dueDate,
    required this.isCompleted,
    required this.subtasks,
  });

  factory Task.fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      name: map['name'] ?? '',
      assignedTo: map['assignedTo'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      isCompleted: map['isCompleted'] ?? false,
      subtasks: (map['subtasks'] as List<dynamic>).map((subtask) {
        var subtaskData = subtask as Map<String, dynamic>;
        return SubTask.fromMap(subtaskData);
      }).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'assignedTo': assignedTo,
      'dueDate': dueDate,
      'isCompleted': isCompleted,
      'subtasks': subtasks.map((subtask) => subtask.toMap()).toList(),
    };
  }
}

class SubTask {
  String id;
  String name;
  bool isCompleted;

  SubTask({
    required this.id,
    required this.name,
    required this.isCompleted,
  });

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isCompleted': isCompleted,
    };
  }
}
