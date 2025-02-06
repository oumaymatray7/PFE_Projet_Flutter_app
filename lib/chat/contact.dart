import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  final String name;
  final String jobTitle;
  final String email;
  final String phone;
  final String address;
  final String avatarPath;
  final bool isOnline;

  const ContactPage({
    Key? key,
    required this.name,
    required this.jobTitle,
    required this.email,
    required this.phone,
    required this.address,
    required this.avatarPath,
    required this.isOnline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact Details"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.25),
                Color.fromARGB(255, 54, 43, 113),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: Color.fromARGB(255, 28, 9, 65),
        child: ListView(
          children: <Widget>[
            SizedBox(height: 24), // For spacing
            CircleAvatar(
              radius: 80, // Adjust the size as needed
              backgroundImage: AssetImage(avatarPath),
              backgroundColor: Colors.transparent,
            ),
            SizedBox(height: 16), // For spacing
            Center(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Center(
              child: Text(
                jobTitle,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.email, color: Colors.white),
              title: Text(email, style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.white),
              title: Text(phone, style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.white),
              title: Text(address, style: TextStyle(color: Colors.white)),
            ),
            if (isOnline)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.circle, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text('Online', style: TextStyle(color: Colors.green))
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
