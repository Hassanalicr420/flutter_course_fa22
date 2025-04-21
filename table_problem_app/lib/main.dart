import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final darkMode = prefs.getBool('darkMode') ?? false;
  runApp(MathTablesApp(darkMode: darkMode));
}

class MathTablesApp extends StatefulWidget {
  final bool darkMode;

  const MathTablesApp({Key? key, required this.darkMode}) : super(key: key);

  @override
  _MathTablesAppState createState() => _MathTablesAppState();

  static _MathTablesAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MathTablesAppState>();
}

class _MathTablesAppState extends State<MathTablesApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.darkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void changeThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Master',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/learn': (context) => const LearnTablesScreen(),
        '/practice': (context) => const PracticeScreen(),
        '/test': (context) => const TestScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6C63FF),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF6C63FF),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Colors.black54,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6C63FF),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          color: Colors.white70,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Colors.white60,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: const Color(0xFF1E1E1E),
        margin: const EdgeInsets.all(8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Master'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Master Your Multiplication Tables',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                _FeatureCard(
                  icon: Icons.school,
                  title: 'Learn Tables',
                  subtitle: 'Study multiplication tables',
                  onTap: () {
                    Navigator.pushNamed(context, '/learn');
                  },
                  color: const Color(0xFF6C63FF),
                ),
                const SizedBox(height: 20),
                _FeatureCard(
                  icon: Icons.fitness_center,
                  title: 'Practice Mode',
                  subtitle: 'Practice with feedback',
                  onTap: () {
                    Navigator.pushNamed(context, '/practice');
                  },
                  color: const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 20),
                _FeatureCard(
                  icon: Icons.quiz,
                  title: 'Test Mode',
                  subtitle: 'Challenge yourself',
                  onTap: () {
                    Navigator.pushNamed(context, '/test');
                  },
                  color: const Color(0xFFFF9800),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;

  const _FeatureCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.4),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LearnTablesScreen extends StatelessWidget {
  const LearnTablesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Tables'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            final tableNumber = index + 1;
            return _TableSelectionCard(
              tableNumber: tableNumber,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TableDetailScreen(tableNumber: tableNumber),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _TableSelectionCard extends StatelessWidget {
  final int tableNumber;
  final VoidCallback onTap;

  const _TableSelectionCard({
    Key? key,
    required this.tableNumber,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.7),
                Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ],
            ),
          ),
          child: Center(
            child: Text(
              tableNumber.toString(),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TableDetailScreen extends StatelessWidget {
  final int tableNumber;

  const TableDetailScreen({Key? key, required this.tableNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table of $tableNumber'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final multiplier = index + 1;
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            '$tableNumber × $multiplier = ${tableNumber * multiplier}',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PracticeScreen(
                        tableNumber: tableNumber,
                        isSpecificTable: true,
                      ),
                    ),
                  );
                },
                child: const Text('Practice This Table'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PracticeScreen extends StatefulWidget {
  final int? tableNumber;
  final bool isSpecificTable;

  const PracticeScreen({
    Key? key,
    this.tableNumber,
    this.isSpecificTable = false,
  }) : super(key: key);

  @override
  _PracticeScreenState createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late _Question currentQuestion;
  int score = 0;
  int questionCount = 0;
  bool showResult = false;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    _generateNewQuestion();
  }

  void _generateNewQuestion() {
    setState(() {
      showResult = false;
      currentQuestion = _generateQuestion();
      questionCount++;
    });
  }

  _Question _generateQuestion() {
    final random = _Random();
    int a, b;

    if (widget.isSpecificTable && widget.tableNumber != null) {
      a = widget.tableNumber!;
      b = random.nextInt(12) + 1;
    } else {
      a = random.nextInt(12) + 1;
      b = random.nextInt(12) + 1;
    }

    final correctAnswer = a * b;
    final options = _generateOptions(correctAnswer);

    return _Question(
      a: a,
      b: b,
      correctAnswer: correctAnswer,
      options: options,
    );
  }

  List<int> _generateOptions(int correctAnswer) {
    final random = _Random();
    final options = <int>[correctAnswer];

    while (options.length < 4) {
      final option = correctAnswer + (random.nextInt(5) - 2);
      if (option > 0 && !options.contains(option)) {
        options.add(option);
      }
    }

    options.shuffle();
    return options;
  }

  void _checkAnswer(int selectedAnswer) {
    setState(() {
      showResult = true;
      isCorrect = selectedAnswer == currentQuestion.correctAnswer;
      if (isCorrect) {
        score++;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      _generateNewQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isSpecificTable
            ? Text('Practice Table ${widget.tableNumber}')
            : const Text('Practice Mode'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: questionCount / 10,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 20),
              Text(
                'Question $questionCount of 10',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    '${currentQuestion.a} × ${currentQuestion.b} = ?',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  children: currentQuestion.options.map((option) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _AnswerButton(
                        option: option,
                        onPressed: () => _checkAnswer(option),
                        isCorrect: showResult && option == currentQuestion.correctAnswer,
                        isWrong: showResult &&
                            !isCorrect &&
                            option != currentQuestion.correctAnswer,
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (showResult)
                Column(
                  children: [
                    Text(
                      isCorrect ? 'Correct! 🎉' : 'Oops! ❌',
                      style: TextStyle(
                        color: isCorrect ? Colors.green : Colors.red,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (!isCorrect)
                      Text(
                        'Correct answer: ${currentQuestion.a} × ${currentQuestion.b} = ${currentQuestion.correctAnswer}',
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              const SizedBox(height: 20),
              Text(
                'Score: $score / $questionCount',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late _Question currentQuestion;
  int score = 0;
  int questionCount = 0;
  bool showResult = false;
  bool isCorrect = false;
  bool testCompleted = false;

  @override
  void initState() {
    super.initState();
    _generateNewQuestion();
  }

  void _generateNewQuestion() {
    setState(() {
      showResult = false;
      currentQuestion = _generateQuestion();
      questionCount++;
    });
  }

  _Question _generateQuestion() {
    final random = _Random();
    final a = random.nextInt(12) + 1;
    final b = random.nextInt(12) + 1;
    final correctAnswer = a * b;
    final options = _generateOptions(correctAnswer);

    return _Question(
      a: a,
      b: b,
      correctAnswer: correctAnswer,
      options: options,
    );
  }

  List<int> _generateOptions(int correctAnswer) {
    final random = _Random();
    final options = <int>[correctAnswer];

    while (options.length < 4) {
      final option = correctAnswer + (random.nextInt(5) - 2);
      if (option > 0 && !options.contains(option)) {
        options.add(option);
      }
    }

    options.shuffle();
    return options;
  }

  void _checkAnswer(int selectedAnswer) {
    setState(() {
      showResult = true;
      isCorrect = selectedAnswer == currentQuestion.correctAnswer;
      if (isCorrect) {
        score++;
      }
    });

    if (questionCount < 10) {
      Future.delayed(const Duration(seconds: 1), () {
        _generateNewQuestion();
      });
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          testCompleted = true;
        });
      });
    }
  }

  void _restartTest() {
    setState(() {
      score = 0;
      questionCount = 0;
      testCompleted = false;
      _generateNewQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Mode'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: testCompleted
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Text(
                          'Test Completed!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Your Score: $score / 10',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Accuracy: ${(score / 10 * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _restartTest,
                          child: const Text('Restart Test'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(200, 50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: questionCount / 10,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 20),
              Text(
                'Question $questionCount of 10',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    '${currentQuestion.a} × ${currentQuestion.b} = ?',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  children: currentQuestion.options.map((option) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _AnswerButton(
                        option: option,
                        onPressed: () => _checkAnswer(option),
                        isCorrect: showResult &&
                            option == currentQuestion.correctAnswer,
                        isWrong: showResult &&
                            !isCorrect &&
                            option != currentQuestion.correctAnswer,
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (showResult)
                Text(
                  isCorrect ? 'Correct! 🎉' : 'Wrong! ❌',
                  style: TextStyle(
                    color: isCorrect ? Colors.green : Colors.red,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              Text(
                'Score: $score / $questionCount',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  String _selectedFont = 'Roboto';
  String _selectedThemeColor = 'Blue';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _selectedFont = prefs.getString('font') ?? 'Roboto';
      _selectedThemeColor = prefs.getString('themeColor') ?? 'Blue';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setString('font', _selectedFont);
    await prefs.setString('themeColor', _selectedThemeColor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                title: const Text('Dark Mode'),
                value: _darkMode,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                  MathTablesApp.of(context)?.changeThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light);
                  _saveSettings();
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Font',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedFont,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedFont = newValue;
                          });
                          _saveSettings();
                        }
                      },
                      items: <String>['Roboto', 'Open Sans', 'Montserrat', 'Lato']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Theme Color',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedThemeColor,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedThemeColor = newValue;
                          });
                          _saveSettings();
                        }
                      },
                      items: <String>['Blue', 'Green', 'Purple', 'Orange']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final int option;
  final VoidCallback onPressed;
  final bool isCorrect;
  final bool isWrong;

  const _AnswerButton({
    Key? key,
    required this.option,
    required this.onPressed,
    this.isCorrect = false,
    this.isWrong = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.surface;
    Color textColor = Theme.of(context).textTheme.bodyLarge!.color!;

    if (isCorrect) {
      backgroundColor = Colors.green;
      textColor = Colors.white;
    } else if (isWrong) {
      backgroundColor = Colors.red;
      textColor = Colors.white;
    } else {
      backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Text(
        option.toString(),
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}

class _Question {
  final int a;
  final int b;
  final int correctAnswer;
  final List<int> options;

  _Question({
    required this.a,
    required this.b,
    required this.correctAnswer,
    required this.options,
  });
}

class _Random {
  int nextInt(int max) {
    return DateTime.now().millisecond % max;
  }
}