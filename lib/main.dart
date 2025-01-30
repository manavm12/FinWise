import 'package:finwise/pages/expenses.dart';
import 'package:finwise/pages/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/home',
    routes: {
      '/home': (context)=>Home(),
      '/expenses': (context)=>ExpensePage()
    }
  ));
}
