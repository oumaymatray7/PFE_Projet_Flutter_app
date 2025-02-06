import 'package:flutter/material.dart';
import 'package:mobile_app/mail/Draft.dart';
import 'package:mobile_app/mail/chat-mail.dart';
import 'package:mobile_app/mail/reponse.dart';
import 'package:mobile_app/mail/email.dart';
// Define an Email data model

class PersonalMailPage extends StatefulWidget {
  @override
  _PersonalMailPageState createState() => _PersonalMailPageState();
}

class _PersonalMailPageState extends State<PersonalMailPage> {
  TextEditingController searchController = TextEditingController();
  // This list would actually come from your backend
  List<Email> emails = [];
  List<Email> filteredEmails = [];
  Set<int> selectedEmailIndices = {};

  @override
  void initState() {
    super.initState();
    fetchEmails();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  // Placeholder for an async function to fetch personal emails
  void fetchEmails() async {
    setState(() {
      emails = [
        Email(
          sender: 'Joaquina Weisenborn',
          subject: 'lorem ipsum lorem ipsum lorem ipsum',
          isStarred: true,
          senderImagePath:
              'assets/Ellipse 10.png', // Ensure this is the correct path for the avatar image
          type: EmailType.private,
          cc: '',
          recipient: '',
          date: '',
          message: '',
          Emailsender:
              'JoaquinaWeisenborn@gmail.com', // The type should match the email category, here it is 'trash'
        ),
        Email(
          sender: 'Felecia Rower',
          subject: 'lorem ipsum lorem ipsum lorem ipsum',
          isStarred: false,
          senderImagePath:
              'assets/Ellipse 11.png', // Correct path for avatar image
          type: EmailType.private, cc: '', recipient: '', date: '', message: '',
          Emailsender: 'FeleciaRower@gmail.com',

          /// Email type is 'trash'
        ),
        // Add more Email objects with their corresponding images and types
        Email(
          sender: 'Sal Piggee',
          subject: 'lorem ipsum lorem ipsum lorem ipsum',
          isStarred: false,
          senderImagePath:
              'assets/Ellipse 12.png', // Update the asset path as needed
          type: EmailType.company, cc: '', recipient: '', date: '', message: '',
          Emailsender: 'SalPiggee]@cc.com',
        ),
        Email(
          sender: 'Verla Morgano',
          subject: 'lorem ipsum lorem ipsum lorem ipsum',
          isStarred: true,
          senderImagePath:
              'assets/Ellipse 13.png', // Update the asset path as needed
          type: EmailType.personal, cc: '', recipient: '', date: '',
          message: '', Emailsender: 'VerlaMorgano@gmail.com',
        ),
        Email(
          sender: 'Mauro Elenbaas',
          subject: 'lorem ipsum lorem ipsum lorem ipsum',
          isStarred: false,
          senderImagePath:
              'assets/Ellipse 14.png', // Update the asset path as needed
          type: EmailType.personal, cc: '', recipient: '', date: '',
          message: '', Emailsender: 'MauroElenbaas@gmail.com',
        ),
        Email(
          sender: 'Miguel Guelff',
          subject: 'lorem ipsum lorem ipsum lorem ipsum',
          isStarred: true,
          senderImagePath:
              'assets/Ellipse 15.png', // Update the asset path as needed
          type: EmailType.important, cc: '', recipient: '', date: '',
          message: '', Emailsender: 'MiguelGuelff@gmail.com',
        ),
      ];
      filteredEmails = emails;
    });
  }

  void _onSearchChanged() {
    String searchTerm = searchController.text.toLowerCase();
    setState(() {
      if (searchTerm.isEmpty) {
        filteredEmails = emails; // If search term is empty, show all emails
      } else {
        filteredEmails = emails.where((email) {
          // Filter emails based on the search term
          return email.sender.toLowerCase().contains(searchTerm);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF28243D), // The background color for the page
        appBar: AppBar(
            title: Text('Personal'),
            backgroundColor: Color(0xFF9155FD), // The header color in the image
            actions: [
              // ... (Any other actions)
              PopupMenuButton<String>(
                onSelected: (String value) {
                  switch (value) {
                    case 'Select All':
                      setState(() {
                        selectedEmailIndices.addAll(
                          List.generate(
                              filteredEmails.length, (index) => index),
                        );
                      });
                      break;
                    case 'Delete':
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // Return a dialog for confirmation
                          return AlertDialog(
                            title: Text('Confirm Delete'),
                            content: Text(
                                'Are you sure you want to delete the selected emails?'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Dismiss the dialog
                                },
                              ),
                              TextButton(
                                child: Text('Delete'),
                                onPressed: () {
                                  setState(() {
                                    selectedEmailIndices
                                        .toList()
                                        .reversed
                                        .forEach((index) {
                                      emails.removeAt(index);
                                    });
                                    selectedEmailIndices.clear();
                                    filteredEmails = List.from(emails);
                                  });
                                  Navigator.of(context)
                                      .pop(); // Dismiss the dialog
                                },
                              ),
                            ],
                          );
                        },
                      );
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'Select All',
                    child: Text('Select All'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Delete',
                    child: Text('Delete'),
                  ),
                ],
                icon: Icon(Icons.more_vert), // Icon for the button
              ),
            ]),
        body: Column(children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: searchController,
              style: TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search (Ctrl+/)',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: Colors.white, size: 20),
                filled: true,
                fillColor: Color(0xFF312D4B),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredEmails.length,
              itemBuilder: (context, index) {
                final email = filteredEmails[index];
                bool isSelected = selectedEmailIndices
                    .contains(index); // Check if the email is selected

                return ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          email.isStarred ? Icons.star : Icons.star_border,
                          color: email.isStarred ? Colors.yellow : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            email.isStarred = !email.isStarred;
                          });
                        },
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        backgroundImage: AssetImage(email.senderImagePath),
                      ),
                    ],
                  ),
                  title:
                      Text(email.sender, style: TextStyle(color: Colors.white)),
                  subtitle: Text(email.subject,
                      style: TextStyle(color: Colors.white.withOpacity(0.5))),
                  trailing: Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      color: Colors.orange, // Indicate it's a personal email
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFF28243D), width: 2),
                    ),
                  ),
                  onTap: () {
                    if (selectedEmailIndices.contains(index)) {
                      // If already selected, deselect it
                      setState(() {
                        selectedEmailIndices.remove(index);
                      });
                    } else {
                      // If not selected, select it and navigate
                      setState(() {
                        selectedEmailIndices.add(index);
                      });
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EmailViewScreen(email: email),
                        ),
                      );
                    }
                  },
                  onLongPress: () {
                    setState(() {
                      if (isSelected) {
                        selectedEmailIndices.remove(index);
                      } else {
                        selectedEmailIndices.add(index);
                      }
                    });
                  },
                  tileColor: isSelected
                      ? Colors.grey[200]
                      : null, // Change color when selected
                );
              },
            ),
          ),
        ]));
  }
}
