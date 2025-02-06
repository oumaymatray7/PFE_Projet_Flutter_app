import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/compteUser/model.dart';
import 'package:mobile_app/Employee%20Management/Employees.dart';

class ServiceHomePage {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<Map<String, dynamic>?> getUserData(User currentUser) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      return userDoc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Failed to load user data: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<CompteUser?> getCompteUser(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      var userData = userDoc.data() as Map<String, dynamic>?;
      if (userData != null) {
        return CompteUser.fromMap(userData);
      }
    } catch (e) {
      print('Failed to load CompteUser data: $e');
    }
    return null;
  }

  // Other service functions can be added here as needed
}
