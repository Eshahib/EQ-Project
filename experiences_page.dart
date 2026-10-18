import 'package:flutter/material.dart';

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

class ExperiencesPage extends StatelessWidget {
  const ExperiencesPage({super.key});

  static const experiences = [
    {
      'title': 'Getting Started',
      'description': 'Your first conversation with your AI companion.',
      'date': 'October 15, 2026',
      'icon': Icons.chat_bubble_outline,
    },
    {
      'title': 'Learning and Discovery',
      'description': 'A conversation about learning something new.',
      'date': 'October 12, 2026',
      'icon': Icons.lightbulb_outline,
    },
    {
      'title': 'Personal Growth',
      'description': 'Reflecting on progress and setting new goals.',
      'date': 'October 10, 2026',
      'icon': Icons.trending_up,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Connect the previous page.
          },
        ),
        title: const Text('Experiences'),
        actions: [
          IconButton(
            tooltip: 'Home',
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              // Connect the home page.
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Experiences',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'View your previous conversations and experiences.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Text(
                'Recent Experiences',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: experiences.length,
                  itemBuilder: (context, index) {
                    final experience = experiences[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          child: Icon(
                            experience['icon'] as IconData,
                          ),
                        ),
                        title: Text(
                          experience['title'] as String,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                experience['description'] as String,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                experience['date'] as String,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall,
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                        ),
                        onTap: () {
                          // Connect experience details.
                        },
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Text(
                'Other Pages',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      // Connect AI chatbot.
                    },
                    icon: const Icon(Icons.smart_toy_outlined),
                    label: const Text('AI Chatbot'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Connect growth score.
                    },
                    icon: const Icon(Icons.trending_up),
                    label: const Text('Growth Score'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Connect sign-in.
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Sign In'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}