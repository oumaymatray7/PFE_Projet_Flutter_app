class CompteUser {
  String uid;
  String name;
  String email;
  String firstName;
  String lastName;
  String country;
  String phoneNumber;
  String jobTitle;
  String role;
  String language;
  String imagePath;
  Map<String, Map<String, String>> workingHours;

  CompteUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.phoneNumber,
    required this.jobTitle,
    required this.role,
    required this.language,
    required this.imagePath,
    required this.workingHours,
  });

  factory CompteUser.fromMap(Map<String, dynamic> map) {
    return CompteUser(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      country: map['country'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      role: map['role'] ?? '',
      language: map['language'] ?? '',
      imagePath: map['imageUrl'] ?? 'assets/Ellipse 10.png',
      workingHours: (map['workingHours'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          Map<String, String>.from(value as Map),
        ),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'country': country,
      'phoneNumber': phoneNumber,
      'jobTitle': jobTitle,
      'role': role,
      'language': language,
      'imagePath': imagePath,
      'workingHours': workingHours,
    };
  }
}
