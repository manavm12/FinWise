import 'package:finwise/pages/aiChatbot.dart';
import 'package:finwise/pages/expenses.dart';
import 'package:finwise/pages/home.dart';
import 'package:finwise/pages/login.dart';
import 'package:finwise/pages/register.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/login',
    routes: {
      '/home': (context)=>Home(),
      '/expenses': (context)=>ExpensePage(),
      '/login': (context)=>LoginScreen(),
      '/register':(context)=>RegisterScreen(),
      '/chatbot':(context)=>AIChatBot()
    }
  ));
}
