import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_app/services/job_Service/RecruitmentService.dart';
import 'package:mobile_app/smart_recurtement/constants.dart';
import 'package:mobile_app/smart_recurtement/models/company.dart';
import 'package:mobile_app/smart_recurtement/views/AddCompanyPage.dart';
import 'package:mobile_app/smart_recurtement/views/ShowApplicantsPage.dart';
import 'package:mobile_app/smart_recurtement/views/ViewCompaniesPage.dart';
import 'package:mobile_app/smart_recurtement/views/job_detail.dart';
import 'package:mobile_app/smart_recurtement/widgets/company_card.dart';
import 'package:mobile_app/smart_recurtement/widgets/company_card2.dart';
import 'package:mobile_app/smart_recurtement/widgets/recent_job_card.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final RecruitmentService _recruitmentService = RecruitmentService();
  List<Company> companyList = [];
  List<Company> recentList = [];
  bool isLoading = true;
  String? userName;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchUserName();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      List<Company> companies = await _recruitmentService.fetchAllCompanies();
      List<Company> recentJobs = await _recruitmentService.fetchRecentJobs();
      setState(() {
        companyList = companies;
        recentList = recentJobs;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> _fetchUserName() async {
    User? currentUser = await _recruitmentService.getCurrentUser();
    if (currentUser != null) {
      Map<String, dynamic>? userData =
          await _recruitmentService.getUserData(currentUser);
      setState(() {
        userName = userData?['name'] ?? 'User';
      });
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Menu'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToAddCompany();
              },
              child: Text('Add Company'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToShowApplicants();
              },
              child: Text('Show Applicants'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToViewCompanies();
              },
              child: Text('View Companies'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToAddCompany() async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCompanyPage()),
    );
    if (result == true) {
      _fetchData();
    }
  }

  void _navigateToShowApplicants() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShowApplicantsPage()),
    );
  }

  void _navigateToViewCompanies() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewCompaniesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 18.0,
            top: 12.0,
            bottom: 12.0,
            right: 12.0,
          ),
          child: InkWell(
            onTap: _showDialog,
            child: SvgPicture.asset(
              "assets/drawer.svg",
              color: kTextColor,
            ),
          ),
        ),
        actions: <Widget>[
          SvgPicture.asset(
            "assets/user.svg",
            width: 25.0,
            color: kTextColor,
          ),
          SizedBox(width: 18.0)
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(left: 18.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 25.0),
              Text(
                "Hi $userName,\nFind your Dream Job",
                style: kPageTitleStyle,
              ),
              SizedBox(height: 25.0),
              Container(
                width: double.infinity,
                height: 50.0,
                margin: EdgeInsets.only(right: 18.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: TextField(
                          cursorColor: kTextColor,
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.search,
                              size: 25.0,
                              color: kTextColor,
                            ),
                            border: InputBorder.none,
                            hintText: "Search for job title",
                            hintStyle: kSubtitleStyle.copyWith(
                              color: Colors.black38,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 50.0,
                      height: 50.0,
                      margin: EdgeInsets.only(left: 12.0),
                      decoration: BoxDecoration(
                        color: kSecondaryColor,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Icon(
                        FontAwesomeIcons.slidersH,
                        color: Colors.white,
                        size: 20.0,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 35.0),
              Text(
                "Popular Company",
                style: kTitleStyle,
              ),
              SizedBox(height: 15.0),
              Container(
                width: double.infinity,
                height: screenHeight * 0.25,
                child: ListView.builder(
                  itemCount: companyList.length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    var company = companyList[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobDetail(
                              company: company,
                            ),
                          ),
                        );
                      },
                      child: index == 0
                          ? CompanyCard(company: company)
                          : CompanyCard2(company: company),
                    );
                  },
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              Text(
                "Recent Jobs",
                style: kTitleStyle,
              ),
              ListView.builder(
                itemCount: recentList.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemBuilder: (context, index) {
                  var recent = recentList[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobDetail(
                            company: recent,
                          ),
                        ),
                      );
                    },
                    child: RecentJobCard(company: recent),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
