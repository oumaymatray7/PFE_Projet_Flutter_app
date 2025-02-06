import 'package:flutter/material.dart';
import 'package:mobile_app/Employee%20Management/Employees.dart';
import 'package:mobile_app/Employee%20Management/updateEmployee.dart';

class EmployeeDetailsPage extends StatelessWidget {
  final Employee employee;

  EmployeeDetailsPage({Key? key, required this.employee}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.8;
    double imageRadius = width * 0.2;
    double editButtonWidth = width * 0.6;
    double editButtonHeight = 50;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF9155FD), Color(0xFFC5A5FE)],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 50),
                Image.asset('assets/smartovate.png', height: 100),
                SizedBox(height: 30),
                CircleAvatar(
                  backgroundImage: NetworkImage(employee.imagePath),
                  radius: imageRadius,
                ),
                SizedBox(height: 20),
                Text(
                  employee.name,
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Details',
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        color: Colors.white70,
                      ),
                ),
                SizedBox(height: 20),
                Container(
                  width: width,
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildDetailRow(Icons.person, 'Username', employee.name),
                      _buildDetailRow(Icons.person_outline, 'First Name',
                          employee.firstName),
                      _buildDetailRow(
                          Icons.person_outline, 'Last Name', employee.lastName),
                      _buildDetailRow(Icons.email, 'Email', employee.email),
                      _buildDetailRow(
                          Icons.phone, 'Phone', employee.phoneNumber),
                      _buildDetailRow(
                          Icons.location_on, 'Country', employee.country),
                      _buildDetailRow(
                          Icons.work, 'Job Title', employee.jobTitle),
                      _buildDetailRow(
                          Icons.language, 'Language', employee.language),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: editButtonWidth,
                  height: editButtonHeight,
                  margin: EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UpdateEmployeePage(employee: employee),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF28243D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'EDIT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '$label: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
