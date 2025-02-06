import 'package:mobile_app/smart_recurtement/models/applicant.dart';

class Company {
  final String? companyId;
  final String? companyName;
  final String? job;
  final String? city;
  final String? sallary;
  final String? image;
  final String? mainCriteria;
  final String? jobOpportunity;
  final String? aboutCompany;
  final List<String>? jobResponsbilities;
  final List<String>? tag;
  final List<Applicant>? applicants;

  Company({
    this.companyId,
    this.city,
    this.job,
    this.companyName,
    this.sallary,
    this.tag,
    this.image,
    this.mainCriteria,
    this.jobOpportunity,
    this.jobResponsbilities,
    this.aboutCompany,
    this.applicants,
  });

  factory Company.fromMap(Map<String, dynamic> map, String id) {
    return Company(
      companyId: id,
      companyName: map['companyName'] as String?,
      job: map['job'] as String?,
      city: map['city'] as String?,
      sallary: map['sallary'] as String?,
      image: map['image'] as String?,
      mainCriteria: map['mainCriteria'] as String?,
      jobOpportunity: map['jobOpportunity'] as String?,
      aboutCompany: map['aboutCompany'] as String?,
      jobResponsbilities: List<String>.from(map['jobResponsbilities'] ?? []),
      tag: List<String>.from(map['tag'] ?? []),
      applicants: (map['applicants'] as List<dynamic>?)
          ?.map((e) => Applicant.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'job': job,
      'city': city,
      'sallary': sallary,
      'image': image,
      'mainCriteria': mainCriteria,
      'jobOpportunity': jobOpportunity,
      'aboutCompany': aboutCompany,
      'jobResponsbilities': jobResponsbilities,
      'tag': tag,
      'applicants': applicants?.map((e) => e.toMap()).toList(),
    };
  }
}
