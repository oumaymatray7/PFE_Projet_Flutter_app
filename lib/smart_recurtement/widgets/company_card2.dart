import 'package:flutter/material.dart';
import 'package:mobile_app/smart_recurtement/constants.dart';
import 'package:mobile_app/smart_recurtement/models/company.dart';

class CompanyCard2 extends StatelessWidget {
  final Company company;

  CompanyCard2({required this.company});

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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width:
                    screenWidth * 0.2, // Adjust width relative to screen size
                height:
                    screenWidth * 0.1, // Adjust height relative to screen size
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
                company.sallary ?? 'N/A',
                style: kTitleStyle,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.005), // Adjust height
          Text(
            company.job ?? 'Job Title',
            style: kTitleStyle,
          ),
          SizedBox(height: screenHeight * 0.005), // Adjust height
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: company.companyName ?? 'Company Name',
                  style: kSubtitleStyle,
                ),
                TextSpan(
                  text: "  •  ",
                  style: kSubtitleStyle,
                ),
                TextSpan(
                  text: company.city ?? 'City',
                  style: kSubtitleStyle,
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.01), // Adjust height
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: company.tag
                    ?.map(
                      (e) => Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(right: 10.0),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03, // Adjust padding
                          vertical: screenHeight * 0.01, // Adjust padding
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          color: kPrimaryColor.withOpacity(0.1),
                          border: Border.all(
                            color: kPrimaryColor,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          e,
                          style: kSubtitleStyle.copyWith(
                            color: kPrimaryColor,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    )
                    .toList() ??
                [],
          ),
        ],
      ),
    );
  }
}