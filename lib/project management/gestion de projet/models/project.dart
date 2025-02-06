import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/Employee%20Management/Employees.dart';
import 'package:mobile_app/project%20management/gestion%20de%20projet/models/task.dart';

class Project {
  String id;
  String title;
  DateTime startDate;
  DateTime endDate;
  double progress;
  bool isCompleted;
  List<Employee> employees;
  List<Task> tasks;

  Project({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.progress,
    required this.isCompleted,
    required this.employees,
    required this.tasks,
  });

  factory Project.fromMap(Map<String, dynamic> map, String id) {
    return Project(
      id: id,
      title: map['title'] ?? '',
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      progress: (map['progress'] ?? 0.0).toDouble(),
      isCompleted: map['isCompleted'] ?? false,
      employees: (map['employees'] as List<dynamic>?)?.map((e) {
            var empData = e as Map<String, dynamic>;
            return Employee.fromMap(empData, empData['id'] ?? '');
          }).toList() ??
          [],
      tasks: (map['tasks'] as List<dynamic>?)?.map((t) {
            var taskData = t as Map<String, dynamic>;
            return Task.fromMap(taskData, taskData['id'] ?? '');
          }).toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate,
      'endDate': endDate,
      'progress': progress,
      'isCompleted': isCompleted,
      'employees': employees.map((e) => e.toMap()).toList(),
      'tasks': tasks.map((t) => t.toMap()).toList(),
    };
  }
}

class ProjectRepository {
  static final ProjectRepository _instance = ProjectRepository._internal();
  factory ProjectRepository() => _instance;

  List<Project> projects = [];

  ProjectRepository._internal();
}

final projectRepository = ProjectRepository();
