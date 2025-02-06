import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/project%20management/gestion%20de%20projet/ProjectManagementDetails.dart';
import 'package:mobile_app/project%20management/planning/PlanningDetails.dart';
import 'package:mobile_app/Employee%20Management/Employees.dart';
import 'package:mobile_app/services/projectMnagementService/project_mangementService.dart';

class ProjectManagementHomePage extends StatefulWidget {
  @override
  _ProjectManagementHomePageState createState() =>
      _ProjectManagementHomePageState();
}

class _ProjectManagementHomePageState extends State<ProjectManagementHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  final ProjectManagementService _projectService = ProjectManagementService();
  Employee? currentEmployee;

  String userName = '';
  Map<String, dynamic>? workingHours;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: Offset(0.0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();

    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      if (userData != null) {
        setState(() {
          userName = userData['name'];
          workingHours = userData['workingHours'];
        });

        currentEmployee = Employee.fromMap(userData, currentUser.uid);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PlanningDetails(currentUserID: currentEmployee!.id),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFF28243D),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              FadeTransition(
                opacity: _opacityAnimation,
                child: _buildTopBanner(screenWidth, screenHeight),
              ),
              SlideTransition(
                position: _slideAnimation,
                child: _buildWelcomeMessage(),
              ),
              SlideTransition(
                position: _slideAnimation,
                child: _buildStatusCard(),
              ),
              SlideTransition(
                position: _slideAnimation,
                child: _buildFeatureSection(
                    screenWidth,
                    'Project List',
                    Icons.dashboard_customize,
                    ProjectManagementDetails() as Widget),
              ),
              SlideTransition(
                position: _slideAnimation,
                child: _buildFeatureSection(
                    screenWidth,
                    'Planification',
                    Icons.schedule,
                    currentEmployee != null
                        ? PlanningDetails(currentUserID: currentEmployee!.id)
                        : Container()), // Display an empty container if currentEmployee is null
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBanner(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth,
      height: screenHeight * 0.25,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/R.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
        child: Text(
          'Enhance Your Project Management Skills',
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: <Shadow>[
              Shadow(
                offset: Offset(0, 2),
                blurRadius: 3.0,
                color: Color.fromARGB(150, 0, 0, 0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Welcome, $userName',
        style: GoogleFonts.roboto(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    if (workingHours == null) {
      return CircularProgressIndicator();
    }

    DateTime now = DateTime.now();
    String dayOfWeek = _getDayOfWeek(now.weekday);
    String checkInTime = workingHours![dayOfWeek]?['checkIn'] ?? '--:--';
    String checkOutTime = workingHours![dayOfWeek]?['checkOut'] ?? '--:--';

    bool isHoliday = checkInTime == 'holiday' || checkOutTime == 'holiday';

    bool isValidTime(String time) {
      return time.contains(':') &&
          time.split(':').length == 2 &&
          int.tryParse(time.split(':')[0]) != null &&
          int.tryParse(time.split(':')[1]) != null;
    }

    bool workDayComplete = false;
    if (!isHoliday && isValidTime(checkOutTime)) {
      workDayComplete = now.isAfter(DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(checkOutTime.split(':')[0]),
        int.parse(checkOutTime.split(':')[1]),
      ));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              "Today's Status",
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      'Check In',
                      style:
                          GoogleFonts.roboto(fontSize: 16, color: Colors.black),
                    ),
                    Text(
                      checkInTime,
                      style:
                          GoogleFonts.roboto(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Check Out',
                      style:
                          GoogleFonts.roboto(fontSize: 16, color: Colors.black),
                    ),
                    Text(
                      checkOutTime,
                      style:
                          GoogleFonts.roboto(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              '${now.toLocal()}'.split(' ')[0],
              style: GoogleFonts.roboto(fontSize: 14, color: Colors.black),
            ),
            Text(
              '${now.toLocal()}'.split(' ')[1],
              style: GoogleFonts.roboto(fontSize: 14, color: Colors.black),
            ),
            SizedBox(height: 10),
            Text(
              isHoliday
                  ? 'Today is a holiday'
                  : workDayComplete
                      ? 'Workday complete'
                      : 'Work in progress',
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayOfWeek(int day) {
    switch (day) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }

  Widget _buildFeatureSection(
      double screenWidth, String title, IconData icon, Widget page) {
    return Container(
      width: screenWidth * 0.9,
      margin: EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF6D42CE),
          padding: EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: screenWidth * 0.1, color: Colors.white),
            SizedBox(width: screenWidth * 0.05),
            Text(
              title,
              style: GoogleFonts.roboto(
                  fontSize: screenWidth * 0.05, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
