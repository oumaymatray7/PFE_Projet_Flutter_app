import 'package:flutter/material.dart';
import 'package:mobile_app/services/job_Service/RecruitmentService.dart';
import 'package:mobile_app/smart_recurtement/constants.dart';
import 'package:mobile_app/smart_recurtement/models/company.dart';

class EditCompanyPage extends StatefulWidget {
  final String companyId;
  final Company company;

  EditCompanyPage({required this.companyId, required this.company});

  @override
  _EditCompanyPageState createState() => _EditCompanyPageState();
}

class _EditCompanyPageState extends State<EditCompanyPage> {
  final _formKey = GlobalKey<FormState>();
  final RecruitmentService _recruitmentService = RecruitmentService();
  late TextEditingController _companyNameController;
  late TextEditingController _jobTitleController;
  late TextEditingController _cityController;
  late TextEditingController _salaryController;
  late TextEditingController _imageController;
  late TextEditingController _criteriaController;
  late TextEditingController _jobOpportunityController;
  late TextEditingController _aboutCompanyController;
  late TextEditingController _jobResponsibilitiesController;
  late TextEditingController _tagController;

  @override
  void initState() {
    super.initState();
    _companyNameController =
        TextEditingController(text: widget.company.companyName);
    _jobTitleController = TextEditingController(text: widget.company.job);
    _cityController = TextEditingController(text: widget.company.city);
    _salaryController = TextEditingController(text: widget.company.sallary);
    _imageController = TextEditingController(text: widget.company.image);
    _criteriaController =
        TextEditingController(text: widget.company.mainCriteria);
    _jobOpportunityController =
        TextEditingController(text: widget.company.jobOpportunity);
    _aboutCompanyController =
        TextEditingController(text: widget.company.aboutCompany);
    _jobResponsibilitiesController = TextEditingController(
        text: widget.company.jobResponsbilities?.join(',') ?? '');
    _tagController =
        TextEditingController(text: widget.company.tag?.join(',') ?? '');
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _jobTitleController.dispose();
    _cityController.dispose();
    _salaryController.dispose();
    _imageController.dispose();
    _criteriaController.dispose();
    _jobOpportunityController.dispose();
    _aboutCompanyController.dispose();
    _jobResponsibilitiesController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      Company updatedCompany = Company(
        companyId: widget.companyId,
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
        applicants: widget.company.applicants,
      );

      try {
        await _recruitmentService.updateCompany(
            widget.companyId, updatedCompany);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Company updated successfully!')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update company: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Company'),
        backgroundColor: kPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildTextField(_companyNameController, 'Company Name'),
              SizedBox(height: 16.0),
              _buildTextField(_jobTitleController, 'Job Title'),
              SizedBox(height: 16.0),
              _buildTextField(_cityController, 'City'),
              SizedBox(height: 16.0),
              _buildTextField(_salaryController, 'Salary'),
              SizedBox(height: 16.0),
              _buildTextField(_imageController, 'Image URL'),
              SizedBox(height: 16.0),
              _buildTextField(_criteriaController, 'Criteria'),
              SizedBox(height: 16.0),
              _buildTextField(_jobOpportunityController, 'Job Opportunity'),
              SizedBox(height: 16.0),
              _buildTextField(_aboutCompanyController, 'About Company'),
              SizedBox(height: 16.0),
              _buildTextField(_jobResponsibilitiesController,
                  'Job Responsibilities (comma separated)'),
              SizedBox(height: 16.0),
              _buildTextField(_tagController, 'Tags (comma separated)'),
              SizedBox(height: 32.0),
              SizedBox(
                width: screenWidth,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Text(
                    'Update Company',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: kPrimaryColor),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: kPrimaryColor),
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}
