import 'package:flutter/material.dart';
import 'package:mobile_app/chat/call.dart';
import 'package:camera/camera.dart';

class VideoPage extends StatefulWidget {
  final String name;
  final String title;
  final String imageAsset;

  VideoPage({
    Key? key,
    required this.name,
    required this.title,
    required this.imageAsset,
  }) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0; // Default to first camera (usually rear)

  @override
  void initState() {
    super.initState();
    _initCamera(selectedCameraIndex);
  }

  Future<void> _initCamera(int cameraIndex) async {
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(
        cameras[cameraIndex],
        ResolutionPreset.medium,
      );
      _initializeControllerFuture = _controller?.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggleCamera() {
    selectedCameraIndex = selectedCameraIndex == 0 ? 1 : 0;
    _controller?.dispose();
    _initCamera(selectedCameraIndex);
  }

  double iconSize = 48; // Adjust based on your design

  bool isMuted = false; // Add this variable to track the mute state

  void onMutePressed() {
    setState(() {
      isMuted = !isMuted;
    });
  }

  bool isVoiceEnabled = true; // Add this variable to track the voice state

  void onKeyboardPressed() {
    setState(() {
      isVoiceEnabled = !isVoiceEnabled;
    });
  }

  void oncallPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CallPage(
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
      body: Stack(
        fit: StackFit.expand, // Ensure Stack fills the screen
        children: <Widget>[
          Image.asset(widget.imageAsset,
              fit: BoxFit.cover), // Background image of the person being called
          Positioned(
            right: 16.0,
            bottom: 100.0,
            child: Container(
              width: 120.0,
              height: 160.0,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return CameraPreview(
                          _controller!); // Display the camera feed
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 321.0,
              height: 62.0,
              margin: const EdgeInsets.only(bottom: 12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withOpacity(0.3),
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
                        ? Icon(Icons.mic_none_outlined,
                            color: Colors.white) // Voice enabled icon
                        : Icon(Icons.mic_off,
                            color: Colors.white), // Voice disabled icon
                    iconSize: iconSize,
                    onPressed: onKeyboardPressed,
                  ),
                  IconButton(
                    icon: Icon(Icons.flip_camera_ios, color: Colors.white),
                    iconSize: iconSize,
                    onPressed: _toggleCamera, // Button to switch cameras
                  ),
                  IconButton(
                    icon: Icon(Icons.call, color: Colors.white),
                    iconSize: iconSize,
                    onPressed: oncallPressed,
                  ),
                  IconButton(
                    icon: Image.asset('assets/R_button.png'),
                    iconSize: iconSize,
                    onPressed: onHangupPressed,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
