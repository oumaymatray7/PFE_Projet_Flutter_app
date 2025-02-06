import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/services/job_Service/RecruitmentService.dart';

import 'package:mobile_app/smart_recurtement/models/company.dart';

class AddCompanyPage extends StatefulWidget {
  @override
  _AddCompanyPageState createState() => _AddCompanyPageState();
}

class _AddCompanyPageState extends State<AddCompanyPage> {
  final _formKey = GlobalKey<FormState>();
  final RecruitmentService _recruitmentService = RecruitmentService();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _criteriaController = TextEditingController();
  final TextEditingController _jobOpportunityController =
      TextEditingController();
  final TextEditingController _aboutCompanyController = TextEditingController();
  final TextEditingController _jobResponsibilitiesController =
      TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        Company newCompany = Company(
          companyName: _companyNameController.text,
          job: _jobTitleController.text,
          city: _cityController.text,
          sallary: _salaryController.text,
          image: _imageController.text,
          mainCriteria: _criteriaController.text,
          jobOpportunity: _jobOpportunityController.text,
          aboutCompany: _aboutCompanyController.text,
          jobResponsbilities: _jobResponsibilitiesController.text.split(','),
          tag: _tagController.text.split(','),
          applicants: [],
        );
        await _recruitmentService.addCompany(newCompany);
        Navigator.pop(context, true);
      } catch (e) {
        print('Error adding company: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Company'),
        backgroundColor: theme.primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildTextFormField(_companyNameController, 'Company Name',
                  'Please enter a company name'),
              _buildTextFormField(
                  _jobTitleController, 'Job Title', 'Please enter a job title'),
              _buildTextFormField(
                  _cityController, 'City', 'Please enter a city'),
              _buildTextFormField(
                  _salaryController, 'Salary', 'Please enter a salary'),
              _buildTextFormField(
                  _imageController, 'Image URL', 'Please enter an image URL'),
              _buildTextFormField(
                  _criteriaController, 'Criteria', 'Please enter criteria'),
              _buildTextFormField(_jobOpportunityController, 'Job Opportunity',
                  'Please enter job opportunity'),
              _buildTextFormField(_aboutCompanyController, 'About Company',
                  'Please enter information about the company'),
              _buildTextFormField(
                  _jobResponsibilitiesController,
                  'Job Responsibilities (comma separated)',
                  'Please enter job responsibilities'),
              _buildTextFormField(_tagController, 'Tags (comma separated)',
                  'Please enter tags'),
              SizedBox(height: screenHeight * 0.03),
              SizedBox(
                height: screenHeight * 0.08,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    'Add Company',
                    style: theme.textTheme.headline6
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label,
      String validationMessage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validationMessage;
          }
          return null;
        },
      ),
    );
  }
}
