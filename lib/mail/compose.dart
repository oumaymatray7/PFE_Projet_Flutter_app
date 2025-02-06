import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile_app/components/button.dart';
import 'package:url_launcher/url_launcher.dart';

class ComposeMailScreen extends StatefulWidget {
  @override
  _ComposeMailScreenState createState() => _ComposeMailScreenState();
}

class _ComposeMailScreenState extends State<ComposeMailScreen> {
  final TextEditingController messageController = TextEditingController();
  TextStyle currentStyle = TextStyle(color: Colors.white);
  final TextEditingController toController = TextEditingController();
  final TextEditingController ccController = TextEditingController();
  final TextEditingController bccController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();

  // Placeholder function to mimic sending an email

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;

      // Check if the message already contains some text
      String currentText = messageController.text;
      if (currentText.isNotEmpty) {
        currentText += '\n'; // Add a new line before the file name
      }

      // Append the file name or path to the message text
      messageController.text =
          '$currentText${file.name}'; // Use file.path for full file path

      // Optionally, if you want to move the cursor to the end of the text
      messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: messageController.text.length),
      );
    } else {
      // User canceled the picker
    }
  }

  void sendEmail() async {
    final String to = toController.text.trim();
    final String cc = ccController.text.trim();
    final String bcc = bccController.text.trim();
    final String subject = Uri.encodeComponent(subjectController.text.trim());
    final String body = Uri.encodeComponent(messageController.text.trim());

    // Constructing the mailto URI
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: to.isNotEmpty ? to : null, // Only add to the path if it's not empty
      query: to.isNotEmpty
          ? {
              if (cc.isNotEmpty) 'cc': cc,
              if (bcc.isNotEmpty) 'bcc': bcc,
              'subject': subject,
              'body': body
            }.entries.map((e) => '${e.key}=${e.value}').join('&')
          : null,
    );

    final String emailLaunchUriString = emailLaunchUri.toString();

    if (await canLaunch(emailLaunchUriString)) {
      await launch(emailLaunchUriString);
    } else {
      // Display an alert or a Toast if the email client cannot be opened
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch email client.'),
        ),
      );
    }
  }

  String selectedFormatAction = '';

  void onFormatButtonPressed(String formatAction) {
    setState(() {
      // Toggle the current style with the new action
      if (selectedFormatAction != formatAction) {
        selectedFormatAction = formatAction;
      } else {
        selectedFormatAction = '';
      }

      // Start with a white text color for the current style
      currentStyle = TextStyle(color: Colors.white);

      if (selectedFormatAction == 'bold') {
        currentStyle = currentStyle.copyWith(fontWeight: FontWeight.bold);
      } else if (selectedFormatAction == 'italic') {
        currentStyle = currentStyle.copyWith(fontStyle: FontStyle.italic);
      } else if (selectedFormatAction == 'underline') {
        currentStyle =
            currentStyle.copyWith(decoration: TextDecoration.underline);
      } else if (selectedFormatAction == 'strikethrough') {
        currentStyle =
            currentStyle.copyWith(decoration: TextDecoration.lineThrough);
      }

      // Apply the current style along with the white text color to the messageController
      messageController.value = messageController.value.copyWith(
        text: messageController.text,
        selection: messageController.selection,
        composing: TextRange.empty,
      );
    });
  }

  Widget formatButton(IconData icon, String formatAction) {
    bool isSelected = selectedFormatAction == formatAction;
    Color backgroundColor = isSelected ? Color(0xFFC5A5FE) : Colors.transparent;

    return IconButton(
      icon: Icon(icon, color: isSelected ? Colors.white : Colors.grey),
      onPressed: () => onFormatButtonPressed(formatAction),
      // Apply a color filter if the button is selected
      color: isSelected ? Color(0xFFC5A5FE) : Colors.grey,
    );
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the widget tree
    toController.dispose();
    ccController.dispose();
    bccController.dispose();
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF28243D),
      appBar: AppBar(
        title: Text('Compose Mail'),
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
            icon: Icon(Icons.send),
            onPressed: sendEmail,
          ),
          FloatingActionButton(
            onPressed: pickFile,
            tooltip: 'Attach File',
            child: Icon(Icons.attach_file),
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Confirm"),
                    content: Text("Choose an action"),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                          Navigator.of(context)
                              .pop(); // Optional: go back to the previous screen
                        },
                      ),
                      TextButton(
                        child: Text('Continue Writing'),
                        onPressed: () {
                          Navigator.of(context).pop(); // Just close the dialog
                        },
                      ),
                      TextButton(
                        child: Text('Delete'),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Confirm Delete"),
                                content: Text(
                                    "Are you sure you want to delete this draft?"),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('No'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Yes'),
                                    onPressed: () {
                                      // Add your delete logic here
                                      Navigator.of(context)
                                          .pop(); // Close the confirm dialog
                                      Navigator.of(context)
                                          .pop(); // Close the compose mail screen
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          // Using ListView to make the form scrollable
          children: <Widget>[
            buildTextField(
              controller: toController,
              labelText: 'To',
              hint: 'Enter recipient email',
              labelStyle: TextStyle(color: Colors.white),
              hintStyle: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 8.0),
            buildTextField(
              controller: ccController,
              labelText: 'Cc',
              hint: 'Enter cc email',
              labelStyle: TextStyle(color: Colors.white),
              hintStyle: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 8.0),
            buildTextField(
              controller: bccController,
              labelText: 'Bcc',
              hint: 'Enter bcc email',
              labelStyle: TextStyle(color: Colors.white),
              hintStyle: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 8.0),
            buildTextField(
              controller: subjectController,
              labelText: 'Subject',
              hint: 'Enter subject',
              labelStyle: TextStyle(color: Colors.white),
              hintStyle: TextStyle(color: Colors.black),
            ),
            Wrap(
              children: <Widget>[
                formatButton(Icons.format_bold, 'bold'),
                formatButton(Icons.format_italic, 'italic'),
                formatButton(Icons.format_underline, 'underline'),
                formatButton(Icons.format_strikethrough, 'strikethrough'),
                formatButton(Icons.format_align_left, 'align_left'),
                formatButton(Icons.format_align_center, 'align_center'),
                formatButton(Icons.format_align_right, 'align_right'),

                // Add more buttons as needed
              ],
            ),
            SizedBox(height: 8.0),
            buildTextField(
              controller: messageController,
              labelText: 'Message',
              hint: 'Enter your message here',
              maxLines: 10, // Allows for multiline input
              labelStyle: TextStyle(color: Colors.white),
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hint,
    required labelStyle,
    required hintStyle,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: currentStyle,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hint,
        labelStyle: labelStyle,
        hintStyle: hintStyle,
        border: OutlineInputBorder(),
      ),
    );
  }
}
