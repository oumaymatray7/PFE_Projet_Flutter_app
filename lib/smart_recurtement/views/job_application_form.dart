import 'package:flutter/material.dart';
import 'package:mobile_app/services/job_Service/RecruitmentService.dart';

import 'package:mobile_app/smart_recurtement/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile_app/smart_recurtement/models/applicant.dart';

class JobApplicationFormScreen extends StatefulWidget {
  final String jobTitle;
  final String companyName;

  JobApplicationFormScreen({required this.jobTitle, required this.companyName});

  @override
  _JobApplicationFormScreenState createState() =>
      _JobApplicationFormScreenState();
}

class _JobApplicationFormScreenState extends State<JobApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _coverLetterController = TextEditingController();
  String? _cvFileName;
  RecruitmentService _recruitmentService = RecruitmentService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _coverLetterController.dispose();
    super.dispose();
  }

  Future<void> _pickCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _cvFileName = result.files.single.name;
      });
    }
  }

  Future<void> _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      if (_cvFileName == null || _cvFileName!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please upload your CV')),
        );
        return;
      }

      // Create an applicant instance
      Applicant applicant = Applicant(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        coverLetter: _coverLetterController.text,
        cv: _cvFileName!,
      );

      try {
        // Add applicant to the company
        await _recruitmentService.addApplicantToCompany(
            widget.companyName, applicant);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Application submitted successfully!')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit application: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Apply for ${widget.jobTitle}',
            style: kTitleStyle.copyWith(color: kSecondaryColor)),
        backgroundColor: kPrimaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              TextFormField(
                controller: _coverLetterController,
                decoration: InputDecoration(labelText: 'Cover Letter'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your cover letter';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              GestureDetector(
                onTap: _pickCV,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: _cvFileName ?? 'Upload CV',
                    ),
                    validator: (value) {
                      if (_cvFileName == null || _cvFileName!.isEmpty) {
                        return 'Please upload your CV';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              SizedBox(
                height: screenHeight * 0.08,
                child: ElevatedButton(
                  onPressed: _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    'Submit Application',
                    style: kTitleStyle.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
