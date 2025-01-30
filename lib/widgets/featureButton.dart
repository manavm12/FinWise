import 'package:flutter/material.dart';

Widget FeatureButton(IconData icon, String label, VoidCallback fun) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: fun,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue[100],
            child: Icon(icon, size: 30, color: Colors.blue),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }