import 'package:flutter/material.dart';
import 'dart:math';

class TestStatistics {
  int completedTests = 0;
  int totalCorrectAnswers = 0;
  int totalQuestionsAnswered = 0;

  void update(int correct, int total) {
    completedTests++;
    totalCorrectAnswers += correct;
    totalQuestionsAnswered += total;
  }

  int get correct => totalCorrectAnswers;
  int get wrong => totalQuestionsAnswered - totalCorrectAnswers;
  double get accuracy => totalQuestionsAnswered == 0 ? 0 : (totalCorrectAnswers / totalQuestionsAnswered * 100);
}

void main() {
  runApp(const MathPracticeApp());
}

class MathPracticeApp extends StatelessWidget {
  const MathPracticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Master',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Master', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calculate, size: 120, color: Colors.blue),
            const SizedBox(height: 30),
            _buildMenuButton(
              context,
              'Learn Tables',
              Colors.blue,
              Icons.table_chart,
                  () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LearnTablePage()
                  )
              ),
            ),
            const SizedBox(height: 15),
            _buildMenuButton(
              context,
              'Practice Test',
              Colors.green,
              Icons.quiz,
                  () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PracticeTestPage()
                  )
              ),
            ),
            const SizedBox(height: 15),
            _buildMenuButton(
              context,
              'Take Challenge',
              Colors.orange,
              Icons.leaderboard,
                  () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StatisticsTestPage(statistics: TestStatistics())
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, Color color, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24),
        label: Text(text, style: const TextStyle(fontSize: 18)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}



class LearnTablePage extends StatelessWidget {
  const LearnTablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiplication Tables (1-30)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 30,
          itemBuilder: (context, index) {
            final tableNumber = index + 1;
            return _buildTableButton(tableNumber.toString(), context);
          },
        ),
      ),
    );
  }

  Widget _buildTableButton(String text, BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _getTableColor(int.parse(text)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TableDetailsPage(tableNumber: text),
          ),
        );
      },
      child: Text(
        text,
        style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getTableColor(int tableNumber) {
    final colors = [
      Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple,
      Colors.teal, Colors.indigo, Colors.amber, Colors.deepOrange, Colors.lightBlue,
      Colors.lime, Colors.cyan, Colors.deepPurple, Colors.pink, Colors.brown,
      Colors.blueGrey, Colors.redAccent, Colors.blueAccent, Colors.greenAccent,
      Colors.orangeAccent, Colors.purpleAccent, Colors.tealAccent, Colors.indigoAccent,
      Colors.amberAccent, Colors.deepOrangeAccent, Colors.lightBlueAccent,
      Colors.limeAccent, Colors.cyanAccent, Colors.deepPurpleAccent, Colors.pinkAccent
    ];
    return colors[tableNumber - 1];
  }
}

class TableDetailsPage extends StatelessWidget {
  final String tableNumber;

  const TableDetailsPage({super.key, required this.tableNumber});

