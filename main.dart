import 'package:flutter/material.dart';
import 'chatbot_page.dart';
import 'experiences_page.dart';
import 'login_page.dart';
import 'survey_page.dart';

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
  initialRoute: '/sign-in', // <--- Add this line to specify the starting route
  routes: {
    '/sign-in': (context) => const LoginPage(),
    '/survey': (context) => EmotionSurveyPage(
      onComplete: (result) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => ChatbotPage(surveyResult: result),
          ),
        );
      },
    ),
    '/chat': (_) => const ChatbotPage(),
    '/experiences': (_) => const ExperiencesPage(),
  },
);
  }
}

