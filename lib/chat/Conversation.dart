import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:mobile_app/chat/PhotoPicker.dart';
import 'package:mobile_app/chat/call.dart';
import 'package:mobile_app/chat/chatHomePage.dart';
import 'package:mobile_app/chat/contact.dart';
import 'package:mobile_app/chat/vedio.dart';
import 'package:intl/intl.dart'; // Ensure you have added the intl package for date formatting
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:mobile_app/chat/AudioPlayer.dart';

import 'package:file_picker/file_picker.dart';

enum MessageType { text, audio, file, image }

// Assuming you have a Message class like this:
class Message {
  String senderId;
  String text;
  DateTime timestamp;
  String senderAvatar; // Add this line
  String? audioPath;
  String? filePath;
  MessageType type;
  String? imagePath; // Add this line for image path

  Message({
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.senderAvatar,
    this.audioPath, // Add this line
    this.type = MessageType.text,
    this.filePath,
    this.imagePath,
  });
}

class ConversationPage extends StatefulWidget {
  final String jobTitle;
  final ChatEntry chat;
  final String chatName;
  final String chatImageAsset;
  final bool isOnline;

  ConversationPage({
    Key? key,
    required this.jobTitle,
    required this.chat, // Ensure chat is part of the constructor.
    required this.chatName,
    required this.chatImageAsset,
    required this.isOnline,
  }) : super(key: key);

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final FocusNode _textFieldFocusNode = FocusNode();
  String currentUserId = 'yourCurrentUserId';
  String senderAvatar = 'assets/Ellipse 11.png';
  String? _selectedFilePath;
  bool _isFileSelected = false;

  late List<Message> messages;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  File? _selectedImageFile;
  File? _pickedImage;
  bool isRecording = false;
  late ChatEntry chat; // Declare chat in the state class

  @override
  void initState() {
    super.initState();
    messages = [];
    chat = widget.chat;
    initRecorder();
  }

  void navigateToContact(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContactPage(
          name: chat.name,
          jobTitle: chat.jobTitle,
          email: chat.email,
          phone: chat.phone,
          address: chat.address,
          avatarPath: chat.avatarPath,
          isOnline: chat.isOnline,
        ),
      ),
    );
  }

  Future<void> _handlePhotoButtonPressed() async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImageFile = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to pick the image: $e")));
    }
  }

  void sendMessageWithAudio(String path) {
    File audioFile = File(path);

    // Create a new message object for the audio
    Message newMessage = Message(
      senderId: currentUserId,
      text: "",
      timestamp: DateTime.now(),
      senderAvatar: senderAvatar,
      type: MessageType.audio,
      audioPath: path,
    );
    setState(() {
      messages.add(newMessage);
    });

    // Optionally, upload the audio file to a server
    uploadAudioFile(audioFile);
  }

  Future<void> initRecorder() async {
    var hasPermission = await checkPermissions();
    if (!hasPermission) {
      print("Microphone permission not granted");
      return;
    }

    try {
      await _audioRecorder.openRecorder();
    } catch (e) {
      print("Failed to open the recorder: $e");
      return;
    }
  }

  Future<bool> checkPermissions() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Microphone permission not granted")));
    }
    return status == PermissionStatus.granted;
  }

