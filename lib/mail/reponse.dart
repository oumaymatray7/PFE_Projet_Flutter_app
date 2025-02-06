import 'package:flutter/material.dart';
import 'package:mobile_app/mail/email.dart'; // Ensure correct import

class Reply extends StatefulWidget {
  final Email email;

  Reply({required this.email});

  @override
  _ReplyState createState() => _ReplyState();
}

class _ReplyState extends State<Reply> {
  final TextEditingController toController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    toController.text = widget.email.sender; // Pre-fill the 'To' field
    subjectController.text =
        'Re: ${widget.email.subject}'; // Pre-fill the 'Subject' field with a reply prefix
  }

  void sendReply() {
    print('Reply sent to: ${toController.text}');
    // Integrate with your backend or email service here to send the email
    Navigator.of(context).pop(); // Optionally pop the screen after sending
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF28243D),
      appBar: AppBar(
        title: Text('Reply to: ${widget.email.subject}'),
        backgroundColor: Color(0xFF9155FD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            buildReadOnlyEmailField(
                'From: ${widget.email.Emailsender}', widget.email.message),
            SizedBox(height: 16.0),
            buildTextField(
                controller: toController, labelText: 'To', isEnabled: false),
            buildTextField(controller: subjectController, labelText: 'Subject'),
            buildTextField(
                controller: messageController,
                labelText: 'Message',
                maxLines: 10),
            ElevatedButton(onPressed: sendReply, child: Text('Send Reply')),
          ],
        ),
      ),
    );
  }

  Widget buildReadOnlyEmailField(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 8.0),
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4.0)),
          child: Text(content, style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  Widget buildTextField(
      {required TextEditingController controller,
      required String labelText,
      bool isEnabled = true,
      int maxLines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white),
        hintText: 'Enter text',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        disabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        border:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
      ),
      maxLines: maxLines,
      enabled: isEnabled,
      style: TextStyle(color: Colors.white),
    );
  }
}
