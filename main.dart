import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const WordleApp());
}

class WordleApp extends StatelessWidget {
  const WordleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WordlePage(),
    );
  }
}

class WordlePage extends StatefulWidget {
  const WordlePage({super.key});

  @override
  State<WordlePage> createState() => _WordlePageState();
}

class _WordlePageState extends State<WordlePage> {
  final int wordLength = 5;
  final int maxAttempts = 6;

  final List<String> wordList = [
    "apple",
    "grape",
    "chair",
    "table",
    "light",
    "plant",
    "stone",
    "water",
    "house",
    "green",
    "brown",
    "smile",
    "train",
    "cloud",
  ];

  late String targetWord;
  List<String> guesses = [];
  String currentGuess = "";

  /// 📊 statisztikák (CSAK MEMÓRIÁBAN)
  int played = 0;
  int wins = 0;
  int streak = 0;
  int maxStreak = 0;
  List<int> distribution = List.filled(6, 0);

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    targetWord = wordList[Random().nextInt(wordList.length)];
    guesses.clear();
    currentGuess = "";
    setState(() {});
  }

  void _submitGuess() {
    if (currentGuess.length != wordLength) return;

    setState(() {
      guesses.add(currentGuess);
      currentGuess = "";
    });

    if (guesses.last == targetWord) {
      _win();
    } else if (guesses.length >= maxAttempts) {
      _lose();
    }
  }

  void _win() {
    played++;
    wins++;
    streak++;
    maxStreak = max(streak, maxStreak);
    distribution[guesses.length - 1]++;

    _showStatsDialog(true);
  }

  void _lose() {
    played++;
    streak = 0;

    _showStatsDialog(false);
  }

  Color _getColor(int i, String letter) {
    if (targetWord[i] == letter) return Colors.green;
    if (targetWord.contains(letter)) return Colors.orange;
    return Colors.grey;
  }

  Widget _buildGrid() {
    return Column(
      children: List.generate(maxAttempts, (i) {
        String guess = i < guesses.length
            ? guesses[i]
            : (i == guesses.length ? currentGuess : "");

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(wordLength, (j) {
            String letter = j < guess.length ? guess[j] : "";

            return Container(
              margin: const EdgeInsets.all(4),
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: (i < guesses.length && j < guess.length)
                    ? _getColor(j, letter)
                    : Colors.white,
              ),
              child: Text(
                letter.toUpperCase(),
                style: const TextStyle(fontSize: 20),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildKeyboard() {
    const keys = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        ...keys.split("").map((k) {
          return Padding(
            padding: const EdgeInsets.all(2),
            child: ElevatedButton(
              onPressed: () {
                if (currentGuess.length < wordLength) {
                  setState(() {
                    currentGuess += k.toLowerCase();
                  });
                }
              },
              child: Text(k),
            ),
          );
        }),
        ElevatedButton(onPressed: _submitGuess, child: const Text("ENTER")),
        ElevatedButton(
          onPressed: () {
            setState(() {
              if (currentGuess.isNotEmpty) {
                currentGuess = currentGuess.substring(
                  0,
                  currentGuess.length - 1,
                );
              }
            });
          },
          child: const Text("⌫"),
        ),
      ],
    );
  }

  void _showStatsDialog(bool win) {
    double winRate = played == 0 ? 0 : (wins / played) * 100;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(win ? "Nyertél! 🎉" : "Vesztettél 😢"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("A szó: $targetWord"),
            const SizedBox(height: 10),
            Text("Lejátszott: $played"),
            Text("Nyerések: $wins"),
            Text("Win rate: ${winRate.toStringAsFixed(1)}%"),
            Text("Streak: $streak"),
            Text("Max streak: $maxStreak"),
            const SizedBox(height: 10),
            const Text("Eloszlás:"),
            ...List.generate(6, (i) {
              return Text("${i + 1}: ${distribution[i]}");
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _newGame();
            },
            child: const Text("Új játék"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wordle"),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => _showStatsDialog(false),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildGrid(),
          const Spacer(),
          _buildKeyboard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
