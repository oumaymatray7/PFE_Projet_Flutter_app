import 'package:flutter/material.dart';
import 'package:mobile_app/mail/CompanyMail.dart';
import 'package:mobile_app/mail/Draft.dart';
import 'package:mobile_app/mail/PersonalMail.dart';
import 'package:mobile_app/mail/ImportantMail.dart';
import 'package:mobile_app/mail/PrivateMail.dart';
import 'package:mobile_app/mail/Starred.dart';
import 'package:mobile_app/mail/TrashMail.dart';
import 'package:mobile_app/mail/compose.dart';
import 'package:mobile_app/mail/inbox.dart';
import 'package:mobile_app/mail/sent.dart';
import 'package:mobile_app/mail/spam.dart';

class CircleButtonInfo {
  final String label;
  final Color color;
  final Widget destinationPage;

  CircleButtonInfo({
    required this.label,
    required this.color,
    required this.destinationPage,
  });
}

class MailHomePage extends StatefulWidget {
  @override
  _MailHomePageState createState() => _MailHomePageState();
}

class _MailHomePageState extends State<MailHomePage> {
  double imageWidth = 0;
  double imageHeight = 0;
  @override
  void initState() {
    super.initState();
    loadImageDimensions();
  }

  void loadImageDimensions() {
    AssetImage('assets/mail_box.png').resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        setState(() {
          imageWidth = info.image.width.toDouble();
          imageHeight = info.image.height.toDouble();
        });
      }),
    );
  }

  List<CircleButtonInfo> circleButtonList = [
    CircleButtonInfo(
        label: 'Personal',
        color: Colors.green,
        destinationPage: PersonalMailPage()),
    CircleButtonInfo(
        label: 'Company',
        color: Colors.blue,
        destinationPage: CompanyMailPage()),
    CircleButtonInfo(
        label: 'inportant',
        color: Colors.yellow,
        destinationPage: ImportantMailPage()),
    CircleButtonInfo(
        label: 'private',
        color: Colors.red,
        destinationPage: PrivateMailPage()),
    CircleButtonInfo(
        label: 'Trash', color: Colors.grey, destinationPage: TrashMailPage()),

    // Add other buttons as needed
  ];

  final TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // Show loading screen until image dimensions are loaded
    if (imageWidth == 0 || imageHeight == 0) {
      return Center(child: CircularProgressIndicator());
    }

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF28243D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF28243D),
        elevation: 0,
        centerTitle: true,
        title: Image.asset('assets/smartovate.png', height: 70, width: 250),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: IntrinsicHeight(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                _searchBar(),
                _mailBoxWithButtons(),
                _folderButtons(),
                _composeButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
      child: TextField(
        controller: searchController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
          hintText: 'Search (Ctrl+/)',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(Icons.search, color: Colors.white, size: 20),
          filled: true,
          fillColor: Color(0xFF312D4B),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _folderButtons() {
    return Column(
      children: <Widget>[
        _buildEmailFolderButton(
            context, Icons.inbox, 'Inbox', 3, Colors.white, InboxPage()),
        _buildEmailFolderButton(
            context, Icons.send, 'Sent', 0, Colors.white, sentPage()),
        _buildEmailFolderButton(
            context, Icons.drafts, 'Draft', 4, Colors.white, DraftPage()),
        _buildEmailFolderButton(
            context, Icons.star, 'Starred', 0, Colors.white, StarredPage()),
        _buildEmailFolderButton(context, Icons.assignment_late_sharp, 'Spam', 2,
            Colors.white, spamPage()),
        // Add more buttons as needed
      ],
    );
  }

  Widget _composeButton() {
    return Container(
      width: double.infinity, // Set the width to match the parent container
      padding: EdgeInsets.all(16), // Add some padding
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ComposeMailScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF312D4B), // Button color
          shadowColor: Colors.white, // Text color
          padding: EdgeInsets.symmetric(vertical: 16), // Vertical padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
        ),
        child: Text('Compose'),
      ),
    );
  }

  Widget _mailBoxWithButtons() {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonSize = screenWidth * 0.1;
    double relativeTop1 = imageHeight * 0.69; // Example relative positions
    double relativeLeft1 = imageWidth * 0.16;
    double relativeTop2 = imageHeight * 0.47; // Example relative positions
    double relativeLeft2 = imageWidth * 0.24;
    double relativeTop3 = imageHeight * 0.34; // Example relative positions
    double relativeLeft3 = imageWidth * 0.49;
    double relativeTop4 = imageHeight * 0.44; // Example relative positions
    double relativeLeft4 = imageWidth * 0.75;
    double relativeTop5 = imageHeight * 0.63; // Example relative positions
    double relativeLeft5 = imageWidth * 0.85;
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Image.asset('assets/mail_box.png', width: screenWidth),
        Positioned(
          top: relativeTop1,
          left: relativeLeft1,
          child: _buildCircleButton(circleButtonList[0]),
        ),
        Positioned(
          top: relativeTop2, // Example relative positions
          left: relativeLeft2,
          child: _buildCircleButton(circleButtonList[1]),
        ),
        Positioned(
          top: relativeTop3, // Example relative positions
          left: relativeLeft3,
          child: _buildCircleButton(circleButtonList[2]),
        ),
        Positioned(
          top: relativeTop4, // Example relative positions
          left: relativeLeft4,
          child: _buildCircleButton(circleButtonList[3]),
        ),
        Positioned(
          top: relativeTop5, // Example relative positions
          left: relativeLeft5,
          child: _buildCircleButton(circleButtonList[4]),
        ),
        // Add other Positioned widgets for each circular button
      ],
    );
  }

  Widget _buildCircleButton(CircleButtonInfo buttonInfo) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => buttonInfo.destinationPage),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircleAvatar(backgroundColor: buttonInfo.color),
          SizedBox(height: 4),
          Text(buttonInfo.label, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildEmailFolderButton(BuildContext context, IconData icon,
      String title, int count, Color iconColor, Widget destinationPage) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.95, // Use a percentage of the screen width
      height: 56, // Fixed height for accessibility
      margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: 5), // Responsive horizontal margin
      decoration: BoxDecoration(
        color: Color(0xFF9155FD),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.045), // Responsive font size
        ),
        trailing:
            _buildCounter(count, screenWidth * 0.03), // Responsive counter size
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => destinationPage));
        },
      ),
    );
  }

  Widget _buildCounter(int count, double size) {
    return count > 0
        ? Container(
            padding: EdgeInsets.all(size), // Use size passed as parameter
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                  color: Colors.white, fontSize: size), // Responsive font size
            ),
          )
        : SizedBox.shrink();
  }
}
