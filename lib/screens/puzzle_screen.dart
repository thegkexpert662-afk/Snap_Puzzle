import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:async';
import '../models/puzzle_piece.dart';
import '../services/image_splitter.dart';
import 'package:confetti/confetti.dart';
import 'victory_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'asset_puzzle_screen.dart';
import '../services/global_puzzle_service.dart';

class PuzzleScreen extends StatefulWidget {
  final File imageFile;
  final int gridSize;

  const PuzzleScreen({
    super.key,
    required this.imageFile,
    required this.gridSize,
  });

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  List<PuzzlePiece> pieces = [];
  bool loading = true;
  double imageWidth = 1;
  double imageHeight = 1;

  Timer? timer;

  int seconds = 0;
  int moves = 0;


  late ConfettiController confettiController;

  @override
  void initState() {
    super.initState();
    loadPuzzle();
    confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }
  void shufflePieces() {
    pieces.shuffle();

    for (int i = 0; i < pieces.length; i++) {
      pieces[i].currentIndex = i;
    }
  }
  void swapPieces(int oldIndex, int newIndex) {
    setState(() {
      final temp = pieces[oldIndex];
      pieces[oldIndex] = pieces[newIndex];
      pieces[newIndex] = temp;

      pieces[oldIndex].currentIndex = oldIndex;
      pieces[newIndex].currentIndex = newIndex;
      moves++;
    });

    checkWin();
  }
  Future<void> checkWin() async {
    bool win = true;

    for (int i = 0; i < pieces.length; i++) {
      if (pieces[i].correctIndex != i) {
        win = false;
        break;
      }
    }

    if (win) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        int score = (widget.gridSize * 1000) - (seconds * 5) - (moves * 2);

        if (score < 0) score = 0;

        final playerDoc = await FirebaseFirestore.instance
            .collection("players")
            .doc(user.uid)
            .get();

        final playerData = playerDoc.data();
      }
      timer?.cancel();
      confettiController.play();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("🎉 Puzzle Completed"),
          content: const Text("Your puzzle has been completed successfully."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dialog बंद
                Navigator.pop(context); // Puzzle Screen बंद
              },
              child: const Text("Done"),
            ),
          ],
        ),
      );
    }
  }
  void startTimer() {
    timer?.cancel();

    seconds = 0;
    moves = 0;

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        setState(() {
          seconds++;
        });
      },
    );
  }

  Future<void> loadPuzzle() async {
    pieces = await ImageSplitter.splitImage(
      widget.imageFile,
      widget.gridSize,
    );

    shufflePieces();

    startTimer();

    final bytes = await widget.imageFile.readAsBytes();

    final decoded = img.decodeImage(bytes);

    if (decoded != null) {
      imageWidth = decoded.width.toDouble();
      imageHeight = decoded.height.toDouble();
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "⏱️ ${seconds}s   🔄 $moves",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: ConfettiWidget(
        confettiController: confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        emissionFrequency: 0.15,
        numberOfParticles: 120,
        maxBlastForce: 60,
        minBlastForce: 25,
        gravity: 0.15,
        shouldLoop: false,
        colors: const [
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.yellow,
          Colors.purple,
          Colors.orange,
          Colors.pink,
          Colors.cyan,
          Colors.white,
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
        builder: (context, constraints) {

          final boardWidth = constraints.maxWidth - 20;
          final boardHeight =
              boardWidth * (imageHeight / imageWidth);

          return Center(
            child: SizedBox(
              width: boardWidth,
              height: boardHeight,
              child: Table(
                defaultColumnWidth: const FlexColumnWidth(),
                border: TableBorder.all(
                  color: Colors.black12,
                  width: 1,
                ),
                children: List.generate(widget.gridSize, (row) {
                  return TableRow(
                    children: List.generate(widget.gridSize, (col) {

                      final index = row * widget.gridSize + col;

                      return AspectRatio(
                          aspectRatio:
                          (imageWidth / widget.gridSize) /
                              (imageHeight / widget.gridSize),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                          ),
                          child: DragTarget<int>(
                            onAcceptWithDetails: (details) {
                              swapPieces(details.data, index);
                            },
                            builder: (context, candidateData, rejectedData) {
                              return Draggable<int>(
                                data: index,

                                feedback: SizedBox(
                                  width: 100,
                                  child: Image.memory(
                                    pieces[index].image,
                                    fit: BoxFit.fill,
                                  ),
                                ),

                                childWhenDragging: Container(
                                  color: Colors.black12,
                                ),

                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                  ),
                                  child: Image.memory(
                                    pieces[index].image,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              );
                            },
                          )
                        )
                      );

                    }),
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }
  @override
  void dispose() {
    timer?.cancel();
    confettiController.dispose();
    super.dispose();
  }
}