  @override
  Widget build(BuildContext context) {
    List<Widget> tableRows = [];
    for (int i = 1; i <= 10; i++) {
      int multiplier = int.parse(tableNumber);
      tableRows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            '$tableNumber × $i = ${multiplier * i}',
            style: const TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$tableNumber Times Table'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getTableColor(int.parse(tableNumber)).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Table of $tableNumber',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _getTableColor(int.parse(tableNumber)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ...tableRows,
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultiplicationQuizPage(
                        tableNumber: int.parse(tableNumber),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getTableColor(int.parse(tableNumber)),
                  minimumSize: const Size(200, 50),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: const Text(
                  'PRACTICE THIS TABLE',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTableColor(int tableNumber) {
    final colors = [
      Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple,
      Colors.teal, Colors.indigo, Colors.amber, Colors.deepOrange, Colors.lightBlue,
      Colors.lime, Colors.cyan, Colors.deepPurple, Colors.pink, Colors.brown,
      Colors.blueGrey, Colors.redAccent, Colors.blueAccent, Colors.greenAccent,
      Colors.orangeAccent, Colors.purpleAccent, Colors.tealAccent, Colors.indigoAccent,
      Colors.amberAccent, Colors.deepOrangeAccent, Colors.lightBlueAccent,
      Colors.limeAccent, Colors.cyanAccent, Colors.deepPurpleAccent, Colors.pinkAccent
    ];
    return colors[tableNumber - 1];
  }
}

class MultiplicationQuizPage extends StatefulWidget {
  final int tableNumber;

  const MultiplicationQuizPage({super.key, required this.tableNumber});

  @override
  _MultiplicationQuizPageState createState() => _MultiplicationQuizPageState();
}

class _MultiplicationQuizPageState extends State<MultiplicationQuizPage> {
  late List<Map<String, dynamic>> questions;
  int currentQuestionIndex = 0;
  int score = 0;
  int? selectedAnswer;
  bool quizCompleted = false;

  @override
  void initState() {
    super.initState();
    generateQuestions();
  }

  void generateQuestions() {
    questions = [];
    final random = Random();

    for (int i = 1; i <= 10; i++) {
      int answer = widget.tableNumber * i;
      questions.add({
        'question': '${widget.tableNumber} × $i = ?',
        'answer': answer,
        'options': generateOptions(answer, random),
      });
    }
  }

  List<int> generateOptions(int correctAnswer, Random random) {
    final options = <int>[correctAnswer];
    while (options.length < 4) {
      int option = correctAnswer + random.nextInt(10) - 5;
      if (option >= 0 && !options.contains(option)) {
        options.add(option);
      }
    }
    options.shuffle();
    return options;
  }

  void checkAnswer(int answer) {
    bool isCorrect = answer == questions[currentQuestionIndex]['answer'];

    setState(() {
      selectedAnswer = answer;
      if (isCorrect) score++;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswer = null;
        });
      } else {
        setState(() => quizCompleted = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (quizCompleted) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Results'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your Score: $score/${questions.length}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultiplicationQuizPage(
                        tableNumber: widget.tableNumber,
                      ),
                    ),
                  );
                },
                child: const Text('Try Again'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to Table'),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];
    final options = (currentQuestion['options'] as List<int>).cast<int>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Table of ${widget.tableNumber}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
            ),
            const SizedBox(height: 20),
            Text(
              'Question ${currentQuestionIndex + 1}/${questions.length}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              currentQuestion['question'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ...options.map((option) {
              bool isCorrect = option == currentQuestion['answer'];
              bool isSelected = selectedAnswer == option;
              Color? buttonColor = selectedAnswer != null
                  ? isSelected
                  ? isCorrect ? Colors.green : Colors.red
                  : isCorrect ? Colors.green : null
                  : null;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: buttonColor,
                  ),
                  onPressed: selectedAnswer == null ? () => checkAnswer(option) : null,
                  child: Text(option.toString(), style: const TextStyle(fontSize: 18)),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class PracticeTestPage extends StatefulWidget {
  const PracticeTestPage({super.key});

  @override
  _PracticeTestPageState createState() => _PracticeTestPageState();
}

class _PracticeTestPageState extends State<PracticeTestPage> {
  int maxNumber = 10;
  bool additionSelected = true;
  bool subtractionSelected = false;
  bool multiplicationSelected = false;
  bool divisionSelected = false;
  String gameType = 'Test';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select difficulty',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'What would you like to train?',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      additionSelected = true;
                      subtractionSelected = false;
                      multiplicationSelected = false;
                      divisionSelected = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: additionSelected ? Colors.blue : Colors.grey,
                  ),
                  child: const Text('+', style: TextStyle(fontSize: 24)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      additionSelected = false;
                      subtractionSelected = true;
                      multiplicationSelected = false;
                      divisionSelected = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: subtractionSelected ? Colors.blue : Colors.grey,
                  ),
                  child: const Text('-', style: TextStyle(fontSize: 24)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      additionSelected = false;
                      subtractionSelected = false;
                      multiplicationSelected = true;
                      divisionSelected = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: multiplicationSelected ? Colors.blue : Colors.grey,
                  ),
                  child: const Text('×', style: TextStyle(fontSize: 24)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      additionSelected = false;
                      subtractionSelected = false;
                      multiplicationSelected = false;
                      divisionSelected = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: divisionSelected ? Colors.blue : Colors.grey,
                  ),
                  child: const Text('÷', style: TextStyle(fontSize: 24)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Difficulty (Max number = 1000)',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: maxNumber.toDouble(),
                    min: 1,
                    max: 1000,
                    divisions: 999,
                    label: maxNumber.toString(),
                    onChanged: (value) {
                      setState(() {
                        maxNumber = value.round();
                      });
                    },
                  ),
                ),
                Text('$maxNumber', style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Type of game',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChoiceChip(
                  label: const Text('Test'),
                  selected: gameType == 'Test',
                  onSelected: (selected) {
                    setState(() {
                      gameType = 'Test';
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('True/False'),
                  selected: gameType == 'TrueFalse',
                  onSelected: (selected) {
                    setState(() {
                      gameType = 'TrueFalse';
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Input'),
                  selected: gameType == 'Input',
                  onSelected: (selected) {
                    setState(() {
                      gameType = 'Input';
                    });
                  },
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PracticeQuizPage(
                        maxNumber: maxNumber,
                        operation: additionSelected
                            ? '+'
                            : subtractionSelected
                            ? '-'
                            : multiplicationSelected
                            ? '×'
                            : '÷',
                        gameType: gameType,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                child: const Text('START TEST'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class PracticeQuizPage extends StatefulWidget {
  final int maxNumber;
  final String operation;
  final String gameType;

  const PracticeQuizPage({
    super.key,
    required this.maxNumber,
    required this.operation,
    required this.gameType,
  });

  @override
  _PracticeQuizPageState createState() => _PracticeQuizPageState();
}

class _PracticeQuizPageState extends State<PracticeQuizPage> {
  late List<Map<String, dynamic>> questions;
  int currentQuestionIndex = 0;
  int score = 0;
  int? selectedAnswer;
  bool quizCompleted = false;
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    generateQuestions();
  }

  void generateQuestions() {
    questions = [];
    final random = Random();

    for (int i = 0; i < 10; i++) {
      int a = random.nextInt(widget.maxNumber) + 1;
      int b = random.nextInt(widget.maxNumber) + 1;

      if (widget.operation == '-' && a < b) {
        int temp = a;
        a = b;
        b = temp;
      } else if (widget.operation == '÷') {
        b = random.nextInt(widget.maxNumber ~/ 2) + 1;
        a = b * (random.nextInt(10) + 1);
        if (a > widget.maxNumber) {
          a = b * (random.nextInt(widget.maxNumber ~/ b) + 1);
        }
      } else if (widget.operation == '×') {
        a = random.nextInt(20) + 1;
        b = random.nextInt(20) + 1;
      }

      int answer;
      String question;
      if (widget.operation == '+') {
        answer = a + b;
        question = '$a + $b = ?';
      } else if (widget.operation == '-') {
        answer = a - b;
        question = '$a - $b = ?';
      } else if (widget.operation == '×') {
        answer = a * b;
        question = '$a × $b = ?';
      } else {
        answer = a ~/ b;
        question = '$a ÷ $b = ?';
      }

      if (widget.gameType == 'TrueFalse') {
        bool isCorrect = random.nextBool();
        int wrongAnswer = answer + (random.nextInt(5) + 1) * (random.nextBool() ? 1 : -1);
        questions.add({
          'question': widget.operation == '+'
              ? '$a + $b = ${isCorrect ? answer : wrongAnswer}'
              : widget.operation == '-'
              ? '$a - $b = ${isCorrect ? answer : wrongAnswer}'
              : widget.operation == '×'
              ? '$a × $b = ${isCorrect ? answer : wrongAnswer}'
              : '$a ÷ $b = ${isCorrect ? answer : wrongAnswer}',
          'answer': isCorrect,
          'options': [true, false],
        });
      } else {
        questions.add({
          'question': question,
          'answer': answer,
          'options': widget.gameType == 'Test' ? generateOptions(answer, random) : null,
        });
      }
    }
  }

  List<int> generateOptions(int correctAnswer, Random random) {
    final options = <int>[correctAnswer];
    while (options.length < 4) {
      int option;
      if (widget.operation == '+' || widget.operation == '-') {
        option = correctAnswer + random.nextInt(10) - 5;
      } else if (widget.operation == '×') {
        option = correctAnswer + random.nextInt(10) - 5;
      } else {
        option = correctAnswer + random.nextInt(5) - 2;
      }

      if (option >= 0 && !options.contains(option)) {
        options.add(option);
      }
    }
    options.shuffle();
    return options;
  }

  void checkAnswer(dynamic answer) {
    setState(() {
      selectedAnswer = answer;
      if (answer == questions[currentQuestionIndex]['answer']) {
        score++;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswer = null;
          _answerController.clear();
        });
      } else {
        setState(() {
          quizCompleted = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (quizCompleted) {
      return ResultPage(
        score: score,
        totalQuestions: questions.length,
        onRestart: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PracticeQuizPage(
                maxNumber: widget.maxNumber,
                operation: widget.operation,
                gameType: widget.gameType,
              ),
            ),
          );
        },
        onBack: () {
          Navigator.pop(context);
        },
      );
    }

    final currentQuestion = questions[currentQuestionIndex];
    final operationName = widget.operation == '+'
        ? 'Addition'
        : widget.operation == '-'
        ? 'Subtraction'
        : widget.operation == '×'
        ? 'Multiplication'
        : 'Division';

    return Scaffold(
      appBar: AppBar(
        title: Text('$operationName Practice'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
            ),
            const SizedBox(height: 20),
            Text(
              'Question ${currentQuestionIndex + 1}/${questions.length}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              currentQuestion['question'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            if (widget.gameType == 'Test') ...[
              ...(currentQuestion['options'] as List<int>).map((option) {
                bool isCorrect = option == currentQuestion['answer'];
                bool isSelected = selectedAnswer == option;

                Color? buttonColor;
                if (selectedAnswer != null) {
                  if (isSelected) {
                    buttonColor = isCorrect ? Colors.green : Colors.red;
                  } else if (isCorrect) {
                    buttonColor = Colors.green;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: buttonColor,
                    ),
                    onPressed: selectedAnswer == null
                        ? () => checkAnswer(option)
                        : null,
                    child: Text(
                      option.toString(),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                );
              }).toList(),
            ] else if (widget.gameType == 'TrueFalse') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedAnswer == true
                            ? (currentQuestion['answer'] == true ? Colors.green : Colors.red)
                            : null,
                      ),
                      onPressed: selectedAnswer == null
                          ? () => checkAnswer(true)
                          : null,
                      child: const Text('True', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedAnswer == false
                            ? (currentQuestion['answer'] == false ? Colors.green : Colors.red)
                            : null,
                      ),
                      onPressed: selectedAnswer == null
                          ? () => checkAnswer(false)
                          : null,
                      child: const Text('False', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ] else if (widget.gameType == 'Input') ...[
              TextField(
                controller: _answerController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Your answer',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: selectedAnswer == null
                    ? () {
                  if (_answerController.text.isNotEmpty) {
                    checkAnswer(int.tryParse(_answerController.text));
                  }
                }
                    : null,
                child: const Text('Submit'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StatisticsTestPage extends StatefulWidget {
  final TestStatistics statistics;

  const StatisticsTestPage({
    super.key,
    required this.statistics,
  });

  @override
  _StatisticsTestPageState createState() => _StatisticsTestPageState();
}

class _StatisticsTestPageState extends State<StatisticsTestPage> {
  String selectedComplexity = 'Middle';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildStatItem('Completed', widget.statistics.completedTests.toString()),
            _buildStatItem('Correct', widget.statistics.correct.toString()),
            _buildStatItem('Accuracy rate',
                '${widget.statistics.accuracy.toStringAsFixed(0)}%'),
            _buildStatItem('Wrong', widget.statistics.wrong.toString()),
            const Divider(height: 40),
            const Text(
              'Choose test complexity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            RadioListTile(
              title: const Text('Easy'),
              value: 'Easy',
              groupValue: selectedComplexity,
              onChanged: (value) => setState(() => selectedComplexity = value.toString()),
            ),
            RadioListTile(
              title: const Text('Middle'),
              value: 'Middle',
              groupValue: selectedComplexity,
              onChanged: (value) => setState(() => selectedComplexity = value.toString()),
            ),
            RadioListTile(
              title: const Text('Hard'),
              value: 'Hard',
              groupValue: selectedComplexity,
              onChanged: (value) => setState(() => selectedComplexity = value.toString()),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ComplexityQuizPage(
                        complexity: selectedComplexity,
                        statistics: widget.statistics,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                child: const Text('START TEST'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('• $label  ', style: const TextStyle(fontSize: 18)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class ComplexityQuizPage extends StatefulWidget {
  final String complexity;
  final TestStatistics statistics;

  const ComplexityQuizPage({
    super.key,
    required this.complexity,
    required this.statistics,
  });

  @override
  _ComplexityQuizPageState createState() => _ComplexityQuizPageState();
}

class _ComplexityQuizPageState extends State<ComplexityQuizPage> {
  late List<Map<String, dynamic>> questions;
  int currentQuestionIndex = 0;
  int score = 0;
  int? selectedAnswer;
  bool quizCompleted = false;

  @override
  void initState() {
    super.initState();
    generateQuestions();
  }

  void generateQuestions() {
    questions = [];
    final random = Random();
    int maxNumber = widget.complexity == 'Easy' ? 10 :
    widget.complexity == 'Hard' ? 100 : 50;

    for (int i = 0; i < 10; i++) {
      int operation = random.nextInt(3);
      int a, b, answer;
      String operator;

      if (operation == 0) {
        a = random.nextInt(maxNumber) + 1;
        b = random.nextInt(maxNumber) + 1;
        answer = a + b;
        operator = '+';
      } else if (operation == 1) {
        a = random.nextInt(maxNumber) + 1;
        b = random.nextInt(maxNumber) + 1;
        if (a < b) {
          int temp = a;
          a = b;
          b = temp;
        }
        answer = a - b;
        operator = '-';
      } else {
        a = random.nextInt(widget.complexity == 'Hard' ? 20 : 10) + 1;
        b = random.nextInt(widget.complexity == 'Hard' ? 20 : 10) + 1;
        answer = a * b;
        operator = '×';
      }

      questions.add({
        'question': '$a $operator $b = ?',
        'answer': answer,
        'options': generateOptions(answer, random),
      });
    }
  }

  List<int> generateOptions(int correctAnswer, Random random) {
    final options = <int>[correctAnswer];
    while (options.length < 4) {
      int option = correctAnswer + random.nextInt(20) - 10;
      if (option >= 0 && !options.contains(option)) {
        options.add(option);
      }
    }
    options.shuffle();
    return options;
  }

  void checkAnswer(int answer) {
    bool isCorrect = answer == questions[currentQuestionIndex]['answer'];

    setState(() {
      selectedAnswer = answer;
      if (isCorrect) score++;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswer = null;
        });
      } else {
        widget.statistics.update(score, questions.length);
        setState(() => quizCompleted = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (quizCompleted) {
      return TestResultPage(
        score: score,
        totalQuestions: questions.length,
        statistics: widget.statistics,
        onRestart: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ComplexityQuizPage(
                complexity: widget.complexity,
                statistics: widget.statistics,
              ),
            ),
          );
        },
        onBack: () => Navigator.pop(context),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];
    final options = (currentQuestion['options'] as List<int>).cast<int>();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.complexity} Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
            ),
            const SizedBox(height: 20),
            Text(
              'Question ${currentQuestionIndex + 1}/${questions.length}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              currentQuestion['question'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ...options.map((option) {
              bool isCorrect = option == currentQuestion['answer'];
              bool isSelected = selectedAnswer == option;
              Color? buttonColor = selectedAnswer != null
                  ? isSelected
                  ? isCorrect ? Colors.green : Colors.red
                  : isCorrect ? Colors.green : null
                  : null;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: buttonColor,
                  ),
                  onPressed: selectedAnswer == null ? () => checkAnswer(option) : null,
                  child: Text(option.toString(), style: const TextStyle(fontSize: 18)),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class TestResultPage extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final TestStatistics statistics;
  final VoidCallback onRestart;
  final VoidCallback onBack;

  const TestResultPage({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.statistics,
    required this.onRestart,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildStatItem('Completed', statistics.completedTests.toString()),
            _buildStatItem('Correct', statistics.correct.toString()),
            _buildStatItem('Accuracy rate', '${statistics.accuracy.toStringAsFixed(0)}%'),
            _buildStatItem('Wrong', statistics.wrong.toString()),
            const Divider(height: 40),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: onRestart,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
                    child: const Text('Try Again'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: onBack,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
                    child: const Text('Back to Menu'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('• $label  ', style: const TextStyle(fontSize: 18)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final VoidCallback onRestart;
  final VoidCallback onBack;

  const ResultPage({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.onRestart,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score / totalQuestions * 100).round();
    final emoji = percentage >= 80 ? '🎉' :
    percentage >= 60 ? '👍' :
    '😕';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Results'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Score',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '$score/$totalQuestions',
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '$percentage% Accuracy',
              style: TextStyle(
                fontSize: 24,
                color: percentage >= 70 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onRestart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(120, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: onBack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    minimumSize: const Size(120, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Menu', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}