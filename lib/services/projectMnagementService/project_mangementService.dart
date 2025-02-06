import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/Employee%20Management/Employees.dart';
import 'package:mobile_app/project%20management/gestion%20de%20projet/models/project.dart';
import 'package:mobile_app/project%20management/gestion%20de%20projet/models/task.dart';

class ProjectManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addEmployee(Employee employee) async {
    try {
      DocumentReference employeeRef =
          _firestore.collection('employees').doc(employee.id);
      await employeeRef.set(employee.toMap());
    } catch (e) {
      print('Error adding employee: $e');
      throw e;
    }
  }

  Future<List<Project>> fetchAllProjects() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('projects').get();
      return snapshot.docs.map((doc) {
        return Project.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching projects: $e');
      throw e;
    }
  }

  Future<Project> fetchProjectById(String projectId) async {
    DocumentSnapshot snapshot =
        await _firestore.collection('projects').doc(projectId).get();
    return Project.fromMap(
        snapshot.data() as Map<String, dynamic>, snapshot.id);
  }

  Future<void> updateProject(Project project) async {
    await _firestore
        .collection('projects')
        .doc(project.id)
        .update(project.toMap());
  }

  Future<void> deleteProject(String projectId) async {
    await _firestore.collection('projects').doc(projectId).delete();
  }

  Future<void> addTask(String projectId, Task task) async {
    await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(task.id)
        .set(task.toMap());
  }

  Future<List<Task>> fetchAllTasks(String projectId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .get();
    return snapshot.docs
        .map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<Task> fetchTaskById(String projectId, String taskId) async {
    DocumentSnapshot snapshot = await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .get();
    return Task.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id);
  }

  Future<void> updateTask(String projectId, Task task) async {
    if (task.id.isEmpty) {
      throw ArgumentError('Task ID must not be empty');
    }
    await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(task.id)
        .update(task.toMap());
  }

  Future<void> deleteTask(String projectId, String taskId) async {
    await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  Future<List<Employee>> fetchAllEmployees() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('employees').get();
      return querySnapshot.docs.map((doc) {
        return Employee.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching employees: $e');
      throw e;
    }
  }

  Future<List<Project>> fetchProjectsByIds(List<String> projectIds) async {
    try {
      if (projectIds.isEmpty) {
        return [];
      }
      QuerySnapshot snapshot = await _firestore
          .collection('projects')
          .where(FieldPath.documentId, whereIn: projectIds)
          .get();
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            if (data != null) {
              return Project.fromMap(data, doc.id);
            } else {
              print('Null data found for project ID ${doc.id}');
              return null;
            }
          })
          .where((project) => project != null)
          .cast<Project>()
          .toList();
    } catch (e) {
      print('Error fetching projects by IDs: $e');
      throw e;
    }
  }

  Future<void> addProject(Project project) async {
    try {
      DocumentReference projectRef = _firestore.collection('projects').doc();
      project.id = projectRef.id; // Set the project's ID to the document ID
      await projectRef.set(project.toMap());

      // Update each employee document to include this project ID
      for (Employee employee in project.employees) {
        DocumentReference employeeRef =
            _firestore.collection('employees').doc(employee.id);
        await employeeRef.update({
          'projectIds': FieldValue.arrayUnion([project.id])
        });
      }
    } catch (e) {
      print('Error adding project: $e');
      throw e;
    }
  }

  Future<List<Project>> fetchProjectsByEmployee(String employeeId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('projects')
          .where('employees', arrayContains: employeeId)
          .get();
      return snapshot.docs
          .map((doc) =>
              Project.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error fetching projects: $e');
      return [];
    }
  }

  String generateTaskId() {
    return _firestore.collection('projects').doc().id;
  }
}
