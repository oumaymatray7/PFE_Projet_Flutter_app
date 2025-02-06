import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextFieldEye extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const TextFieldEye({
    Key? key,
    required this.controller,
    required this.hintText,
  }) : super(key: key);

  @override
  _TextFieldEyeState createState() => _TextFieldEyeState();
}

class _TextFieldEyeState extends State<TextFieldEye> {
  bool isobscure = true;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: screenHeight * 0.062,
      width: screenWidth * 0.778,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(145, 85, 253, 0.5),
            Color.fromRGBO(197, 165, 254, 0.5),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: TextField(
            controller: widget.controller,
            obscureText: isobscure,
            style: GoogleFonts.roboto(),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: widget.hintText,
              suffixIcon: IconButton(
                icon: isobscure
                    ? Icon(
                        Icons.visibility_off,
                        color: Colors.white,
                        size: 20.0,
                      )
                    : Icon(
                        Icons.visibility,
                        color: Colors.white,
                        size: 20.0,
                      ),
                onPressed: togglePasswordVisibility,
              ),
              hintStyle: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
            ),
          ),
        ),
      ),
    );
  }

  void togglePasswordVisibility() {
    setState(() {
      isobscure = !isobscure;
    });
  }
}

class PhoneNumberTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool
      obscureText; // This is not needed for phone numbers but added for flexibility
  final TextInputType keyboardType;

  const PhoneNumberTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.obscureText = false, // default is false because it's a phone number
    this.keyboardType =
        TextInputType.phone, // Default keyboard type set to phone
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Color(0xFF6F35A5),
        borderRadius: BorderRadius.circular(29),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.roboto(
          color: Colors.white, // Text color
          fontSize: 16, // Font size
        ),
        decoration: InputDecoration(
          icon: Icon(Icons.phone, color: Colors.white), // Icon for the phone
          hintText: hintText,
          hintStyle: GoogleFonts.roboto(
            color: Colors.white.withOpacity(0.7), // Hint text color
            fontSize: 16, // Hint text size
          ),
          border: InputBorder.none, // Removes the underline
        ),
      ),
    );
  }
}
