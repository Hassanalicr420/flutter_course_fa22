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
      title: 'Math Tables',
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
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.black54,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.grey[900],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[850],
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white70,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white60,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.grey[800],
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
        title: const Text('Math Tables'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FeatureCard(
              icon: Icons.school,
              title: 'Learn Tables',
              subtitle: 'Practice multiplication tables',
              onTap: () {
                Navigator.pushNamed(context, '/learn');
              },
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            _FeatureCard(
              icon: Icons.fitness_center,
              title: 'Training',
              subtitle: 'Practice with random questions',
              onTap: () {
                Navigator.pushNamed(context, '/practice');
              },
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            _FeatureCard(
              icon: Icons.quiz,
              title: 'Start Test',
              subtitle: 'Test your multiplication skills',
              onTap: () {
                Navigator.pushNamed(context, '/test');
              },
              color: Colors.orange,
            ),
          ],
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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
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
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Text(
            tableNumber.toString(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 12,
                itemBuilder: (context, index) {
                  final multiplier = index + 1;
                  return Card(
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
              child: const Text('Start Practice'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
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
            : const Text('Training Mode'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: questionCount / 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 20),
            Text(
              'Question $questionCount of 10',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              '${currentQuestion.a} × ${currentQuestion.b} = ?',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: currentQuestion.options.map((option) {
                  return _AnswerButton(
                    option: option,
                    onPressed: () => _checkAnswer(option),
                    isCorrect: showResult && option == currentQuestion.correctAnswer,
                    isWrong: showResult &&
                        !isCorrect &&
                        option != currentQuestion.correctAnswer,
                  );
                }).toList(),
              ),
            ),
            if (showResult)
              Text(
                isCorrect ? 'Correct!' : 'Wrong!',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: testCompleted
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Test Completed!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              Text(
                'Your Score: $score / 10',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _restartTest,
                child: const Text('Restart Test'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 20),
            Text(
              'Question $questionCount of 10',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              '${currentQuestion.a} × ${currentQuestion.b} = ?',
              style: const TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: currentQuestion.options.map((option) {
                  return _AnswerButton(
                    option: option,
                    onPressed: () => _checkAnswer(option),
                    isCorrect:
                    showResult && option == currentQuestion.correctAnswer,
                    isWrong: showResult &&
                        !isCorrect &&
                        option != currentQuestion.correctAnswer,
                  );
                }).toList(),
              ),
            ),
            if (showResult)
              Text(
                isCorrect ? 'Correct!' : 'Wrong!',
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
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
          const Divider(),
          const Text(
            'Font',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          DropdownButton<String>(
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
          const Divider(),
          const Text(
            'Theme Color',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          DropdownButton<String>(
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
    if (isCorrect) backgroundColor = Colors.green;
    if (isWrong) backgroundColor = Colors.red;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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