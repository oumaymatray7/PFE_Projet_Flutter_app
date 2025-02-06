import 'package:flutter/material.dart';
import 'package:mobile_app/services/Service Employe/GestionEmployeService.dart';
import 'package:intl/intl.dart';

class AddWorkingHourScreen extends StatefulWidget {
  @override
  _AddWorkingHourScreenState createState() => _AddWorkingHourScreenState();
}

class _AddWorkingHourScreenState extends State<AddWorkingHourScreen> {
  final GestionEmployeService _employeeService = GestionEmployeService();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getDayName(DateTime date) {
    return DateFormat('EEEE').format(date); // Returns the full day name
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      String employeeId = _employeeIdController.text;
      String day = _getDayName(_selectedDate);
      int hours = int.parse(_hoursController.text);

      Map<String, String> workingHourData = {
        'checkIn': '${hours.toString().padLeft(2, '0')}:00',
        'checkOut':
            '${(hours + 8).toString().padLeft(2, '0')}:00', // Assuming an 8-hour workday
      };

      try {
        await _employeeService.addWorkingHour(employeeId, day, workingHourData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Working hour added")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add working hour: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Working Hour")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _employeeIdController,
                decoration: InputDecoration(labelText: "Employee ID"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter Employee ID";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _hoursController,
                decoration: InputDecoration(labelText: "Hours"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter hours";
                  }
                  if (int.tryParse(value) == null) {
                    return "Please enter a valid number";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text(
                    "Select Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text("Add Working Hour"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
