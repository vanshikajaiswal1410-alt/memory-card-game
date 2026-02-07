import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MemoryGameApp());
}

class MemoryGameApp extends StatelessWidget {
  const MemoryGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Memory Card Flip Game",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MemoryGame(),
    );
  }
}

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  List<String> emojis = ["🍎", "🍌", "🍇", "🍓", "🍉", "🍒", "🍍", "🥝"];
  List<Map<String, dynamic>> cards = [];
  List<int> selectedCards = [];
  int score = 0;
  int moves = 0;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    _generateCards();
  }

  void _generateCards() {
    cards = [];
    List<String> allEmojis = [...emojis, ...emojis];
    allEmojis.shuffle(Random());

    for (int i = 0; i < allEmojis.length; i++) {
      cards.add({
        "emoji": allEmojis[i],
        "flipped": false,
        "matched": false,
      });
    }
  }

  void _onCardTap(int index) {
    if (cards[index]["flipped"] || cards[index]["matched"] || selectedCards.length == 2 || gameOver) return;

    setState(() {
      cards[index]["flipped"] = true;
      selectedCards.add(index);
    });

    if (selectedCards.length == 2) {
      moves++;

      if (cards[selectedCards[0]]["emoji"] == cards[selectedCards[1]]["emoji"]) {
        setState(() {
          cards[selectedCards[0]]["matched"] = true;
          cards[selectedCards[1]]["matched"] = true;
          score++;
          selectedCards.clear();

          if (score == emojis.length) {
            gameOver = true;
          }
        });
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            cards[selectedCards[0]]["flipped"] = false;
            cards[selectedCards[1]]["flipped"] = false;
            selectedCards.clear();
          });
        });
      }
    }
  }

  void _resetGame() {
    setState(() {
      score = 0;
      moves = 0;
      gameOver = false;
      selectedCards.clear();
      _generateCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🃏 Memory Card Flip Game"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text("Score: $score/${emojis.length}", style: const TextStyle(fontSize: 20)),
          Text("Moves: $moves", style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                bool isFlipped = cards[index]["flipped"] || cards[index]["matched"];
                return GestureDetector(
                  onTap: () => _onCardTap(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isFlipped ? Colors.orangeAccent : Colors.blueAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        isFlipped ? cards[index]["emoji"] : "❓",
                        style: const TextStyle(fontSize: 28, color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (gameOver)
            Column(
              children: [
                const Text(
                  "🎉 Congratulations! You Won!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: _resetGame,
                  child: const Text("Play Again"),
                ),
                const SizedBox(height: 20),
              ],
            ),
        ],
      ),
    );
  }
}