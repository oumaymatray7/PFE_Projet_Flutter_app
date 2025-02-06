import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/project%20management/gestion%20de%20projet/models/project.dart';
import 'package:mobile_app/project%20management/gestion%20de%20projet/models/task.dart';
import 'package:mobile_app/services/projectMnagementService/project_mangementService.dart';

class EditProjectScreen extends StatefulWidget {
  final Project project;

  EditProjectScreen({Key? key, required this.project}) : super(key: key);

  @override
  _EditProjectScreenState createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProjectManagementService _projectService = ProjectManagementService();
  late TextEditingController _titleController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project.title);
    _startDateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(widget.project.startDate));
    _endDateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(widget.project.endDate));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _saveProject() async {
    if (_formKey.currentState!.validate()) {
      widget.project.title = _titleController.text;
      widget.project.startDate = DateTime.parse(_startDateController.text);
      widget.project.endDate = DateTime.parse(_endDateController.text);

      try {
        await _projectService.updateProject(widget.project);
        Navigator.pop(context, widget.project);
      } catch (e) {
        print('Error updating project: $e');
      }
    }
  }

  void _editTask(BuildContext context, Task task) {
    TextEditingController nameController =
        TextEditingController(text: task.name);
    TextEditingController dueDateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(task.dueDate));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Task Name'),
                ),
                GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: task.dueDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null && picked != task.dueDate) {
                      dueDateController.text =
                          DateFormat('yyyy-MM-dd').format(picked);
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: dueDateController,
                      decoration: InputDecoration(
                        labelText: 'Due Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final updatedTask = Task(
                  id: task.id,
                  name: nameController.text,
                  assignedTo: task.assignedTo,
                  dueDate: DateTime.parse(dueDateController.text),
                  isCompleted: task.isCompleted,
                  subtasks: task.subtasks,
                );
                await _projectService.updateTask(
                    widget.project.id, updatedTask);
                setState(() {
                  int index =
                      widget.project.tasks.indexWhere((t) => t.id == task.id);
                  if (index != -1) {
                    widget.project.tasks[index] = updatedTask;
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffC5A5FE),
      appBar: AppBar(
        backgroundColor: Color(0xffC5A5FE),
        title: Text('Edit Project'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProject,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Project Title'),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter some text';
                return null;
              },
            ),
            TextFormField(
              controller: _startDateController,
              decoration: InputDecoration(labelText: 'Start Date'),
            ),
            TextFormField(
              controller: _endDateController,
              decoration: InputDecoration(labelText: 'End Date'),
            ),
            SizedBox(height: 20),
            Text('Project Tasks', style: Theme.of(context).textTheme.headline6),
            ...widget.project.tasks.map((task) => ListTile(
                  title: Text(task.name),
                  subtitle: Text(
                      'Due on ${DateFormat('yyyy-MM-dd').format(task.dueDate)}'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editTask(context, task),
                  ),
                )),
            ElevatedButton(
              onPressed: () => _addNewTask(context),
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewTask(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController dueDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Task Name'),
              ),
              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    dueDateController.text =
                        DateFormat('yyyy-MM-dd').format(picked);
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: dueDateController,
                    decoration: InputDecoration(
                      labelText: 'Due Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    dueDateController.text.isNotEmpty) {
                  // Generate a new ID for the task
                  String taskId = _projectService.generateTaskId();
                  Task newTask = Task(
                    id: taskId,
                    name: nameController.text,
                    assignedTo: '',
                    dueDate: DateTime.parse(dueDateController.text),
                    isCompleted: false,
                    subtasks: [],
                  );
                  await _projectService.addTask(widget.project.id, newTask);
                  setState(() {
                    widget.project.tasks.add(newTask);
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
