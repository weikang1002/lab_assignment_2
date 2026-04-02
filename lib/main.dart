import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const FairApp());

class FairApp extends StatelessWidget {
  const FairApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomeScreen(title: 'Fair Participation'),
    );
  }
}