// Example placeholder function for uploading an audio file
  Future<void> uploadAudioFile(File audioFile) async {
    try {
      // Implementation of file upload
      // This can be done using various methods depending on how your backend is set up
      // For example, using HTTP multipart requests, Firebase Storage, etc.
      print("Audio file uploaded: ${audioFile.path}");
    } catch (e) {
      print("Failed to upload audio file: $e");
    }
  }

  Future<void> startRecording() async {
    bool hasPermission = await checkPermissions();
    if (!hasPermission) {
      print("Microphone permission not granted");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Microphone permission not granted")));
      return; // Exit if no permission
    }

    try {
      await _audioRecorder.startRecorder(toFile: 'audio_message.aac');
      setState(() {
        isRecording = true;
      });
    } catch (e) {
      print("Failed to start recording: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to start recording: $e")));
      setState(() {
        isRecording = false;
      });
    }
  }

  Future<void> stopRecordingAndSend() async {
    try {
      final String? path = await _audioRecorder.stopRecorder();
      setState(() {
        isRecording = false; // Ensure UI is updated when recording stops
      });

      if (path != null) {
        sendMessageWithAudio(path);
      } else {
        // Inform the user that recording failed or was cancelled
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Recording failed or was cancelled.")));
      }
    } catch (e) {
      print("Error stopping recording: $e");
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to stop recording: $e")));
      setState(() {
        isRecording = false; // Reset recording state on error
      });
    }
  }

  void onCallButtonPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CallPage(
          name: widget.chatName,
          title: widget.jobTitle,
          imageAsset: widget.chatImageAsset,
        ),
      ),
    );
  }

  void onVideoPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPage(
          name: widget.chatName,
          title: widget.jobTitle,
          imageAsset: widget.chatImageAsset,
        ), // Your VideoPage class
      ),
    );
  }

  Future<void> _pickMedia() async {
    try {
      // Let the user select all types of files
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Allows all file types
        // For allowing multiple types, you can use FileType.custom and provide file extensions
        // allowedExtensions: ['jpg', 'pdf', 'doc', 'mp4'], // Example of specific file types
      );

      if (result != null && result.files.single.path != null) {
        // If the result is not null and there's a path for the file
        File selectedFile = File(result.files.single.path!);
        // Do something with the selected file, like storing it in the state
        // For example, to handle image preview
        if (selectedFile.path.endsWith('.png') ||
            selectedFile.path.endsWith('.jpg') ||
            selectedFile.path.endsWith('.jpeg') ||
            selectedFile.path.endsWith('.gif')) {
          setState(() {
            _selectedImageFile = selectedFile; // If it's an image, preview it
          });
        } else {
          // For non-image files, you might want to do something else
          // e.g., store the File object for sending as a message attachment
        }
      } else {
        // User canceled the picker
      }
    } catch (e) {
      // Handle any exceptions
      print('Failed to pick file: $e');
    }
  }

  void _sendMessage() {
    String text = _messageController.text.trim();

    if (_selectedImageFile != null) {
      // If there's a selected image, send it
      final imageMessage = Message(
        senderId: currentUserId,
        text: _messageController.text.trim(), // Any accompanying text
        timestamp: DateTime.now(),
        senderAvatar: senderAvatar,
        type: MessageType.image,
        imagePath: _selectedImageFile!.path, // Path to the selected image
      );

      setState(() {
        messages.add(imageMessage);
        _selectedImageFile = null;

        /// Reset the image
      });

      _messageController.clear();
    } else if (text.isNotEmpty) {
      // If no image is selected, send text
      Message textMessage = Message(
        senderId: currentUserId,
        text: text,
        timestamp: DateTime.now(),
        senderAvatar: senderAvatar,
        type: MessageType.text,
      );

      setState(() {
        messages.add(textMessage);
        _messageController.clear(); // Clear the message input field
      });
    }

    // Scroll to the new message
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void closeMenu() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null; // Ensure to set to null after removing
      isMenuOpen = false;
    }
  }

  bool isMuted = false; // Initial state of notification muting

  bool isMenuOpen = false; // Suivi de l'état du menu
  OverlayEntry? _overlayEntry;
  void _showOptionsMenu() {
    if (!isMenuOpen) {
      // Check if the menu is already open
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _overlayEntry = _createOverlayEntry();
          Overlay.of(context)?.insert(_overlayEntry!);
          isMenuOpen = true;
        }
      });
    }
  }

  void clearChat() {
    setState(() {
      messages.clear(); // Assuming messages is your chat message list
      // Notify the user
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Chat cleared successfully")));
    });
  }

  void confirmClearChat() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Clear Chat'),
          content: Text(
              'Are you sure you want to clear all messages? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Clear Chat'),
              onPressed: () {
                Navigator.of(context).pop();
                clearChat();
              },
            ),
          ],
        );
      },
    );
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (BuildContext context) => Positioned(
        right: 20,
        top: 150,
        width: 200,
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _menuButton(
                'View Contact',
                () => navigateToContact(context),
                icon: Icons.contact_page, // Optional icon for "View Contact"
              ),
              _menuButton(
                'Mute Notifications',
                () {
                  setState(() {
                    isMuted = !isMuted; // Toggle mute state
                    // Here you could also handle persistent state changes or server notifications
                  });
                },
                icon: isMuted
                    ? Icons.volume_off
                    : Icons.volume_up, // Toggle icon based on mute state
              ),
              _menuButton(
                'Clear Chat',
                () {
                  clearChat(); // Call the function to clear chat
                  closeMenu(); // Close the menu after action
                },
                icon: Icons.delete_outline, // Optional icon for "Clear Chat"
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool shouldShowLargeAvatar = messages.length < 4; // Example condition
    return Scaffold(
      backgroundColor: Color(0xFF28243D),
      body: Column(
        children: [
          _buildHeader(shouldShowLargeAvatar: shouldShowLargeAvatar),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) {
                final message = messages[index];
                final bool isMe = message.senderId ==
                    currentUserId; // Replace with actual user ID
                return _buildMessage(message, isMe);
              },
            ),
          ),
          _buildInputSection(),
        ],
      ),
    );
  }

  // bool _showEmojiPicker = false;

  //void _toggleEmojiPicker() {
  // setState(() {
  // _showEmojiPicker = !_showEmojiPicker;
  // });
  // }
