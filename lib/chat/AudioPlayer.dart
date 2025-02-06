import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mobile_app/chat/Conversation.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String? audioPath;

  AudioPlayerWidget({Key? key, this.audioPath}) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        _duration = newDuration;
      });
    });

    // Updated to use the correct API for position updates
    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        _position = newPosition;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _position = Duration.zero;
        isRecording = false;
      });
    });
  }

  void _togglePlay() async {
    if (isRecording) {
      await _audioPlayer.pause();
    } else {
      // Check if the audio file exists
      final file = File(widget.audioPath!);
      if (await file.exists()) {
        // File exists, play the audio
        await _audioPlayer.play(DeviceFileSource(file.path));
      } else {
        // File does not exist, handle the error
        print('Audio file does not exist at path: ${widget.audioPath}');
        // You might want to show an alert or a message to the user
      }
    }
    setState(() {
      isRecording = !isRecording;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Set the height of the play button and slider thumb to fit within the 50 pixels.
    final double buttonHeight = 30.0;
    final double sliderHeight =
        20.0; // Adjust as needed to fit within 50px height

    return Container(
      height: 50.0, // Container height fixed at 50 pixels
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2.0, // Adjust track height to be smaller
                thumbShape:
                    RoundSliderThumbShape(enabledThumbRadius: sliderHeight / 2),
              ),
              child: Slider(
                value: _position.inSeconds.toDouble(),
                min: 0.0,
                max: _duration.inSeconds.toDouble(),
                onChanged: (value) {
                  final newPosition = Duration(seconds: value.toInt());
                  _audioPlayer.seek(newPosition);
                  setState(() {
                    _position = newPosition;
                  });
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(isRecording ? Icons.pause : Icons.play_arrow),
                iconSize: buttonHeight,
                onPressed: _togglePlay,
              ),
              SizedBox(
                  width: 8.0), // Provides spacing between the button and text
              Text(formatDuration(_position)),
              Text(' / '),
              Text(formatDuration(_duration)),
            ],
          ),
        ],
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.release();
    _audioPlayer.dispose();
    super.dispose();
  }
}
