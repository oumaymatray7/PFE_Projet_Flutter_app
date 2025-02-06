import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/calendar/EventActionsDialog.dart';
import 'package:mobile_app/services/calendarService/service_calendar.dart';

class FamilyEventsPage extends StatelessWidget {
  final CalendarService _calendarService = CalendarService();
  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    Future<void> _deleteEvent(String eventId) async {
      try {
        await _calendarService.deleteEvent(eventId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete event: $e')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Family Events",
            style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future:
            _calendarService.fetchUserEventsByType(currentUser!.uid, 'Family'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error fetching events: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('NoFamily events found'));
          } else {
            List<Map<String, dynamic>> FamilyEvents = snapshot.data!;
            return ListView.builder(
              itemCount: FamilyEvents.length,
              itemBuilder: (context, index) {
                final event = FamilyEvents[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Text(
                        event['type'] != null
                            ? event['type'][0]
                            : 'N/A', // Handle null 'type' field
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(event['title'],
                        style: GoogleFonts.roboto(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    subtitle: Text(
                      "${event['description']} - ${event['start_date']}",
                      style: GoogleFonts.roboto(fontSize: 14),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit, color: Colors.deepPurple),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => EventActionsDialog(
                            eventId: event['id'],
                            event: event,
                            onDelete: _deleteEvent,
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      // Optionally, add an action or navigation on tap
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
