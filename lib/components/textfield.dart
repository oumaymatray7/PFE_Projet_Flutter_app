import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Textfield extends StatelessWidget {
  final TextEditingController controller; // Correct type annotation
  final String hintText;
  final bool obscureText;
  final Widget icon; // Corrected type and name

  const Textfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.icon, // Updated to reflect the lowercased 'icon'
  });

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
            Color.fromRGBO(197, 165, 254, 0.5)
          ],
        ),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          style: GoogleFonts.roboto(),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            prefixIcon: icon, // Use the icon parameter
            hintStyle: GoogleFonts.roboto(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
