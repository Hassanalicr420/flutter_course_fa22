import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class Flashcard {
  final String question;
  final String answer;

  const Flashcard({required this.question, required this.answer});
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const FlashcardScreen(),
    );
  }
}

class FlashcardScreen extends StatelessWidget {
  const FlashcardScreen({Key? key}) : super(key: key);

  static const List<Flashcard> flashcards = [
    Flashcard(question: "What is the capital of France?", answer: "Paris"),
    Flashcard(question: "What is 2 + 2?", answer: "4"),
    Flashcard(question: "What is the largest planet?", answer: "Jupiter"),
    Flashcard(question: "Who wrote 'Romeo and Juliet'?", answer: "Shakespeare"),
    Flashcard(question: "What is the fastest land animal?", answer: "Cheetah"),
    Flashcard(question: "What is the longest river?", answer: "Nile"),
    Flashcard(question: "Who was the first president of the USA?", answer: "George Washington"),
    Flashcard(question: "What is the chemical symbol for gold?", answer: "Au"),
    Flashcard(question: "How many continents are there?", answer: "7"),
    Flashcard(question: "What is the square root of 16?", answer: "4"),
    Flashcard(question: "What is the hardest natural substance?", answer: "Diamond"),
    Flashcard(question: "Who painted the Mona Lisa?", answer: "Leonardo da Vinci"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.cyan],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: flashcards.length,
          itemBuilder: (context, index) {
            return FlashcardWidget(flashcard: flashcards[index]);
          },
        ),
      ),
    );
  }
}

class FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;
  const FlashcardWidget({Key? key, required this.flashcard}) : super(key: key);

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  bool showAnswer = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => showAnswer = !showAnswer),
      child: Card(
        elevation: 8,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return RotationYTransition(
                turns: animation,
                child: child,
              );
            },
            child: Text(
              showAnswer ? widget.flashcard.answer : widget.flashcard.question,
              key: ValueKey(showAnswer),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: showAnswer ? Colors.greenAccent : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RotationYTransition extends AnimatedWidget {
  final Widget child;

  const RotationYTransition({Key? key, required this.child, required Animation<double> turns})
      : super(key: key, listenable: turns);

  @override
  Widget build(BuildContext context) {
    final Animation<double> turns = listenable as Animation<double>;
    return Transform(
      transform: Matrix4.rotationY(turns.value),
      alignment: Alignment.center,
      child: child,
    );
  }
}
