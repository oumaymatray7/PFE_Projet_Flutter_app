import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/Employee%20Management/employee_tile.dart';
import 'package:mobile_app/compteUser/compteUser.dart';
import 'package:mobile_app/services/Auth_service/homepage_service.dart';
import 'package:mobile_app/auth/login.dart';

import 'package:mobile_app/calendar/calendarHome.dart';
import 'package:mobile_app/chat/chatHomePage.dart';
import 'package:mobile_app/mail/mailHomePage.dart';
import 'package:mobile_app/project%20management/ProjectManagementHomePage.dart';
import 'package:mobile_app/smart_recurtement/views/home.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSwitched = false;
  User? currentUser;
  String name = '';
  String employeeImageUrl = "assets/Ellipse 10.png";
  final ServiceHomePage _serviceHomePage = ServiceHomePage();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      Map<String, dynamic>? userData =
          await _serviceHomePage.getUserData(currentUser!);
      if (userData != null) {
        setState(() {
          name = userData['name'] ?? 'Unknown User';
          employeeImageUrl = userData['imagePath'] ?? 'assets/Ellipse 10.png';
        });
      } else {
        setState(() {
          name = 'Unknown User';
          employeeImageUrl = 'assets/Ellipse 10.png';
        });
      }
    } else {
      setState(() {
        name = 'Unknown User';
        employeeImageUrl = 'assets/Ellipse 10.png';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0XFF28243D),
        body: Center(
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            children: <Widget>[
              Positioned(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    "assets/Group2.png",
                    fit: BoxFit.cover,
                    width: screenWidth,
                    height: screenHeight * 0.5,
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.2,
                right: 70,
                child: Center(
                  child: CircleAvatar(
                    radius: screenWidth * 0.35,
                    backgroundImage: employeeImageUrl.isNotEmpty
                        ? NetworkImage(employeeImageUrl) as ImageProvider
                        : AssetImage("assets/Ellipse 10.png"),
                    backgroundColor: Colors.transparent,
                    child: employeeImageUrl.isEmpty
                        ? Icon(
                            Icons.account_circle,
                            size: 80,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.54,
                right: screenWidth * 0.2,
                child: Text(
                  'Hello, $name',
                  style: GoogleFonts.roboto(
                    fontSize: screenHeight * 0.03,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                bottom: screenHeight * 0.30,
                right: 110,
                child: Material(
                  color: Colors.transparent,
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(145, 85, 253, 1),
                          Color.fromRGBO(197, 165, 254, 1)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () async {
                        final confirm = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirm Logout'),
                              content: Text('Are you sure you want to logout?'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                ),
                                TextButton(
                                  child: Text('Logout'),
                                  onPressed: () async {
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm) {
                          await _serviceHomePage.signOut();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        }
                      },
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.power_settings_new, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Logout',
                              style: GoogleFonts.roboto(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: screenHeight * 0.25,
                right: 0.1,
                child: Material(
                  color: Colors.transparent,
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: isSwitched,
                                  onChanged: (bool value) {
                                    setState(() {
                                      isSwitched = value;
                                    });
                                  },
                                  activeColor: Colors.green,
                                  inactiveThumbColor: Colors.grey,
                                  inactiveTrackColor: Colors.grey[400],
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            InkWell(
                              onTap: () async {
                                var userData = await _serviceHomePage
                                    .getCompteUser(currentUser!.uid);
                                if (userData != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UpdateUserInfoScreen(
                                        user: userData,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person,
                                      color: Colors.white, size: 34),
                                  SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                bottom: screenHeight * 0.22,
                child: Text(
                  "Apps & Pages",
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.75,
                left: 0,
                right: 0,
                bottom: 0,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      appRow(context, 'Dynamic Email', Icons.email, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MailHomePage()),
                        );
                      }),
                      SizedBox(height: 5),
                      appRow(context, 'Smart Calendar', Icons.calendar_month,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CalendarHome()),
                        );
                      }),
                      SizedBox(height: 5),
                      appRow(context, 'Employee Management',
                          Icons.manage_accounts_outlined, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EmployeeDirectoryPage()),
                        );
                      }),
                      SizedBox(height: 5),
                      appRow(context, 'Smart Project Management',
                          Icons.recent_actors_outlined, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ProjectManagementHomePage()),
                        );
                      }),
                      SizedBox(height: 5),
                      appRow(context, 'Chat', Icons.chat, () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Chat()));
                      }),
                      SizedBox(height: 5),
                      appRow(context, 'Smart Recruitment',
                          Icons.recent_actors_outlined, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Home()),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget appRow(BuildContext context, String title, IconData iconData,
      VoidCallback onTap) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: screenWidth * 0.1,
        ),
        decoration: BoxDecoration(
          color: Color(0xff9155FD),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            Icon(
              iconData,
              size: screenHeight * 0.04,
              color: Colors.white,
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  fontSize: screenHeight * 0.025,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget appTile(BuildContext context, String title, String assetName,
      {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: Color(0xff9155FD),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assetName,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
