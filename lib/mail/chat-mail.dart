import 'package:flutter/material.dart';

import 'package:mobile_app/mail/compose.dart';
import 'package:mobile_app/mail/reponse.dart';
import 'package:mobile_app/mail/email.dart';

class EmailViewScreen extends StatefulWidget {
  final Email email;

  EmailViewScreen({Key? key, required this.email}) : super(key: key);

  @override
  _EmailViewScreenState createState() => _EmailViewScreenState();
}

// The EmailViewScreenState class that manages the state of the EmailViewScreen
class _EmailViewScreenState extends State<EmailViewScreen> {
  void replyy() {
    Navigator.of(context)
        .pop(); // This will just go back to the previous screen
  }

  void forward() {
    // Navigate to compose screen with forward content
    navigateToComposeScreen(
        subject: "Fwd: ${widget.email.subject}", body: widget.email.message);
  }

  void showDeletionConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () {
                // Implement delete functionality
                confirmDelete(context);
              },
            ),
          ],
        );
      },
    );
  }

  void confirmDelete(BuildContext context) {
    // Confirmation dialog before deletion
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                // Perform the deletion or reset operation here
                // For example:
                print('Item deleted');
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Close the bottom sheet
              },
            ),
          ],
        );
      },
    );
  }

  void navigateToComposeScreen({
    String recipient = '',
    List<String>? recipients,
    String subject = '',
    String body = '',
  }) {
    // Assuming you have a ComposeMailScreen that takes these arguments
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComposeMailScreen(
            //to: recipient,
            //cc: recipients!.join(', '), // Handle multiple recipients if needed
            //subject: subject,
            //body: body,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF28243D),
      appBar: AppBar(
        title: Text(widget.email.subject),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(145, 85, 253, 0.5),
                Color.fromRGBO(197, 165, 254, 0.5),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.reply),
            onPressed: replyy,
          ),
          IconButton(
            icon: Icon(Icons.reply_all),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Reply(
                    email: widget.email,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => showDeletionConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Using a SingleChildScrollView for a long email body
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(color: Colors.grey), // Separators
            _buildEmailRow('From:', widget.email.Emailsender),
            Divider(color: Colors.grey), // Separators
            _buildEmailRow('To:', widget.email.recipient),
            Divider(color: Colors.grey), // Separators
            _buildEmailRow('Date:', widget.email.date),
            Divider(color: Colors.grey), // Separators
            _buildEmailRow('Subject:', widget.email.subject),
            Divider(color: Colors.grey), // Separators
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                widget.email.message,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailRow(String label, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
