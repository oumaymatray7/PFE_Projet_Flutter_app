import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/Employee%20Management/Employees.dart';
import 'package:mobile_app/project%20management/gestion%20de%20projet/models/project.dart';
import 'package:mobile_app/project%20management/gestion%20de%20projet/models/task.dart';
import 'package:mobile_app/services/projectMnagementService/project_mangementService.dart';

class AddProjectPage extends StatefulWidget {
  @override
  _AddProjectPageState createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  DateTime? _startDate, _endDate;
  List<Employee> _selectedEmployees = [];
  Employee? _selectedEmployee;
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskDueDateController = TextEditingController();
  List<Task> _tasks = [];
  final ProjectManagementService _projectService = ProjectManagementService();
  List<Employee>? _employees;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    try {
      List<Employee> fetchedEmployees =
          await _projectService.fetchAllEmployees();
      setState(() {
        _employees = fetchedEmployees;
      });
    } catch (e) {
      print('Error fetching employees: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Project', style: GoogleFonts.roboto()),
        backgroundColor: Color(0xFF6D42CE),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Project Title',
                  icon: Icon(Icons.title),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter project title' : null,
                onSaved: (value) => _title = value,
              ),
              TextFormField(
                controller: _startDateController,
                decoration: InputDecoration(
                  labelText: 'Start Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context, true),
              ),
              TextFormField(
                controller: _endDateController,
                decoration: InputDecoration(
                  labelText: 'End Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context, false),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('Add Employees'),
                onPressed: _showEmployeePicker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffC5A5FE),
                  shadowColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.add_task),
                label: Text('Add Task'),
                onPressed: () => _showTaskDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffC5A5FE),
                  shadowColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('Create Project'),
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffC5A5FE),
                  shadowColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isStart ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          _endDate = picked;
          _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Project newProject = Project(
        id: '',
        title: _title!,
        startDate: _startDate!,
        endDate: _endDate!,
        employees: _selectedEmployees,
        tasks: _tasks,
        isCompleted: false,
        progress: 0.0,
      );

      try {
        await _projectService.addProject(newProject);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Project successfully added!'),
        ));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error adding project: $e'),
        ));
      }
    }
  }

  void _showEmployeePicker() {
    List<Employee> localSelectedEmployees =
        List<Employee>.from(_selectedEmployees);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Employees'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
              if (_employees == null) {
                return Center(child: CircularProgressIndicator());
              } else {
                return Container(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _employees!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return CheckboxListTile(
                        title: Text(_employees![index].name),
                        subtitle: Text(_employees![index].jobTitle),
                        secondary: CircleAvatar(
                          backgroundImage:
                              AssetImage(_employees![index].imagePath),
                        ),
                        value:
                            localSelectedEmployees.contains(_employees![index]),
                        onChanged: (bool? value) {
                          setStateDialog(() {
                            if (value!) {
                              localSelectedEmployees.add(_employees![index]);
                            } else {
                              localSelectedEmployees.remove(_employees![index]);
                            }
                          });
                        },
                      );
                    },
                  ),
                );
              }
            },
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                setState(() {
                  _selectedEmployees = localSelectedEmployees;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _taskNameController,
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
                    if (picked != null && picked != DateTime.now()) {
                      _taskDueDateController.text =
                          DateFormat('yyyy-MM-dd').format(picked);
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _taskDueDateController,
                      decoration: InputDecoration(
                        labelText: 'Due Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),
                DropdownButton<Employee>(
                  value: _selectedEmployee,
                  hint: Text('Assign to'),
                  onChanged: (Employee? newValue) {
                    setState(() {
                      _selectedEmployee = newValue;
                    });
                  },
                  items: _selectedEmployees
                      .map<DropdownMenuItem<Employee>>((Employee employee) {
                    return DropdownMenuItem<Employee>(
                      value: employee,
                      child: Text(employee.name),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add Task'),
              onPressed: () {
                if (_taskNameController.text.isNotEmpty &&
                    _taskDueDateController.text.isNotEmpty &&
                    _selectedEmployee != null) {
                  Task newTask = Task(
                    id: '',
                    name: _taskNameController.text,
                    assignedTo: _selectedEmployee!.id,
                    dueDate: DateTime.parse(_taskDueDateController.text),
                    isCompleted: false,
                    subtasks: [],
                  );
                  setState(() {
                    _tasks.add(newTask);
                    _taskNameController.clear();
                    _taskDueDateController.clear();
                    _selectedEmployee = null;
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
