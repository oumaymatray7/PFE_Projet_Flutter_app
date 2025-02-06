import 'package:flutter/material.dart';
import 'package:mobile_app/services/job_Service/RecruitmentService.dart';
import 'package:mobile_app/smart_recurtement/constants.dart';
import 'package:mobile_app/smart_recurtement/models/company.dart';
import 'package:mobile_app/smart_recurtement/views/Edit.dart';

class ViewCompaniesPage extends StatefulWidget {
  @override
  _ViewCompaniesPageState createState() => _ViewCompaniesPageState();
}

class _ViewCompaniesPageState extends State<ViewCompaniesPage> {
  final RecruitmentService _recruitmentService = RecruitmentService();
  List<Company> companyList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCompanies();
  }

  Future<void> _fetchCompanies() async {
    setState(() => isLoading = true);
    try {
      List<Company> companies = await _recruitmentService.fetchAllCompanies();
      setState(() {
        companyList = companies;
      });
    } catch (e) {
      print('Error fetching companies: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> _deleteCompany(String companyId) async {
    try {
      await _recruitmentService.deleteCompany(companyId);
      _fetchCompanies();
    } catch (e) {
      print('Error deleting company: $e');
    }
  }

  void _showDeleteDialog(String companyId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Company'),
          content: Text('Are you sure you want to delete this company?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteCompany(companyId);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Companies'),
        backgroundColor: kPrimaryColor,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: companyList.length,
                itemBuilder: (context, index) {
                  var company = companyList[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      title: Text(
                        company.companyName ?? 'No Company Name',
                        style: kTitleStyle.copyWith(
                            color: kPrimaryColor, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        company.job ?? 'No Job Title',
                        style: kSubtitleStyle.copyWith(color: Colors.grey[600]),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.edit, color: kPrimaryColor),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditCompanyPage(
                                    companyId: company.companyId!,
                                    company: company,
                                  ),
                                ),
                              ).then((_) => _fetchCompanies());
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              _showDeleteDialog(company.companyId!);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
