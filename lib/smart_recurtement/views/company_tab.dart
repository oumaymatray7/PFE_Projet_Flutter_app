import 'package:flutter/material.dart';
import 'package:mobile_app/smart_recurtement/constants.dart';
import 'package:mobile_app/smart_recurtement/models/company.dart';

class CompanyTab extends StatelessWidget {
  final Company company;

  CompanyTab({required this.company});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: ListView(
        children: <Widget>[
          SizedBox(height: 25.0),
          Text(
            "About Company",
            style: kTitleStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15.0),
          Text(
            company.aboutCompany ?? 'No information available',
            style: kSubtitleStyle.copyWith(
              fontWeight: FontWeight.w300,
              height: 1.5,
              color: Color(0xFF5B5B5B),
            ),
          ),
        ],
      ),
    );
  }
}