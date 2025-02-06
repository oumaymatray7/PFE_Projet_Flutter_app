class Employee {
  final String id;
  final String name;
  final String email;
  final String jobTitle;
  final String phoneNumber;
  final String country;
  final String imagePath;
  final String role;
  final String language;
  final String firstName;
  final String lastName;
  final Map<String, Map<String, String>> workingHours;
  final List<String> projectIds;
  final List<Map<String, dynamic>> projects;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.jobTitle,
    required this.phoneNumber,
    required this.country,
    required this.imagePath,
    required this.role,
    required this.language,
    required this.firstName,
    required this.lastName,
    required this.workingHours,
    required this.projectIds,
    required this.projects,
  });

  factory Employee.fromMap(Map<String, dynamic> data, String id) {
    return Employee(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      jobTitle: data['jobTitle'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      country: data['country'] ?? '',
      imagePath: data['imagePath'] ?? 'assets/placeholder.jpg',
      role: data['role'] ?? '',
      language: data['language'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      workingHours: (data['workingHours'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              Map<String, String>.from(value as Map<String, dynamic>),
            ),
          ) ??
          {},
      projectIds: List<String>.from(data['projectIds'] ?? []),
      projects: List<Map<String, dynamic>>.from(data['projects'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
      'projectIds': projectIds,
      'projects': projects,
    };
  }
}

class WorkingHour {
  final String day;
  final String checkIn;
  final String checkOut;

  WorkingHour({
    required this.day,
    required this.checkIn,
    required this.checkOut,
  });

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'checkIn': checkIn,
      'checkOut': checkOut,
    };
  }
}
