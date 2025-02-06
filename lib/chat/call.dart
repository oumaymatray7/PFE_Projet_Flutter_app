import 'package:flutter/material.dart';
import 'package:mobile_app/chat/vedio.dart';

class CallPage extends StatefulWidget {
  final String name;
  final String title;
  final String imageAsset;

  CallPage({
    Key? key,
    required this.name,
    required this.title,
    required this.imageAsset,
  }) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  double iconSize = 48; // Adjust based on your design

  // Example functions for button actions. You will need to implement these.
  bool isMuted = false; // Add this variable to track the mute state

  void onMutePressed() {
    setState(() {
      // Toggle the mute state
      isMuted = !isMuted;
    });
  }

  bool isVoiceEnabled = true; // Add this variable to track the voice state

  void onKeyboardPressed() {
    setState(() {
      // Toggle the voice state
      isVoiceEnabled = !isVoiceEnabled;
    });
  }

  void onVideoPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPage(
          name: widget.name,
          title: widget.title,
          imageAsset: widget.imageAsset,
        ),
      ),
    );
  }

  void onHangupPressed() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFC5A5FE), // Call page background color
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Spacer(),
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 125, // Avatar size
            backgroundImage: AssetImage(
                'assets/ellipse1.png'), // The path to your image asset for the background
            child: CircleAvatar(
              radius:
                  110, // Slightly smaller than the above to create a border effect
              backgroundImage: AssetImage(widget.imageAsset), // Profile image
            ),
          ),
          SizedBox(height: 16), // Space between avatar and text
          Text(
            widget.name, // User name passed as parameter
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          Text(
            widget.title, // User title passed as parameter
            style: TextStyle(
              color: Colors.white.withOpacity(0.85), // Semi-transparent white
              fontSize: 18,
            ),
          ),
          Spacer(flex: 2),
          // Action buttons will move to the bottom of the screen as elements are added
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Rectangle 7.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceAround, // Align buttons with equal spacing
              children: <Widget>[
                IconButton(
                  icon: isMuted
                      ? Image.asset(
                          'assets/haut_parleur.png') // Speaker icon when muted
                      : Image.asset(
                          'assets/mute.png'), // Mute icon when not muted
                  iconSize: iconSize,
                  onPressed: onMutePressed,
                ),
                IconButton(
                  icon: isVoiceEnabled
                      ? Icon(
                          Icons.mic_none_outlined,
                          color: Colors.white,
                        ) // Voice enabled icon
                      : Icon(Icons.mic_off,
                          color: Colors.white), // Voice disabled icon
                  iconSize: iconSize,
                  onPressed: onKeyboardPressed,
                ),
                IconButton(
                  icon: Image.asset('assets/video.png'),
                  iconSize: iconSize,
                  onPressed: onVideoPressed,
                ),
                IconButton(
                  icon: Image.asset('assets/R_button.png'),
                  iconSize: iconSize,
                  onPressed: onHangupPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
