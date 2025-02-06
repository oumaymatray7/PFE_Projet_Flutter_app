import 'package:flutter/material.dart';
class button extends StatelessWidget {
  final Function()? onTap;

  const button({super.key, required this.onTap,});

  @override
  Widget build(BuildContext context) { 
    double screenHeight = MediaQuery.of(context)
        .size
        .height; 
    double screenWidth = MediaQuery.of(context)
        .size
        .width; 
    return  GestureDetector(
      onTap:onTap,
      child: Container(
        height: screenHeight * 0.060,
                      width: screenWidth * 0.778,
        margin: EdgeInsets.all(30),
        child: Center(child: Text(
                          'Submit',
                          style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          height: 0,
                          ),
        )),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.00, -1.00),
                end: Alignment(0, 1),
                colors: [Color(0xFF9155FD), Color(0xFFC5A5FE)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
    
      ),
    );
  }
}