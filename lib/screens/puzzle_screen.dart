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
  const PuzzleScreen({super.key, required this.imageFile, required this.gridSize});
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
    confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  void shufflePieces() {
    pieces.shuffle();
    for (int i = 0; i < pieces.length; i++) pieces[i].currentIndex = i;
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
        final playerDoc = await FirebaseFirestore.instance.collection('players').doc(user.uid).get();
        final playerData = playerDoc.data();
      }
      timer?.cancel();
      confettiController.play();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF092B62),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('🎉 Puzzle Completed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          content: const Text('Your puzzle has been completed successfully.', style: TextStyle(color: Color(0xFFC8E1FF))),
          actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('Done', style: TextStyle(color: Color(0xFF4CCBFF), fontWeight: FontWeight.bold)))],
        ),
      );
    }
  }

  void startTimer() {
    timer?.cancel();
    seconds = 0;
    moves = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => seconds++);
    });
  }

  Future<void> loadPuzzle() async {
    pieces = await ImageSplitter.splitImage(widget.imageFile, widget.gridSize);
    shufflePieces();
    startTimer();
    final bytes = await widget.imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded != null) {
      imageWidth = decoded.width.toDouble();
      imageHeight = decoded.height.toDouble();
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061B43),
      body: SafeArea(
        child: Stack(children: [
          const _PuzzleBackground(),
          Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(children: [
                _CircleButton(onTap: () => Navigator.pop(context), icon: Icons.arrow_back_rounded),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Solve Puzzle', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
                  Text('${widget.gridSize} × ${widget.gridSize} Challenge', style: const TextStyle(color: Color(0xFF9CCBFF), fontSize: 12, fontWeight: FontWeight.w600)),
                ])),
                _StatPill(icon: Icons.timer_rounded, value: '${seconds}s', color: const Color(0xFF45D5FF)),
                const SizedBox(width: 7),
                _StatPill(icon: Icons.swap_horiz_rounded, value: '$moves', color: const Color(0xFF58E69B)),
              ]),
            ),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF36B9FF)))
                  : LayoutBuilder(builder: (context, constraints) {
                      final boardWidth = constraints.maxWidth - 20;
                      final boardHeight = boardWidth * (imageHeight / imageWidth);
                      return Center(
                        child: Container(
                          width: boardWidth,
                          height: boardHeight,
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF04142F),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFF2A8FE0), width: 2),
                            boxShadow: const [BoxShadow(color: Color(0x66006DFF), blurRadius: 25, spreadRadius: 2)],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Table(
                              defaultColumnWidth: const FlexColumnWidth(),
                              border: TableBorder.all(color: Colors.white24, width: 1),
                              children: List.generate(widget.gridSize, (row) => TableRow(children: List.generate(widget.gridSize, (col) {
                                final index = row * widget.gridSize + col;
                                return AspectRatio(
                                  aspectRatio: (imageWidth / widget.gridSize) / (imageHeight / widget.gridSize),
                                  child: Container(
                                    decoration: BoxDecoration(border: Border.all(color: Colors.white70)),
                                    child: DragTarget<int>(
                                      onAcceptWithDetails: (details) => swapPieces(details.data, index),
                                      builder: (context, candidateData, rejectedData) => Draggable<int>(
                                        data: index,
                                        feedback: Material(color: Colors.transparent, child: SizedBox(width: 100, child: Image.memory(pieces[index].image, fit: BoxFit.fill))),
                                        childWhenDragging: Container(color: Colors.black26),
                                        child: Image.memory(pieces[index].image, fit: BoxFit.fill),
                                      ),
                                    ),
                                  ),
                                );
                              }))),
                            ),
                          ),
                        ),
                      );
                    }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: const Color(0xCC092B62), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF1B6DB3), width: 1.5)),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.touch_app_rounded, color: Color(0xFF51C8FF), size: 22), SizedBox(width: 8), Text('Drag and drop pieces to solve the puzzle', style: TextStyle(color: Color(0xFFB9D9F8), fontSize: 12, fontWeight: FontWeight.w600))]),
              ),
            ),
          ]),
          Align(alignment: Alignment.topCenter, child: IgnorePointer(child: ConfettiWidget(confettiController: confettiController, blastDirectionality: BlastDirectionality.explosive, emissionFrequency: 0.15, numberOfParticles: 120, maxBlastForce: 60, minBlastForce: 25, gravity: 0.15, shouldLoop: false, colors: const [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple, Colors.orange, Colors.pink, Colors.cyan, Colors.white]))),
        ]),
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

class _StatPill extends StatelessWidget {
  final IconData icon; final String value; final Color color;
  const _StatPill({required this.icon, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9), decoration: BoxDecoration(color: const Color(0xFF092B62), borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withOpacity(.55))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: color, size: 18), const SizedBox(width: 5), Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900))]));
}

class _CircleButton extends StatelessWidget {
  final VoidCallback onTap; final IconData icon;
  const _CircleButton({required this.onTap, required this.icon});
  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(onTap: onTap, customBorder: const CircleBorder(), child: Container(width: 52, height: 52, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFF0B438B), Color(0xFF061D4D)]), border: Border.all(color: const Color(0xFF1167C8), width: 2)), child: Icon(icon, color: Colors.white, size: 30))));
}

class _PuzzleBackground extends StatelessWidget {
  const _PuzzleBackground();
  @override
  Widget build(BuildContext context) => Positioned.fill(child: DecoratedBox(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF082D6A), Color(0xFF061D49), Color(0xFF03132F)])), child: Stack(children: [Positioned(top: -80, right: -90, child: _glow(240, const Color(0xFF008BFF))), Positioned(bottom: -100, left: -100, child: _glow(250, const Color(0xFF322CFF)))]));
  static Widget _glow(double size, Color color) => IgnorePointer(child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(.22), blurRadius: 100, spreadRadius: 35)])));
}