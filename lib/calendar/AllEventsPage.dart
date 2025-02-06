import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/services/calendarService/service_calendar.dart';

class EventDisplayWidget extends StatefulWidget {
  @override
  _EventDisplayWidgetState createState() => _EventDisplayWidgetState();
}

class _EventDisplayWidgetState extends State<EventDisplayWidget> {
  final CalendarService _calendarService = CalendarService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserEvents();
  }

  void _fetchUserEvents() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        List<Map<String, dynamic>> events =
            await _calendarService.fetchUserEvents(currentUser.uid);
        setState(() {
          _events = events;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load events: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Events",
            style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Text(event['title'][0].toUpperCase(),
                          style: TextStyle(color: Colors.white)),
                    ),
                    title: Text(event['title'],
                        style: GoogleFonts.roboto(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    subtitle: Text(
                        "${event['description'] ?? ''} - ${event['start_date']}",
                        style: GoogleFonts.roboto(fontSize: 14)),
                    trailing: IconButton(
                      icon: Icon(Icons.edit, color: Colors.deepPurple),
                      onPressed: () {
                        // Add your code to handle event editing
                      },
                    ),
                    onTap: () {
                      // Add your code to handle event tap
                    },
                  ),
                );
              },
            ),
    );
  }
}
