import 'package:flutter/material.dart';
import 'package:mobile_app/mail/chat-mail.dart';

import 'package:mobile_app/mail/email.dart';
//... rest of your code

class TrashMailPage extends StatefulWidget {
  @override
  _TrashMailPageState createState() => _TrashMailPageState();
}

class _TrashMailPageState extends State<TrashMailPage> {
  TextEditingController searchController = TextEditingController();
  List<Email> trashEmails = [];
  List<Email> filteredEmails = [];
  int? selectedEmailIndex;
  Set<int> selectedEmailIndices =
      {}; // Using a Set to allow multiple selections
  @override
  void initState() {
    super.initState();
    fetchEmails();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    // Unsubscribe from streams if used
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void fetchEmails() async {
    await Future.delayed(Duration(seconds: 2));
    if (mounted) {
      // Check if the widget is still in the tree
      setState(() {
        trashEmails = [
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
            type: EmailType.private, cc: '', recipient: '', date: '',
            message: '',
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
            type: EmailType.company, cc: '', recipient: '', date: '',
            message: '',
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

        filteredEmails = List.from(trashEmails);
      });
    }
  }

  void _onSearchChanged() {
    if (searchController.text.isEmpty) {
      setState(() {
        filteredEmails = List.from(
            trashEmails); // Show all emails if the search bar is empty
      });
    } else {
      setState(() {
        filteredEmails = trashEmails.where((email) {
          return email.sender.toLowerCase().contains(searchController.text
              .toLowerCase()); // Filter emails by sender name
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF28243D),
      appBar: AppBar(
          title: Text('Trash'),
          backgroundColor: Color(0xFF9155FD),
          actions: [
            // ... (Any other actions)
            PopupMenuButton<String>(
              onSelected: (String value) {
                switch (value) {
                  case 'Select All':
                    setState(() {
                      selectedEmailIndices.addAll(
                        List.generate(filteredEmails.length, (index) => index),
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
                                    trashEmails.removeAt(index);
                                  });
                                  selectedEmailIndices.clear();
                                  filteredEmails = List.from(trashEmails);
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
      body: Column(
        children: <Widget>[
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
          _buildEmailList(),
        ],
      ),
    );
  }

  Widget _buildEmailList() {
    return Expanded(
      child: ListView.builder(
        itemCount: filteredEmails.length,
        itemBuilder: (context, index) {
          final email = filteredEmails[index];
          bool isSelected = selectedEmailIndices.contains(index);

          return _buildEmailItem(email, isSelected, index);
        },
      ),
    );
  }

  Widget _buildEmailItem(Email email, bool isSelected, int index) {
    Color getTypeColor(EmailType type) {
      switch (type) {
        case EmailType.important:
          return Colors.yellow;
        case EmailType.personal:
          return Colors.green;
        case EmailType.company:
          return Colors.blue;
        case EmailType.private:
          return Colors.red;
        default:
          return Colors.transparent;
      }
    }

    return ListTile(
      tileColor: isSelected
          ? Color(0xFF9155FD)
          : Colors.transparent, // Change tile color when selected
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            email.isStarred ? Icons.star : Icons.star_border,
            color: email.isStarred ? Colors.yellow : Colors.grey,
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundImage: AssetImage(email.senderImagePath),
          ),
        ],
      ),
      title: Text(email.sender, style: TextStyle(color: Colors.white)),
      subtitle: Text(email.subject,
          style: TextStyle(color: Colors.white.withOpacity(0.5))),
      trailing: Container(
        height: 12,
        width: 12,
        decoration: BoxDecoration(
          color: getTypeColor(email.type), // Use the method to get color
          shape: BoxShape.circle,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmailViewScreen(email: email),
          ),
        );
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
    );
  }
}
