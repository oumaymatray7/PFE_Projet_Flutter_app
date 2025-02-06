import 'package:flutter/material.dart';
import 'package:mobile_app/smart_recurtement/models/company.dart';
import 'package:mobile_app/smart_recurtement/constants.dart';

class RecentJobCard extends StatelessWidget {
  final Company company;

  RecentJobCard({required this.company});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              company.job ?? 'Job Title',
              style: kTitleStyle,
            ),
            SizedBox(height: 8.0),
            Text(
              company.companyName ?? 'Company Name',
              style: kSubtitleStyle,
            ),
            SizedBox(height: 8.0),
            Text(
              company.city ?? 'City',
              style: kSubtitleStyle,
            ),
          ],
        ),
      ),
    );
  }
}
