import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/Employee%20Management/Employees.dart';
import 'package:mobile_app/project%20management/gestion%20de%20projet/addproject.dart';
import 'package:mobile_app/project%20management/gestion%20de%20projet/editproject.dart';
import 'package:mobile_app/project%20management/gestion%20de%20projet/models/project.dart';
import 'package:mobile_app/project%20management/gestion%20de%20projet/project.dart';
import 'package:mobile_app/services/projectMnagementService/project_mangementService.dart';
import 'package:intl/intl.dart';

class ProjectManagementDetails extends StatefulWidget {
  @override
  _ProjectManagementDetailsState createState() =>
      _ProjectManagementDetailsState();
}

class _ProjectManagementDetailsState extends State<ProjectManagementDetails> {
  final ProjectManagementService _projectService = ProjectManagementService();
  bool isAdmin = true;
  Employee? currentUser;
  bool isLoading = true;
  List<Project> projects = [];

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    setState(() => isLoading = true);
    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      print('Firebase user: ${firebaseUser?.uid}'); // Debug print

      if (firebaseUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('employees')
            .doc(firebaseUser.uid)
            .get();
        print('User document exists: ${userDoc.exists}'); // Debug print

        if (userDoc.exists) {
          currentUser = Employee.fromMap(
              userDoc.data() as Map<String, dynamic>, firebaseUser.uid);
          print('Current user: ${currentUser?.name}'); // Debug print
          _fetchProjects();
        } else {
          print('No user document found in Firestore'); // Debug print
        }
      } else {
        print('No Firebase user found'); // Debug print
      }
    } catch (e) {
      print('Error fetching user: $e'); // Debug print
    }
    setState(() => isLoading = false);
  }

  Future<void> _fetchProjects() async {
    if (currentUser == null) return;

    setState(() => isLoading = true);
    try {
      if (currentUser!.projectIds.isEmpty) {
        print('No projects found for the current user'); // Debug print
      } else {
        List<Project> fetchedProjects =
            await _projectService.fetchProjectsByIds(currentUser!.projectIds);
        print(
            'Fetched projects: ${fetchedProjects.map((p) => p.title).toList()}'); // Debug print
        setState(() {
          projects = fetchedProjects;
        });
      }
    } catch (e) {
      print('Error fetching projects: $e'); // Debug print
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Projects', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF6D42CE),
        actions: <Widget>[
          if (isAdmin)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _navigateToAddProject(context),
            ),
        ],
      ),
      body: currentUser == null
          ? Center(child: Text("No user found"))
          : projects.isEmpty
              ? Center(child: Text("No projects found"))
              : ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final Project project = projects[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: buildProjectListTile(project),
                    );
                  },
                ),
    );
  }

  Widget buildProjectListTile(Project project) {
    return ListTile(
      title: Text(project.title),
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ProjectDetailsScreen(project: project),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0), // Right to left
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ));
      },
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              'Start Date: ${DateFormat('yyyy-MM-dd').format(project.startDate)}'),
          Text('End Date: ${DateFormat('yyyy-MM-dd').format(project.endDate)}'),
          LinearProgressIndicator(value: project.progress / 100),
        ],
      ),
      trailing: canModifyProject(project)
          ? Container(width: 100, child: _buildActionButtons(project))
          : null,
    );
  }

  Widget _buildActionButtons(Project project) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit, color: Colors.blue),
          tooltip: 'Edit Project',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditProjectScreen(project: project),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          tooltip: 'Delete Project',
          onPressed: () => _confirmDeletion(project),
        ),
      ],
    );
  }

  void _confirmDeletion(Project project) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete the project: ${project.title}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                try {
                  await _projectService.deleteProject(project.id);
                  setState(() {
                    projects.remove(project);
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error deleting project: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }

  bool canModifyProject(Project project) {
    return currentUser != null;
  }

  void _navigateToAddProject(BuildContext context) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(builder: (context) => AddProjectPage()),
    )
        .then((_) {
      _fetchProjects();
    });
  }
}
