import 'package:flutter/material.dart';
import 'dart:math' as math;

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
  final String _previewEmotion = 'thrilled';
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
                 itemCount: _messages.length + 1,
                 itemBuilder: (context, index) {
                 if (index == _messages.length) {
                    return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 550,
            ),
            child: FeelingsWheel(
              selectedEmotion: _previewEmotion,
            ),
          ),
        );
      }
      return _MessageBubble(
        message: _messages[index],
      );
    },
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

class FeelingsWheel extends StatelessWidget {
  const FeelingsWheel({
    super.key,
    this.selectedEmotion,
  });

  final String? selectedEmotion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'flutterApp/assets/hpu_feelings_wheel_full.png',
                fit: BoxFit.contain,
              ),
              if (selectedEmotion != null)
                CustomPaint(
                  painter: _FeelingsWheelPainter(
                    emotion: selectedEmotion!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeelingsWheelPainter extends CustomPainter {
  _FeelingsWheelPainter({required this.emotion});

  final String emotion;

  // Each emotion occupies one individual 10-degree segment.
  // These are the six outer segments in the HAPPY section.
  static final Map<String, List<double>> emotionAngles = {
    'thrilled': [-math.pi / 2, -4 * math.pi / 9],
    'eager': [-4 * math.pi / 9, -7 * math.pi / 18],
    'thankful': [-7 * math.pi / 18, -math.pi / 3],
    'moved': [-math.pi / 3, -5 * math.pi / 18],
    'satisfied': [-5 * math.pi / 18, -2 * math.pi / 9],
    'pleased': [-2 * math.pi / 9, -math.pi / 6],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final angles = emotionAngles[emotion.trim().toLowerCase()];

    if (angles == null) return;

    // The image's actual wheel center is offset from the image center.
    final center = Offset(
      size.width * .5714,
      size.height * .5714,
    );

    // Highlight ONLY the outer ring.
    final outerRadius = size.shortestSide * 0.5385;
    final innerRadius = size.shortestSide * 0.302;

    final start = angles[0];
    final sweep = angles[1] - angles[0];
    final end = start + sweep;

    final outerRect = Rect.fromCircle(
      center: center,
      radius: outerRadius,
    );

    final innerRect = Rect.fromCircle(
      center: center,
      radius: innerRadius,
    );

    final path = Path()
      ..moveTo(
        center.dx + outerRadius * math.cos(start),
        center.dy + outerRadius * math.sin(start),
      )
      ..arcTo(outerRect, start, sweep, false)
      ..lineTo(
        center.dx + innerRadius * math.cos(end),
        center.dy + innerRadius * math.sin(end),
      )
      ..arcTo(innerRect, end, -sweep, false)
      ..close();

    // Subtle transparent highlight.
    final highlight = Paint()
      ..color = const Color(0x66FFF176)
      ..style = PaintingStyle.fill;

    final outline = Paint()
      ..color = const Color(0xFFFFC928)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, highlight);
    canvas.drawPath(path, outline);
  }

  @override
  bool shouldRepaint(
    covariant _FeelingsWheelPainter oldDelegate,
  ) {
    return oldDelegate.emotion != emotion;
  }
}