// Starred.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/mail/chat-mail.dart';

import 'package:mobile_app/mail/email.dart';

class StarredPage extends StatefulWidget {
  @override
  _StarredPageState createState() => _StarredPageState();
}

class _StarredPageState extends State<StarredPage> {
  TextEditingController searchController = TextEditingController();
  static List<Email> StarredEmails = [];
  List<Email> filteredEmails = [];
  Set<int> selectedEmailIndices =
      {}; // Using a Set to allow multiple selections

  int?
      selectedEmailIndex; // Stocke l'indice de l'e-mail sélectionné// Using a Set to allow multiple selections

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

  void _onSearchChanged() {
    setState(() {
      filteredEmails = searchController.text.isEmpty
          ? StarredEmails
          : StarredEmails.where((email) =>
                  email.sender
                      .toLowerCase()
                      .contains(searchController.text.toLowerCase()) &&
                  email.isStarred // Ensure only starred emails are included
              ).toList();
    });
  }

  void fetchEmails() async {
    // Simulate a network call to fetch emails
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      StarredEmails = [
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
      ].where((email) => email.isStarred).toList(); // Filter for starred emails
      filteredEmails = List.from(StarredEmails);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color(0xFF28243D), // Set the background color for the entire page
      appBar: AppBar(
          title: Row(
            children: [
              Image.asset('assets/starred.png',
                  height: 24), // Your Starred icon
              SizedBox(width: 8),
              Text('Starred'),
            ],
          ),
          backgroundColor: Color(0xFF9155FD), // AppBar background color
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
                                    StarredEmails.removeAt(index);
                                  });
                                  selectedEmailIndices.clear();
                                  filteredEmails = List.from(StarredEmails);
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
          _buildSearchBar(),
          _buildEmailList(),
        ],
      ),
    );
  }

  Widget _buildEmailItem(Email email, bool isSelected, int index) {
    Color getTypeColor(EmailType type) {
      switch (type) {
        case EmailType.important:
          return Colors.red;
        case EmailType.personal:
          return Colors.green;
        case EmailType.company:
          return Colors.blue;
        case EmailType.private:
          return Colors.orange;
        default:
          return Colors.transparent;
      }
    }

    return Card(
      color: isSelected ? Color(0xFF9155FD) : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(email.isStarred ? Icons.star : Icons.star_border,
                  color: email.isStarred ? Colors.yellow : Colors.grey),
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
        title: Text(email.sender, style: TextStyle(color: Colors.white)),
        subtitle: Text(email.subject,
            style: TextStyle(color: Colors.white.withOpacity(0.5))),
        trailing: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: getTypeColor(email.type),
            shape: BoxShape.circle,
          ),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EmailViewScreen(email: email),
              ));
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
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
        onChanged: (value) {
          // Call the search filter function
          _onSearchChanged();
        },
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
            title: Text(email.sender, style: TextStyle(color: Colors.white)),
            subtitle: Text(email.subject,
                style: TextStyle(color: Colors.white.withOpacity(0.5))),
            trailing: Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                color: Colors.orange, // Could be dynamic based on email type
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFF28243D), width: 2),
              ),
            ),
            onTap: () {
              // Navigate to EmailViewScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmailViewScreen(email: email),
                ),
              );
            },
            tileColor: isSelected ? Colors.grey[200] : null,
          );
        },
      ),
    );
  }

// Implement the _buildEmailItem method as shown in previous code examples

  Color _getTypeColor(EmailType type) {
    switch (type) {
      case EmailType.important:
        return Colors.red;
      case EmailType.personal:
        return Colors.green;
      case EmailType.company:
        return Colors.blue;
      case EmailType.private:
        return Colors.orange;
      default:
        return Colors.transparent;
    }
  }
}
