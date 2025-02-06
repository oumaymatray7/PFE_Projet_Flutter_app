import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GestionEmployeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add employee to Firestore
  Future<void> addEmployee(Map<String, dynamic> employeeData) async {
    try {
      // Ensure all required fields are not null
      String name = employeeData['name'] ?? 'Unnamed';
      String email = employeeData['email'] ?? '';
      String jobTitle = employeeData['jobTitle'] ?? '';
      String phoneNumber = employeeData['phoneNumber'] ?? '';
      String country = employeeData['country'] ?? '';
      String imagePath = employeeData['imagePath'] ?? '';
      String role = employeeData['role'] ?? 'User';
      String language = employeeData['language'] ?? 'en';
      String firstName = employeeData['firstName'] ?? '';
      String lastName = employeeData['lastName'] ?? '';
      String password = employeeData['password'] ??
          'isima1234'; // Ensure password is provided

      // Check if the email already exists
      List<String> methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        throw FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'The email address is already in use by another account.');
      }

      // Create a user account with Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String userId = userCredential.user!.uid;

      // Initialize working hours
      Map<String, Map<String, String>> workingHours = _initializeWorkingHours();

      // Add employee to employees collection
      await _firestore.collection('employees').doc(userId).set({
        'name': name,
        'email': email,
        'jobTitle': jobTitle,
        'phoneNumber': phoneNumber,
        'country': country,
        'imagePath': imagePath,
        'role': role,
        'language': language,
        'firstName': firstName,
        'lastName': lastName,
        'workingHours': workingHours,
        'projectIds': [], // Initialize with an empty list of project IDs
        'projects': [], // Initialize with an empty list of project details
      });

      // Add the same details to the users collection
      await _firestore.collection('users').doc(userId).set({
        'id': userId,
        'name': name,
        'email': email,
        'jobTitle': jobTitle,
        'phoneNumber': phoneNumber,
        'country': country,
        'imagePath': imagePath,
        'role': role,
        'language': language,
        'firstName': firstName,
        'lastName': lastName,
        'workingHours': workingHours,
        'projectIds': [], // Initialize with an empty list of project IDs
        'projects': [], // Initialize with an empty list of project details
      });
    } catch (e) {
      print('Error adding employee: $e');
      throw e;
    }
  }

  // Initialize working hours
  Map<String, Map<String, String>> _initializeWorkingHours() {
    return {
      'Monday': {'checkIn': '09:00', 'checkOut': '17:00'},
      'Tuesday': {'checkIn': '09:00', 'checkOut': '17:00'},
      'Wednesday': {'checkIn': '09:00', 'checkOut': '17:00'},
      'Thursday': {'checkIn': '09:00', 'checkOut': '17:00'},
      'Friday': {'checkIn': '09:00', 'checkOut': '17:00'},
      'Saturday': {'checkIn': 'holiday', 'checkOut': 'holiday'},
      'Sunday': {'checkIn': 'holiday', 'checkOut': 'holiday'},
    };
  }

  // Fetch all employees
  Future<List<Map<String, dynamic>>> fetchAllEmployees() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('employees').get();
      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error fetching employees: $e');
      throw e;
    }
  }

  // Update an employee in Firestore
  Future<void> updateEmployee(
      String employeeId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore
          .collection('employees')
          .doc(employeeId)
          .update(updatedData);
      await _firestore.collection('users').doc(employeeId).update(updatedData);
    } catch (e) {
      print('Error updating employee: $e');
      throw e;
    }
  }

  // Delete an employee from Firestore
  Future<void> deleteEmployee(String employeeId) async {
    try {
      await _firestore.collection('employees').doc(employeeId).delete();
      await _firestore.collection('users').doc(employeeId).delete();
    } catch (e) {
      print('Error deleting employee: $e');
      throw e;
    }
  }

  // Add working hour for an employee
  Future<void> addWorkingHour(String employeeId, String day,
      Map<String, String> workingHourData) async {
    try {
      await _firestore
          .collection('employees')
          .doc(employeeId)
          .collection('workingHours')
          .doc(day)
          .set(workingHourData);
    } catch (e) {
      print('Error adding working hour: $e');
      throw e;
    }
  }

  // Create user account and add employee details
  Future<void> createUserAccount(
      String email, String password, Map<String, dynamic> userDetails) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      String userId = userCredential.user!.uid;

      // Add user details to users collection
      await _firestore.collection('users').doc(userId).set(userDetails);
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        // Handle the case where the email is already in use
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(email).get();
        if (userDoc.exists) {
          // The user already exists, so just update their details
          await _firestore.collection('users').doc(email).update(userDetails);
        } else {
          print(
              'Error: email already in use but no corresponding user document found.');
        }
      } else {
        print('Error creating user account: $e');
        throw e;
      }
    }
  }

  // Stream of user projects
  Stream<QuerySnapshot> getUserProjects() {
    return _firestore.collection('projects').snapshots();
  }
}
