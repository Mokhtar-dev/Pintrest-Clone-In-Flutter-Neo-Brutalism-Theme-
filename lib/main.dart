import 'package:flutter/material.dart';
import 'features/pinboard/presentation/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Mania',
      theme: ThemeData.dark(),
      home: const LoginScreen(),
    );
  }
}