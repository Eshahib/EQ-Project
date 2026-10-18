import 'package:flutter/material.dart';
import 'chatbot_page.dart';
import 'experiences_page.dart';
import 'login_page.dart';

void main() {
  runApp(const EqAiApp());
}

class EqAiApp extends StatelessWidget {
  const EqAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Friend',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff6750a4)),
        useMaterial3: true,
      ),
      initialRoute: '/sign-in',
      routes: {
        '/sign-in': (_) => const LoginPage(),
        '/chat': (_) => const ChatbotPage(),
        '/experiences': (_) => const ExperiencesPage(),
      },
    );
  }
}
