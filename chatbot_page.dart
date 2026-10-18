import 'package:flutter/material.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final _messageController = TextEditingController();
  final _messages = <_ChatMessage>[
    const _ChatMessage(
      text:
          'Place holder message where we will put the response to the survey part',
      isUser: false,
    ),
  ];
  String _selectedEmotion = '😊';
  bool _ended = false;
  bool _isResponding = false;

  static const _emotions = [
    ['😊', 'Happy'],
    ['😌', 'Calm'],
    ['🥰', 'Loved'],
    ['😐', 'Neutral'],
    ['😕', 'Confused'],
    ['😟', 'Worried'],
    ['😰', 'Anxious'],
    ['😢', 'Sad'],
    ['😠', 'Angry'],
    ['😩', 'Overwhelmed'],
    ['😴', 'Tired'],
    ['🥹', 'Hopeful'],
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _ended || _isResponding) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _messageController.clear();
      _isResponding = true;
    });
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (!mounted || _ended) return;
      setState(() {
        _messages.add(
          const _ChatMessage(
            text:
                'This is a placeholder AI response. Eventually, I will respond to what you tell me!',
            isUser: false,
          ),
        );
        _isResponding = false;
      });
    });
  }

  Future<void> _endChat() async {
    if (_ended) return;
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End this conversation?'),
        content: const Text('This will finish the current chat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End chat'),
          ),
        ],
      ),
    );
    if (shouldEnd == true && mounted) {
      setState(() {
        _ended = true;
        _messages.add(
          const _ChatMessage(
            text:
                'Conversation ended. This conversation is saved on this device.',
            isUser: false,
          ),
        );
      });
    }
  }

  void _chooseEmotion() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _emotions
                .map(
                  (emotion) => OutlinedButton(
                    onPressed: () {
                      setState(() => _selectedEmotion = emotion[0]);
                      Navigator.pop(context);
                      _messageController.text +=
                          '${_messageController.text.isEmpty ? '' : ' '}${emotion[0]} ${emotion[1]} ';
                    },
                    child: Text('${emotion[0]} ${emotion[1]}'),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy_outlined),
            SizedBox(width: 10),
            Text('AI Friend'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/experiences'),
            icon: const Icon(Icons.bookmark_border),
            label: const Text('Experiences'),
          ),
          TextButton(onPressed: _endChat, child: const Text('End Chat')),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  _MessageBubble(message: _messages[index]),
            ),
          ),
          if (_isResponding)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('AI Friend is responding...'),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Choose an emotion',
                  onPressed: _ended ? null : _chooseEmotion,
                  icon: Text(
                    _selectedEmotion,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !_ended && !_isResponding,
                    minLines: 1,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: "Share what's on your mind...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  tooltip: 'Send message',
                  onPressed: _ended ? null : _sendMessage,
                  icon: const Icon(Icons.arrow_upward),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Text(
              'AI Friend is not a replacement for professional care. For immediate danger, call 911.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.isUser});
  final String text;
  final bool isUser;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 660),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isUser
              ? const Color(0xff302e58)
              : const Color(0xff19263b),
          border: Border.all(color: const Color(0xff35425b)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          message.text,
          style: const TextStyle(color: Colors.white, height: 1.5),
        ),
      ),
    );
  }
}
