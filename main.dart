import 'package:flutter/material.dart';
import 'experiences_page.dart';

void main() {
  runApp(const ExperiencesApp());
}

class ExperiencesApp extends StatelessWidget {
  const ExperiencesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Experiences',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const ExperiencesPage(),
    );
  }
}