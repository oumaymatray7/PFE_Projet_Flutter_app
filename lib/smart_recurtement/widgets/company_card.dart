import 'package:flutter/material.dart';
import 'package:mobile_app/smart_recurtement/constants.dart';
import 'package:mobile_app/smart_recurtement/models/company.dart';

class CompanyCard extends StatelessWidget {
  final Company company;

  CompanyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.8, // Adjust width relative to screen size
      margin: EdgeInsets.only(right: 15.0),
      padding: EdgeInsets.all(screenWidth * 0.04), // Adjust padding
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: kPrimaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width:
                    screenWidth * 0.13, // Adjust width relative to screen size
                height:
                    screenWidth * 0.13, // Adjust height relative to screen size
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  image: DecorationImage(
                    image:
                        AssetImage(company.image ?? 'assets/placeholder.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Spacer(),
              Text(
                company.sallary ?? 'Salary',
                style: kTitleStyle.copyWith(color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02), // Adjust height
          Text(
            company.job ?? 'Job Title',
            style: kTitleStyle.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenHeight * 0.02), // Adjust height
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: company.companyName ?? 'Company Name',
                  style: kSubtitleStyle.copyWith(
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: "  •  ",
                  style: kSubtitleStyle.copyWith(
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: company.city ?? 'City',
                  style: kSubtitleStyle.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.02), // Adjust height
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: company.tag?.map((e) {
                    return Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(right: 10.0),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03, // Adjust padding
                        vertical: screenHeight * 0.01, // Adjust padding
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: kAccentColor,
                      ),
                      child: Text(
                        e,
                        style: kSubtitleStyle.copyWith(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                    );
                  }).toList() ??
                  [Text('No tags available')],
            ),
          ),
        ],
      ),
    );
  }
}
