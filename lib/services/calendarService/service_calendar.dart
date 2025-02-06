import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add event to Firestore
  Future<void> addEvent(Map<String, dynamic> eventData) async {
    try {
      await _firestore.collection('events').add(eventData);
    } catch (e) {
      print('Error adding event: $e');
      throw e;
    }
  }

  // Fetch all events created by the current user
  Future<List<Map<String, dynamic>>> fetchUserEvents(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('events')
          .where('created_by', isEqualTo: userId)
          .get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching user events: $e');
      throw e;
    }
  }

  // Fetch events of a specific type created by the current user
  Future<List<Map<String, dynamic>>> fetchUserEventsByType(
      String userId, String eventType) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('events')
          .where('created_by', isEqualTo: userId)
          .where('calendar', isEqualTo: eventType)
          .get();
      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error fetching user events: $e');
      throw e;
    }
  }

  // Update an event in Firestore
  Future<void> updateEvent(
      String eventId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('events').doc(eventId).update(updatedData);
    } catch (e) {
      print('Error updating event: $e');
      throw e;
    }
  }

  // Delete an event from Firestore
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
      throw e;
    }
  }
}
