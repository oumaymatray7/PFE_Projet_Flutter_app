import 'package:flutter/material.dart';
import 'package:mobile_app/smart_recurtement/models/company.dart'; // Correct import path
import 'package:mobile_app/smart_recurtement/constants.dart';
import 'package:mobile_app/smart_recurtement/views/company_tab.dart';
import 'package:mobile_app/smart_recurtement/views/description_tab.dart';
import 'package:mobile_app/smart_recurtement/views/job_application_form.dart';

class JobDetail extends StatelessWidget {
  final Company company;

  JobDetail({required this.company});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: kSecondaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          company.companyName ?? 'Company Name',
          style: kTitleStyle.copyWith(color: kSecondaryColor),
        ),
        centerTitle: true,
      ),
      body: DefaultTabController(
        length: 2,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.005,
          ),
          decoration: BoxDecoration(
            color: kBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40.0),
              topRight: Radius.circular(40.0),
            ),
          ),
          child: Column(
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: screenWidth * 0.18,
                        height: screenWidth * 0.18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          image: DecorationImage(
                            image: NetworkImage(
                              company.image ?? 'assets/placeholder.jpg',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      company.job ?? 'Job Title',
                      style: kTitleStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: kSecondaryColor,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Text(
                      company.sallary ?? 'N/A',
                      style: kSubtitleStyle.copyWith(color: kSecondaryColor),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: company.tag?.map((e) {
                            return Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.01),
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02,
                                vertical: screenHeight * 0.01,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: kSecondaryColor.withOpacity(.5),
                                ),
                              ),
                              child: Text(
                                e,
                                style: kSubtitleStyle.copyWith(
                                    color: kSecondaryColor),
                              ),
                            );
                          }).toList() ??
                          [],
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(
                          color: kSecondaryColor.withOpacity(.2),
                        ),
                      ),
                      child: TabBar(
                        unselectedLabelColor: kTextColor,
                        indicator: BoxDecoration(
                          color: kAccentColor,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        tabs: [
                          Tab(text: "Description"),
                          Tab(text: "Company"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Expanded(
                child: TabBarView(
                  children: [
                    DescriptionTab(company: company),
                    CompanyTab(company: company),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.1),
        child: Container(
          padding: EdgeInsets.only(
            left: screenWidth * 0.05,
            bottom: screenHeight * 0.03,
            right: screenWidth * 0.05,
          ),
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Container(
                width: screenWidth * 0.13,
                height: screenWidth * 0.13,
                decoration: BoxDecoration(
                  border: Border.all(color: kSecondaryColor.withOpacity(.5)),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  Icons.bookmark_border,
                  color: kSecondaryColor,
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: SizedBox(
                  height: screenWidth * 0.13,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobApplicationFormScreen(
                            jobTitle: company.job ?? 'Job Title',
                            companyName: company.companyName!,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      "Apply for Job",
                      style: kTitleStyle.copyWith(
                        color: Colors.white,
                      ),
                    ),
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
