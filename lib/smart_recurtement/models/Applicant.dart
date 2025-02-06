class Applicant {
  final String name;
  final String email;
  final String phone;
  final String coverLetter;
  final String cv;

  Applicant({
    required this.name,
    required this.email,
    required this.phone,
    required this.coverLetter,
    required this.cv,
  });

  factory Applicant.fromMap(Map<String, dynamic> map) {
    return Applicant(
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      coverLetter: map['coverLetter'] as String,
      cv: map['cv'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'coverLetter': coverLetter,
      'cv': cv,
    };
  }
}