// Assume you have a variable to hold the picked file path
  String? pickedFilePath;

  Widget _buildInputSection() {
    final BorderRadius borderRadius = BorderRadius.circular(30.0);
    final double iconSize = 20.0; // Icon size for the emojis and other actions

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/barre_input.png"),
          fit: BoxFit.fill,
        ),
        borderRadius: borderRadius,
        border: Border.all(
          color: Colors.white, // White border color for contrast
          width: 1.0, // Border width
        ),
      ),
      child: Row(
        children: <Widget>[
          if (_selectedImageFile != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(
                _selectedImageFile!,
                width: 100, // Example thumbnail width
                height: 100, // Example thumbnail height
              ),
            ),
          Expanded(
              child: TextField(
            controller: _messageController,
            maxLines:
                null, // Allows the input field to expand to accommodate the text
            //softWrap: true, // Enables text wrapping
            keyboardType: TextInputType.multiline, // Allows for multiline input
            decoration: InputDecoration(
              hintText: "Type a message",
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              border: InputBorder.none,
              suffixIcon: IconButton(
                iconSize: iconSize,
                icon: Icon(Icons.attach_file),
                onPressed: _pickMedia,
              ),
              labelStyle: TextStyle(
                color: Colors.white, // Style the label text (e.g., color, size)
                overflow: TextOverflow
                    .ellipsis, // Add an ellipsis if the text overflows
              ),
            ),
          )),
          IconButton(
            iconSize: iconSize,
            icon: Icon(Icons.photo_album),
            color: Colors.white,
            onPressed: _handlePhotoButtonPressed,
          ),
          GestureDetector(
              onLongPressStart: (_) {
                setState(() {
                  isRecording =
                      true; // Set isRecording to true when recording starts
                });
                startRecording().catchError((error) {
                  // If an error occurs starting the recording, handle it
                  setState(() {
                    isRecording = false; // Reset isRecording on error
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Error starting recording: $error")));
                });
              },
              onLongPressEnd: (_) {
                stopRecordingAndSend().catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Error stopping recording: $error")));
                }).whenComplete(() {
                  setState(() {
                    isRecording =
                        false; // Ensure isRecording is reset when recording stops
                  });
                });
              },
              child: IconButton(
                icon: Icon(
                  Icons.mic,
                  color: isRecording
                      ? Colors.blue
                      : Colors.white, // Change color based on isRecording
                ),
                onPressed: () {
                  setState(() {
                    isRecording = !isRecording; // Toggle recording state
                  });
                  if (isRecording) {
                    // Start recording
                  } else {
                    // Stop recording
                  }
                },
              )),
          IconButton(
            iconSize: iconSize,
            icon: Icon(
              Icons.send, // Uses the built-in send icon
              color: Colors.white, // Icon color
            ),
            onPressed: _sendMessage, // Triggers sending a message
          ),
          if (_pickedImage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Image.file(
                    _pickedImage!,
                    width: 100, // or some other appropriate size
                    height: 100,
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _pickedImage = null; // Remove the image
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFileMessage(Message message, bool isMe) {
    IconData fileIcon = Icons.attach_file; // Default icon for files
    String fileName = message.filePath?.split('/').last ?? 'Unknown file';
    String fileExtension = fileName.split('.').last;

    switch (fileExtension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        fileIcon = Icons.image;
        break;
      case 'pdf':
        fileIcon = Icons.picture_as_pdf;
        break;
      case 'mp3':
        fileIcon = Icons.music_note;
        break;
      case 'mp4':
        fileIcon = Icons.videocam;
        break;
      // Extend with more file types as needed
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: isMe ? Colors.lightBlueAccent : Colors.grey[200],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: InkWell(
        onTap: () {
          if (message.imagePath != null) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ImageScreen(imagePath: message.imagePath)));
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(fileIcon, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                fileName,
                style: TextStyle(
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(
    Message message,
    bool isMe,
  ) {
    Color messageBgColor = isMe ? Color(0xFFFFFFFF) : Color(0xFF937CC1);
    double maxWidth = MediaQuery.of(context).size.width *
        0.6; // Decrease the max width to make the bubble smaller

    Widget messageContent = SizedBox.shrink();
    switch (message.type) {
      case MessageType.audio:
        messageContent = Container(
          height: 50.0,
          width: MediaQuery.of(context).size.width * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: AudioPlayerWidget(audioPath: message.audioPath),
          ),
        );
        break;
      case MessageType.image:
        // Display the image message
        messageContent = Image.file(
          File(message.imagePath!),
          width: 200, // Adjust the width as needed
          height: 200, // Adjust the height as needed
          fit: BoxFit.cover, // This scales the image to cover the box
        );
        break;
      case MessageType.file:
        messageContent = _buildFileMessage(message, isMe);

        break;

      case MessageType.text:
      default:
        messageContent = Text(
          message.text,
          style: TextStyle(
            color: isMe ? Color(0xFF28243D) : Color(0xFFFFFFFF),
            fontSize: 16,
          ),
        );
        break;
    }

    Widget avatarWidget = Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: CircleAvatar(
        backgroundImage: AssetImage(message.senderAvatar),
      ),
    );

    Widget messageBubble = Container(
      margin: EdgeInsets.symmetric(
          vertical: 4.0, horizontal: 8.0), // Adjust margins as needed
      padding: EdgeInsets.symmetric(
          horizontal: 12.0, vertical: 8.0), // Adjust padding as needed
      decoration: BoxDecoration(
        color: messageBgColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: messageContent,
    );

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        if (!isMe) avatarWidget,
        messageBubble,
        if (isMe) avatarWidget,
      ],
    );
  }

  Widget _menuButton(String text, VoidCallback onPressed, {IconData? icon}) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        padding: EdgeInsets.all(16),
        alignment: Alignment.centerLeft,
        textStyle: TextStyle(fontSize: 16),
      ),
      onPressed: () {
        onPressed(); // Perform the button-specific action
        closeMenu(); // Then close the menu
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, color: Colors.black),
          SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildHeader({required bool shouldShowLargeAvatar}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double fem = screenWidth / 375; // Scaling factor for width
    final double ffem = screenHeight / 812; // Scaling factor for height
    final double arcHeight = 219 * fem;
    final double largeAvatarSize = 123 * fem;
    final double iconSize = 24 * fem;
    final double headerHeight = shouldShowLargeAvatar
        ? arcHeight + (largeAvatarSize / 2)
        : 60 * fem; // 60 is an arbitrary value for a smaller header

    return Container(
      height: headerHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Arc background image
          if (shouldShowLargeAvatar)
            Positioned.fill(
              child: Image.asset(
                'assets/arc.png',
                fit: BoxFit.cover,
              ),
            ),
          // Row for small avatar, name, and icons
          Positioned(
            top:
                MediaQuery.of(context).padding.top, // Align with the status bar
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: 20 * fem), // Horizontal margin
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Small avatar with online status indicator
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (widget.isOnline)
                        CircleAvatar(
                          radius:
                              24 * fem, // Outer circle for the status indicator
                          backgroundColor: Colors.green,
                        ),
                      CircleAvatar(
                        radius: 20 * fem, // Actual avatar size
                        backgroundImage: AssetImage(widget.chatImageAsset),
                      ),
                    ],
                  ),
                  // Text for name and job title
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8 * fem),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.chatName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13 * fem,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.jobTitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12 * fem,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top,
                    right: 20,
                    child: Row(
                      children: [
                        if (isMuted) // Conditionally display mute icon
                          Icon(Icons.volume_off,
                              color: Colors.red, size: iconSize),
                        // Other icons or elements...
                      ],
                    ),
                  ),
                  // Icons for call, video, etc.

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Image.asset('assets/call.png',
                            width: iconSize, height: iconSize),
                        onPressed:
                            onCallButtonPressed, // Assuming this is defined somewhere
                      ),
                      IconButton(
                        icon: Image.asset('assets/video.png',
                            width: iconSize, height: iconSize),
                        onPressed:
                            onVideoPressed, // Assuming this is defined somewhere
                      ),
                      IconButton(
                        icon: Image.asset(
                          'assets/3p.png',
                          width:
                              iconSize, // Define your iconSize variable somewhere
                          height: iconSize,
                        ),
                        onPressed:
                            _showOptionsMenu, // Call the method to show the menu
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Large avatar with the user's name below it
          if (shouldShowLargeAvatar)
            Positioned(
              top: arcHeight - (largeAvatarSize / 2),
              child: CircleAvatar(
                radius: largeAvatarSize / 2,
                backgroundImage: AssetImage(widget.chatImageAsset),
              ),
            ),

          // Conditionally display the user's name below the large avatar
          if (shouldShowLargeAvatar)
            Positioned(
              top:
                  arcHeight + (largeAvatarSize / 2) + 8, // Adjusted for spacing
              child: Text(
                widget.chatName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20 * ffem,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();

    _audioRecorder.closeRecorder();

    super.dispose();
  }
}

class ImageScreen extends StatelessWidget {
  final String? imagePath;

  ImageScreen({this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image Preview")),
      body: Center(
        child: imagePath != null
            ? Image.file(File(imagePath!))
            : Text("No image found."),
      ),
    );
  }
}
