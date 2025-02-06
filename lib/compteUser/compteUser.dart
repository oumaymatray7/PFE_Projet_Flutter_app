import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mobile_app/auth/Security%20Privacy/SecurityPrivacyPage.dart';
import 'dart:io';
import 'package:mobile_app/compteUser/model.dart';
import 'package:mobile_app/homePage.dart';

class UpdateUserInfoScreen extends StatefulWidget {
  final CompteUser user;

  const UpdateUserInfoScreen({Key? key, required this.user}) : super(key: key);

  @override
  _UpdateUserInfoScreenState createState() => _UpdateUserInfoScreenState();
}

class _UpdateUserInfoScreenState extends State<UpdateUserInfoScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController countryController;
  late TextEditingController phoneNumberController;
  late TextEditingController jobTitleController;

  String? selectedRole;
  String? selectedLanguage;
  String imageUrl = '';

  final List<String> roles = ['Admin', 'User', 'Viewer'];
  final List<String> languages = ['English', 'French', 'Spanish'];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    firstNameController = TextEditingController(text: widget.user.firstName);
    lastNameController = TextEditingController(text: widget.user.lastName);
    countryController = TextEditingController(text: widget.user.country);
    phoneNumberController =
        TextEditingController(text: widget.user.phoneNumber);
    jobTitleController = TextEditingController(text: widget.user.jobTitle);
    selectedRole = widget.user.role;
    selectedLanguage = widget.user.language;
    imageUrl = widget.user.imagePath;
  }

  Future<void> _updateUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'name': nameController.text,
        'email': emailController.text,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'country': countryController.text,
        'phoneNumber': phoneNumberController.text,
        'jobTitle': jobTitleController.text,
        'role': selectedRole,
        'language': selectedLanguage,
        'imageUrl': imageUrl,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage()), // Update this to your home page
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${widget.user.uid}.jpg');
      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      setState(() {
        imageUrl = downloadUrl;
      });

      if (widget.user.uid.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.uid)
            .update({'imageUrl': downloadUrl});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF9155FD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Container(
                    height: screenHeight * 0.35,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF9155FD), Color(0xFFC5A5FE)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    top: screenHeight * 0.15,
                    left: screenWidth * 0.35,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: screenWidth * 0.15,
                        backgroundImage:
                            imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                        child: imageUrl.isEmpty
                            ? Icon(Icons.camera_alt,
                                size: screenWidth * 0.1, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              _buildSection('Account Details'),
              _buildTextField('Name', nameController),
              _buildTextField('Email', emailController),
              _buildDropdown('Select Role', roles, selectedRole),
              _buildSection('Personal Info'),
              _buildTextField('First Name', firstNameController),
              _buildTextField('Last Name', lastNameController),
              _buildTextField('Country', countryController),
              _buildDropdown('Language', languages, selectedLanguage),
              _buildTextField('Phone Number', phoneNumberController),
              _buildTextField('Job Title', jobTitleController),
              _buildSubmitButton(),
              _buildSecurityButton(),
              SizedBox(height: 20),
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
            hint: Text(hintText,
                style: TextStyle(color: Colors.white.withOpacity(0.7))),
            dropdownColor: Color(0xFF6D42CE),
            value: selectedValue != '' ? selectedValue : null,
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
                if (options == roles) {
                  selectedRole = newValue;
                } else if (options == languages) {
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

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _updateUser,
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

  Widget _buildSecurityButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SecurityPrivacyPage()),
          );
        },
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
              'SECURITY',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
