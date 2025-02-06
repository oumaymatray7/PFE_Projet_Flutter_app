import 'dart:async';
import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mobile_app/auth/Reset%20Password.dart';
import 'package:mobile_app/compteUser/model.dart';

class AuthenticationService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore; // Declare the FirebaseFirestore instance.
  String? _verificationId;
  int? _resendToken; // Stores the resend token from Firebase

  AuthenticationService(this._firebaseAuth)
      : _firestore = FirebaseFirestore.instance;

  void handleAuthException(FirebaseAuthException e) {
    String message = 'Authentication failed: ${e.message}';
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found for that email.';
        break;
      case 'wrong-password':
        message = 'Wrong password provided for that user.';
        break;
      case 'too-many-requests':
        message = 'Too many requests. Please try again later.';
        break;
      case 'invalid-email':
        message = 'The email address is badly formatted.';
        break;
    }
  }

  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> sendEmailVerification() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> reloadUser() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }

  bool isEmailVerified() {
    User? user = _firebaseAuth.currentUser;
    return user?.emailVerified ?? false;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      debugPrint('Error: Email and password must not be empty.');
      return false;
    }

    if (!EmailValidator.validate(email)) {
      debugPrint('Error: Invalid email format.');
      return false;
    }

    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (userCredential.user != null) {
        debugPrint('Login successful: User is logged in.');
        return true;
      } else {
        debugPrint('Login failed: User credential returned null.');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      handleAuthException(e);
      return false;
    } catch (e) {
      debugPrint('General Exception: $e');
      return false;
    }
  }

  Future<bool> checkUserExists(String email) async {
    try {
      List<String> signInMethods =
          await _firebaseAuth.fetchSignInMethodsForEmail(email);
      return signInMethods.isNotEmpty;
    } catch (e) {
      print("Error checking if user exists: $e");
      return false;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    } else {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'No user is currently signed in.',
      );
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );
    return await _firebaseAuth.signInWithCredential(credential);
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

  Future<void> registerWithEmailAndPassword(String email, String password,
      {required String name,
      required String jobTitle,
      required String country,
      String? photoPath}) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? newUser = userCredential.user;
      if (newUser != null) {
        await newUser.sendEmailVerification(); // Send verification email
        debugPrint("Verification email sent.");

        // Continue with the rest of the registration process
        String? photoUrl;
        if (photoPath != null) {
          File imageFile = File(photoPath);
          try {
            UploadTask task = FirebaseStorage.instance
                .ref('user_images/${newUser.uid}/profile.jpg')
                .putFile(imageFile);
            TaskSnapshot snapshot = await task;
            photoUrl = await snapshot.ref.getDownloadURL();
          } catch (e) {
            print("Failed to upload photo: $e");
          }
        }

        CompteUser user = CompteUser(
          uid: newUser.uid,
          name: name,
          email: email,
          firstName: '',
          lastName: '',
          country: country,
          phoneNumber: '',
          jobTitle: jobTitle,
          role: 'User',
          language: 'English',
          imagePath: photoUrl ?? '',
          workingHours: {},
        );

        DocumentReference userDoc =
            _firestore.collection('users').doc(newUser.uid);
        await userDoc.set(user.toMap());
      } else {
        throw FirebaseAuthException(
            code: "USER_CREATION_FAILED",
            message: "Failed to create a new user.");
      }
    } on FirebaseAuthException catch (e) {
      handleAuthException(e);
      throw e; // Rethrow the exception to handle it in UI
    }
  }

  Future<void> signInWithCredential(AuthCredential credential) async {
    await _firebaseAuth.signInWithCredential(credential);
  }

  Future<bool> enableTwoFactorAuthentication() async {
    // Your logic to enable 2FA in Firebase
    return true;
  }

  Future<bool> disableTwoFactorAuthentication() async {
    // Your logic to disable 2FA in Firebase
    return true;
  }

  Future<bool> isTwoFactorEnabled() async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(_firebaseAuth.currentUser!.uid)
          .get();
      Map<String, dynamic> data =
          userDoc.data() as Map<String, dynamic>; // Safely cast to a Map
      return data['twoFactorEnabled'] ?? false;
    } catch (e) {
      print('Failed to fetch 2FA status: $e');
      return false;
    }
  }

  Future<void> phoneAuthentication(
    String phoneNumber, {
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<bool> verifyOTP(String verificationId, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user != null;
    } catch (e) {
      return false;
    }
  }

  Future<DocumentSnapshot> _getUserDocument() async {
    return _firestore
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .get();
  }

  Future<void> sendOTP(String phoneNumber) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        handleAuthException(e);
        throw e;
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> resendOTP(String phoneNumber) async {
    if (_resendToken == null) {
      throw Exception("Resend token is not available.");
    }
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 120),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        handleAuthException(e);
        throw e;
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
      },
      forceResendingToken: _resendToken,
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      User? user = _firebaseAuth.currentUser;
      AuthCredential credentials = EmailAuthProvider.credential(
          email: user!.email!, password: currentPassword);
      await user.reauthenticateWithCredential(credentials);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      handleAuthException(e);
      throw Exception(e.message);
    }
  }

  String? getVerificationId() {
    return _verificationId;
  }
}

class AuthController extends GetxController {
  String? verificationId;

  void updateVerificationId(String newVerificationId) {
    verificationId = newVerificationId;
    update();
  }
}
