import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/project%20management/gestion%20de%20projet/editproject.dart';
import 'package:mobile_app/project%20management/gestion%20de%20projet/models/project.dart';
import 'package:mobile_app/project%20management/gestion%20de%20projet/models/task.dart';
import 'package:mobile_app/services/projectMnagementService/project_mangementService.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  ProjectDetailsScreen({Key? key, required this.project}) : super(key: key);

  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final ProjectManagementService _projectService = ProjectManagementService();
  List<Task> _userTasks = [];
  bool _showUserTasks = false;

  String get currentUserRole => "admin"; // Simulate the current user's role

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() async {
    try {
      List<Task> tasks = await _projectService.fetchAllTasks(widget.project.id);
      setState(() {
        widget.project.tasks = tasks;
        _filterUserTasks();
      });
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this project?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProject();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteProject() async {
    try {
      await _projectService.deleteProject(widget.project.id);
      Navigator.of(context).pop();
    } catch (e) {
      print('Error deleting project: $e');
    }
  }

  void _filterUserTasks() {
    setState(() {
      String currentUser = "oumayma"; // Replace with actual current user ID
      _userTasks = widget.project.tasks.where((task) {
        return task.assignedTo == currentUser;
      }).toList();
    });
  }

  void _onMenuSelected(String value) {
    if (currentUserRole == 'admin' && (value == 'Edit' || value == 'Delete')) {
      switch (value) {
        case 'Edit':
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    EditProjectScreen(project: widget.project)),
          );
          break;
        case 'Delete':
          _showDeleteConfirmation();
          break;
      }
    } else if (value == 'My Tasks') {
      setState(() {
        _showUserTasks = true;
        _filterUserTasks();
      });
    }
  }

  void _updateTaskCompletion(Task task, bool isCompleted) async {
    if (task.id.isEmpty) {
      print('Task ID is empty, cannot update task');
      return;
    }

    setState(() {
      final int taskIndex = widget.project.tasks.indexOf(task);
      if (taskIndex != -1) {
        widget.project.tasks[taskIndex] = Task(
          id: task.id,
          name: task.name,
          assignedTo: task.assignedTo,
          dueDate: task.dueDate,
          isCompleted: isCompleted,
          subtasks: task.subtasks,
        );
      }
    });

    try {
      await _projectService.updateTask(widget.project.id, task);
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  double _calculateProgress(List<Task> tasks) {
    if (tasks.isEmpty) return 0.0;
    int completedTasks = tasks.where((task) => task.isCompleted).length;
    return completedTasks / tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    List<Task> tasksToShow = _showUserTasks ? _userTasks : widget.project.tasks;
    double progress = _calculateProgress(tasksToShow) * 100;

    return Scaffold(
      backgroundColor: Color(0xffC5A5FE),
      appBar: AppBar(
        title: Text(widget.project.title,
            style:
                GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xff9155FD),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _onMenuSelected,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              if (currentUserRole == 'admin')
                PopupMenuItem<String>(
                  value: 'Edit',
                  child: Text('Edit'),
                ),
              if (currentUserRole == 'admin')
                PopupMenuItem<String>(
                  value: 'Delete',
                  child: Text('Delete'),
                ),
              PopupMenuItem<String>(
                value: 'My Tasks',
                child: Text('My Tasks'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchTasks();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetailItem(
                icon: Icons.date_range,
                title: 'Start Date',
                subtitle:
                    DateFormat('yyyy-MM-dd').format(widget.project.startDate),
              ),
              DetailItem(
                icon: Icons.date_range,
                title: 'End Date',
                subtitle:
                    DateFormat('yyyy-MM-dd').format(widget.project.endDate),
              ),
              DetailItem(
                icon: Icons.trending_up,
                title: 'Progress',
                subtitle: '${progress.toStringAsFixed(1)}%',
                progress: progress / 100,
              ),
              SizedBox(height: 20),
              Text(
                'Project Tasks',
                style: GoogleFonts.roboto(
                    fontSize: 18, fontWeight: FontWeight.w500),
              ),
              ...tasksToShow
                  .map((task) => TaskItem(
                        task: task,
                        onTaskCompletionChanged: (Task task, bool isCompleted) {
                          _updateTaskCompletion(task, isCompleted);
                        },
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double? progress;

  const DetailItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8),
      leading: Icon(icon, color: Colors.white),
      title: Text(title,
          style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: GoogleFonts.roboto(fontSize: 14)),
      trailing: progress != null
          ? SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              ),
            )
          : null,
    );
  }
}

class TaskItem extends StatefulWidget {
  final Task task;
  final Function(Task task, bool isCompleted) onTaskCompletionChanged;

  const TaskItem({
    Key? key,
    required this.task,
    required this.onTaskCompletionChanged,
  }) : super(key: key);

  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.task.isCompleted;
  }

  void _toggleCompleted(bool newValue) {
    setState(() {
      _isCompleted = newValue;
    });

    widget.onTaskCompletionChanged(widget.task, _isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _toggleCompleted(!_isCompleted),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.name,
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Due by ${DateFormat('yyyy-MM-dd').format(widget.task.dueDate)}',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    if (widget.task.isCompleted) SizedBox(height: 4),
                    if (widget.task.isCompleted)
                      Chip(
                        label: Text('Completed'),
                        backgroundColor: Color(0xff9155FD),
                      ),
                  ],
                ),
              ),
              Switch(
                value: _isCompleted,
                onChanged: _toggleCompleted,
                activeColor: Colors.white,
                activeTrackColor: Color(0xff9155FD),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
