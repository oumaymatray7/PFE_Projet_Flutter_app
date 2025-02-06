import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:mobile_app/Employee%20Management/Employees.dart';
import 'package:mobile_app/services/Service%20Employe/GestionEmployeService.dart';

class UpdateEmployeePage extends StatefulWidget {
  final Employee employee;

  UpdateEmployeePage({required this.employee});

  @override
  _UpdateEmployeePageState createState() => _UpdateEmployeePageState();
}

class _UpdateEmployeePageState extends State<UpdateEmployeePage> {
  final GestionEmployeService _employeeService = GestionEmployeService();
  String? selectedRole;
  String? selectedLanguage;
  final List<String> roles = ['Admin', 'User', 'Viewer'];
  final List<String> languages = ['English', 'French', 'Spanish'];

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController countryController;
  late TextEditingController phoneNumberController;
  late TextEditingController jobTitleController;

  File? _image;
  final ImagePicker _picker = ImagePicker();
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    selectedRole = widget.employee.role;
    selectedLanguage = widget.employee.language;

    nameController = TextEditingController(text: widget.employee.name);
    emailController = TextEditingController(text: widget.employee.email);
    firstNameController =
        TextEditingController(text: widget.employee.firstName);
    lastNameController = TextEditingController(text: widget.employee.lastName);
    countryController = TextEditingController(text: widget.employee.country);
    phoneNumberController =
        TextEditingController(text: widget.employee.phoneNumber);
    jobTitleController = TextEditingController(text: widget.employee.jobTitle);
    imageUrl = widget.employee.imagePath;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('employee_images')
        .child('${emailController.text}.jpg');
    await storageRef.putFile(imageFile);
    return await storageRef.getDownloadURL();
  }

  void _updateEmployee() async {
    try {
      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
      }

      Map<String, dynamic> updatedEmployee = {
        'name': nameController.text,
        'email': emailController.text,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'country': countryController.text,
        'phoneNumber': phoneNumberController.text,
        'jobTitle': jobTitleController.text,
        'role': selectedRole,
        'language': selectedLanguage,
        'imagePath': imageUrl,
      };

      await _employeeService.updateEmployee(
          widget.employee.id, updatedEmployee);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Employee updated successfully')));
      Navigator.of(context).pop(); // Navigate back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update employee: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9155FD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/smartovate.png', height: 100),
              _buildSection('1. Account Details'),
              _buildTextField('Username', nameController),
              _buildTextField('Email', emailController),
              _buildDropdown('Select Role', roles, selectedRole),
              _buildSection('2. Personal Info'),
              _buildTextField('First Name', firstNameController),
              _buildTextField('Last Name', lastNameController),
              _buildTextField('Country', countryController),
              _buildDropdown('Language', languages, selectedLanguage),
              _buildTextField('Phone Number', phoneNumberController),
              _buildTextField('Job Title', jobTitleController),
              _buildImagePicker(),
              _buildSubmitButton(),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomCenter,
                child: Image.network(imageUrl!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          filled: true,
          fillColor: Color(0x40000000),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildDropdown(
      String hintText, List<String> options, String? selectedValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Color(0x40000000),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            hint: Text(selectedValue ?? hintText,
                style: TextStyle(color: Colors.white.withOpacity(0.7))),
            dropdownColor: Color(0xFF6D42CE),
            value: selectedValue,
            icon: Icon(Icons.arrow_drop_down, color: Colors.white),
            isExpanded: true,
            items: options.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                if (hintText == 'Select Role') {
                  selectedRole = newValue;
                } else if (hintText == 'Language') {
                  selectedLanguage = newValue;
                }
              });
            },
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          if (_image != null)
            CircleAvatar(
              backgroundImage: FileImage(_image!),
              radius: 40,
            ),
          SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: Icon(Icons.camera_alt),
            label: Text('Upload Image'),
            style: ElevatedButton.styleFrom(
              shadowColor: Colors.white.withOpacity(0.7),
              backgroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _updateEmployee,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9155FD), Color(0xFFC5A5FE)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(minHeight: 50.0),
            child: const Text(
              'UPDATE',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    countryController.dispose();
    phoneNumberController.dispose();
    jobTitleController.dispose();
    super.dispose();
  }
}
