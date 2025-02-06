import 'package:mobile_app/mail/Draft.dart';

class Email {
  final String sender;
  final String Emailsender;
  final String subject;
  final String recipient;
  final String cc;
  bool isStarred;
  final String date;
  final String senderImagePath;
  final String message;
  final EmailType type;

  Email(
      {required this.sender,
      required this.Emailsender,
      required this.cc,
      required this.subject,
      required this.isStarred,
      required this.recipient,
      required this.senderImagePath,
      required this.date,
      required this.message,
      required this.type});
}

enum EmailType { important, personal, company, private }
