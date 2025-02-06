import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShowApplicantsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Show Applicants', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('companies').snapshots(),
        builder: (context, companySnapshot) {
          if (!companySnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final companies = companySnapshot.data!.docs;

          return ListView.builder(
            itemCount: companies.length,
            itemBuilder: (context, index) {
              var company = companies[index];
              var companyData = company.data() as Map<String, dynamic>;
              var applicants = companyData.containsKey('applicants')
                  ? companyData['applicants'] as List<dynamic>
                  : [];

              return Card(
                margin: EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 3,
                child: ExpansionTile(
                  title: Text(
                    companyData['companyName'] ?? 'No Company Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  children: applicants.isNotEmpty
                      ? applicants.map((applicantData) {
                          var applicant = applicantData as Map<String, dynamic>;
                          return Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 6.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.deepPurpleAccent,
                                child: Text(
                                  applicant['name']?.substring(0, 1) ?? '',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(applicant['name'] ?? 'No Name'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email: ${applicant['email'] ?? 'No Email'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    'Phone: ${applicant['phone'] ?? 'No Phone'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    'Cover Letter: ${applicant['coverLetter'] ?? 'No Cover Letter'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    'CV: ${applicant['cv'] ?? 'No CV'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        }).toList()
                      : [ListTile(title: Text('No applicants'))],
                ),
              );
            },
          );
        },
      ),
    );
  }
}