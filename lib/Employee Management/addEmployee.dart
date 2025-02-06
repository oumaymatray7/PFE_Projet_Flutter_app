import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/services/Service%20Employe/GestionEmployeService.dart';
import 'package:mobile_app/compteUser/model.dart';
import 'dart:io';

class AddEmployeeScreen extends StatefulWidget {
  @override
  _AddEmployeeScreenState createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  String? selectedRole;
  String? selectedLanguage;
  final List<String> roles = ['Admin', 'User', 'Viewer'];
  final List<String> languages = ['English', 'French', 'Spanish'];

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController jobTitleController = TextEditingController();

  final GestionEmployeService _employeeService = GestionEmployeService();
  final ImagePicker _picker = ImagePicker();
  File? _image;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    countryController.dispose();
    phoneNumberController.dispose();
    jobTitleController.dispose();
    super.dispose();
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

  // Inside the _submitForm() method of AddEmployeeScreen

  void _submitForm() async {
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        countryController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        jobTitleController.text.isEmpty ||
        selectedRole == null ||
        selectedLanguage == null ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please fill all the fields and upload an image')),
      );
      return;
    }

    try {
      // Upload image and get URL
      String imageUrl = await _uploadImage(_image!);

      // Create employee data
      Map<String, dynamic> employeeData = {
        'name': usernameController.text,
        'email': emailController.text,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'country': countryController.text,
        'phoneNumber': phoneNumberController.text,
        'jobTitle': jobTitleController.text,
        'role': selectedRole,
        'language': selectedLanguage,
        'imagePath': imageUrl,
        'password': 'isima1234', // Default password
      };

      // Add employee data to Firestore
      await _employeeService.addEmployee(employeeData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Employee added successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add employee: $e')),
      );
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
              _buildTextField('Username', usernameController),
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
                child: Image.asset('assets/Uemployee.png'),
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
        onPressed: _submitForm,
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
              'SUBMIT',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
