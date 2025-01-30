import 'package:flutter/material.dart';

class BlueText extends StatelessWidget {
  const BlueText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.blue
    ),);
  }
}