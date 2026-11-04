import 'package:flutter/material.dart';

/// The information passed from the check-in survey to AI Friend.
class EmotionSurveyResult {
  final String emotion;
  final String nuance;
  final String preciseEmotion;
  final int intensity;
  final String note;

  const EmotionSurveyResult({
    required this.emotion,
    required this.nuance,
    required this.preciseEmotion,
    required this.intensity,
    required this.note,
  });

  /// Useful when building the first chatbot message later.
  String get summary =>
      'I feel $preciseEmotion ($emotion → $nuance), intensity $intensity/5.'
      '${note.trim().isEmpty ? '' : ' Additional context: ${note.trim()}'}';
}

/// Place this widget between the login page and the chatbot shell.
/// Its parent controls navigation via [onComplete].
class EmotionSurveyPage extends StatefulWidget {
  final ValueChanged<EmotionSurveyResult> onComplete;

  const EmotionSurveyPage({super.key, required this.onComplete});

  @override
  State<EmotionSurveyPage> createState() => _EmotionSurveyPageState();
}

class _EmotionSurveyPageState extends State<EmotionSurveyPage> {
  static const _background = Color(0xFF0C1220);
  static const _panel = Color(0xFF172338);
  static const _border = Color(0xFF26364E);
  static const _accent = Color(0xFF9C92FF);
  static const _foreground = Color(0xFFF1F5FC);
  static const _muted = Color(0xFFA4B1C6);

  static const Map<String, Color> _colors = {
    'Afraid': Color(0xFF885FD4),
    'Angry': Color(0xFFE57373),
    'Happy': Color(0xFFF0BC51),
    'Calm': Color(0xFF52B788),
    'Strong': Color(0xFF4BAFCB),
    'Sad': Color(0xFF7096E4),
  };

  static const Map<String, String> _emoji = {
    'Afraid': '😟', 'Angry': '😠', 'Happy': '😊',
    'Calm': '😌', 'Strong': '💪', 'Sad': '😢',
  };

  static const Map<String, String> _descriptions = {
    'Afraid': 'worried, unsure, under pressure',
    'Angry': 'frustrated, treated unfairly',
    'Happy': 'upbeat, glad, energized',
    'Calm': 'steady, at peace, open',
    'Strong': 'capable, confident, engaged',
    'Sad': 'down, disappointed, alone',
  };

  // Exact labels used by the 36 highlighted segments in the HPU wheel.
  // Broad group → closer feeling → precise wheel segment.
  static const Map<String, Map<String, List<String>>> _wheel = {
    'Happy': {
      'Excited': ['Thrilled', 'Eager'],
      'Grateful': ['Thankful', 'Moved'],
      'Content': ['Satisfied', 'Pleased'],
    },
    'Calm': {
      'Relaxed': ['At ease', 'Settled'],
      'Hopeful': ['Optimistic', 'Inspired'],
      'Caring': ['Warm', 'Tender'],
    },
    'Strong': {
      'Confident': ['Capable', 'Bold'],
      'Curious': ['Engaged', 'Interested'],
      'Proud': ['Accomplished', 'Valued'],
    },
    'Sad': {
      'Lonely': ['Isolated', 'Left out'],
      'Disappointed': ['Let down', 'Deflated'],
      'Grieving': ['Heartbroken', 'Bereft'],
    },
    'Afraid': {
      'Anxious': ['Worried', 'Tense'],
      'Helpless': ['Overwhelmed', 'Stuck'],
      'Insecure': ['Uncertain', 'Doubtful'],
    },
    'Angry': {
      'Frustrated': ['Blocked', 'Irritated'],
      'Resentful': ['Bitter', 'Wronged'],
      'Furious': ['Outraged', 'Livid'],
    },
  };

  final _noteController = TextEditingController();
  int _step = 0; // 0 broad, 1 closer, 2 precise, 3 context, 4 review
  String? _broad;
  String? _nuance;
  String? _precise;
  double _intensity = 3;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  void _chooseBroad(String choice) {
    setState(() {
      _broad = choice;
      _nuance = null;
      _precise = null;
      _step = 1;
    });
  }

  void _chooseNuance(String choice) {
    setState(() {
      _nuance = choice;
      _precise = null;
      _step = 2;
    });
  }

  void _choosePrecise(String choice) {
    setState(() {
      _precise = choice;
      _step = 3;
    });
  }

