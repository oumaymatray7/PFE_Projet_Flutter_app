import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/smart_recurtement/models/applicant.dart';
import 'package:mobile_app/smart_recurtement/models/company.dart';

class RecruitmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addCompany(Company company) async {
    try {
      await _firestore.collection('companies').add(company.toMap());
    } catch (e) {
      print('Error adding company: $e');
      throw Exception('Error adding company: $e');
    }
  }

  Future<void> updateCompany(String companyId, Company company) async {
    try {
      await _firestore
          .collection('companies')
          .doc(companyId)
          .update(company.toMap());
    } catch (e) {
      print('Error updating company: $e');
      throw Exception('Error updating company: $e');
    }
  }

  Future<void> deleteCompany(String companyId) async {
    try {
      await _firestore.collection('companies').doc(companyId).delete();
    } catch (e) {
      print('Error deleting company: $e');
      throw Exception('Error deleting company: $e');
    }
  }

  Future<void> addApplicantToCompany(
      String companyName, Applicant applicant) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('companies')
          .where('companyName', isEqualTo: companyName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot companyDoc = querySnapshot.docs.first;
        await companyDoc.reference.update({
          'applicants': FieldValue.arrayUnion([applicant.toMap()]),
        });
      }
    } catch (e) {
      print('Error adding applicant: $e');
      throw e;
    }
  }

  Future<List<Company>> fetchAllCompanies() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('companies').get();
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Company.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching companies: $e');
      throw Exception('Error fetching companies: $e');
    }
  }

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

  Future<List<Company>> fetchRecentJobs() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('recentJobs').get();
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Company.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching recent jobs: $e');
      throw Exception('Error fetching recent jobs: $e');
    }
  }

  Stream<List<Company>> streamCompanies() {
    return _firestore.collection('companies').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Company.fromMap(data, doc.id);
      }).toList();
    });
  }
}