  void _submit() {
    widget.onComplete(EmotionSurveyResult(
      emotion: _broad!,
      nuance: _nuance!,
      preciseEmotion: _precise!,
      intensity: _intensity.round(),
      note: _noteController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _step == 0 ? null : _back,
                        icon: const Icon(Icons.arrow_back, size: 17),
                        label: const Text('Back'),
                        style: TextButton.styleFrom(foregroundColor: _muted),
                      ),
                      const Spacer(),
                      ...List.generate(5, (index) => Container(
                        width: 27,
                        height: 5,
                        margin: const EdgeInsets.only(left: 5),
                        decoration: BoxDecoration(
                          color: index <= _step ? _accent : _border,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      )),
                      const SizedBox(width: 10),
                      Text('Step ${_step + 1} of 5',
                          style: const TextStyle(color: _muted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Expanded(
                    child: SingleChildScrollView(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: KeyedSubtree(
                          key: ValueKey(_step),
                          child: _buildStep(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _heading('How are you feeling right now?',
              'Start broad. We’ll help you find a more specific word.'),
          _responsiveGrid(_colors.keys.map((name) => _emotionCard(name)).toList(), 255),
        ]);
      case 1:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _trail(),
          _heading('Which feels closer?',
              'Pick the one that fits best. You can always go back.'),
          _responsiveGrid(_wheel[_broad]!.keys.map((name) => _choiceCard(
            name, 'Tap to explore this feeling',
            () => _chooseNuance(name),
          )).toList(), 220),
        ]);
      case 2:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _trail(),
          _heading('Can you be more precise?',
              'These choices match the feelings wheel shown in chat.'),
          _responsiveGrid(_wheel[_broad]![_nuance]!.map((name) =>
              _choiceCard(name, '', () => _choosePrecise(name))).toList(), 260),
        ]);
      case 3:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _trail(),
          _heading('A little more context',
              'These details are optional and help AI Friend understand you.'),
          _panelCard(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('HOW STRONG IS IT?  ${_intensity.round()}/5',
                style: const TextStyle(color: _foreground, fontWeight: FontWeight.w600)),
            SliderTheme(
              data: SliderThemeData(activeTrackColor: _accent,
                  thumbColor: _accent, inactiveTrackColor: _border),
              child: Slider(value: _intensity, min: 1, max: 5, divisions: 4,
                  onChanged: (value) => setState(() => _intensity = value)),
            ),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('A little', style: TextStyle(color: _muted)),
                Text('Intensely', style: TextStyle(color: _muted))]),
          ])),
          const SizedBox(height: 14),
          _panelCard(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('ANYTHING YOU WANT TO ADD? (OPTIONAL)',
                style: TextStyle(color: _muted, fontWeight: FontWeight.w600, fontSize: 12)),
            const SizedBox(height: 12),
            _textField(_noteController, 'One or two sentences is plenty.', maxLines: 4),
          ])),
          const SizedBox(height: 20),
          _primaryButton('Continue', () => setState(() => _step = 4)),
          const SizedBox(height: 8),
          TextButton(onPressed: () {
            _noteController.clear();
            setState(() { _intensity = 3; _step = 4; });
          }, child: const Text('Skip', style: TextStyle(color: _muted))),
        ]);
      default:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _heading('Ready to chat?',
              'Here is what AI Friend will receive from your check-in.'),
          _panelCard(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _trail(),
            const SizedBox(height: 10),
            _summaryLine('Intensity', '${_intensity.round()}/5'),
            _summaryLine('Your note', _noteController.text.trim().isEmpty
                ? 'None' : _noteController.text.trim()),
          ])),
          const SizedBox(height: 20),
          _primaryButton('Continue to AI Friend', _submit),
          const SizedBox(height: 8),
          TextButton(onPressed: () => setState(() {
            _step = 0; _broad = null; _nuance = null; _precise = null;
            _noteController.clear(); _intensity = 3;
          }), child: const Text('Start over', style: TextStyle(color: _muted))),
        ]);
    }
  }

  Widget _heading(String title, String subtitle) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: _foreground,
          fontSize: 27, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(subtitle, style: const TextStyle(color: _muted, fontSize: 15)),
    ]),
  );

  Widget _trail() => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Wrap(spacing: 6, runSpacing: 7, crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (_broad != null) _pill(_broad!),
        if (_nuance != null) ...[const Text('›', style: TextStyle(color: _muted)), _pill(_nuance!)],
        if (_precise != null) ...[const Text('›', style: TextStyle(color: _muted)), _pill(_precise!)],
      ]),
  );

  Widget _pill(String name) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(color: _colors[_broad] ?? _accent,
        borderRadius: BorderRadius.circular(30)),
    child: Text(name, style: const TextStyle(color: _background,
        fontWeight: FontWeight.bold, fontSize: 12)),
  );

  Widget _emotionCard(String name) => InkWell(
    onTap: () => _chooseBroad(name),
    borderRadius: BorderRadius.circular(15),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _panel,
        border: Border.all(color: _colors[name]!, width: 2),
        borderRadius: BorderRadius.circular(15)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(name, style: const TextStyle(color: _foreground,
              fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(), Text(_emoji[name]!, style: const TextStyle(fontSize: 25)),
        ]),
        const SizedBox(height: 10),
        Text(_descriptions[name]!, style: const TextStyle(color: _muted)),
      ]),
    ),
  );

  Widget _choiceCard(String name, String description, VoidCallback action) => InkWell(
    onTap: action,
    borderRadius: BorderRadius.circular(15),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _panel,
        border: Border.all(color: _border, width: 1.5),
        borderRadius: BorderRadius.circular(15)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(name, style: const TextStyle(color: _foreground,
            fontSize: 18, fontWeight: FontWeight.bold)),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 7),
          Text(description, style: const TextStyle(color: _muted)),
        ],
      ]),
    ),
  );

  Widget _responsiveGrid(List<Widget> children, double minWidth) =>
      LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= minWidth * 3 + 24 ? 3
            : width >= minWidth * 2 + 12 ? 2 : 1;
        return GridView.count(
          crossAxisCount: columns, crossAxisSpacing: 12, mainAxisSpacing: 12,
          childAspectRatio: columns == 1 ? 2.6 : 2.0,
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          children: children,
        );
      });

  Widget _panelCard(Widget child) => Container(
    width: double.infinity, padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: _panel,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(15)),
    child: child,
  );

  Widget _textField(TextEditingController controller, String hint, {int maxLines = 1}) =>
      TextField(
        controller: controller, maxLines: maxLines,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: _foreground),
        decoration: InputDecoration(hintText: hint,
          hintStyle: const TextStyle(color: _muted), filled: true,
          fillColor: _background,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _accent)),
        ),
      );

  ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(
    backgroundColor: _accent, foregroundColor: _background,
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );

  Widget _primaryButton(String label, VoidCallback action) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(onPressed: action, style: _buttonStyle(),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
  );

  Widget _summaryLine(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Text.rich(TextSpan(children: [
      TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
      TextSpan(text: value),
    ]), style: const TextStyle(color: _foreground, fontSize: 15)),
  );
}
