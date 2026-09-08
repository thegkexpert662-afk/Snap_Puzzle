import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../models/puzzle_piece.dart';
import '../services/image_splitter.dart';
import 'package:confetti/confetti.dart';
import 'victory_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'asset_puzzle_screen.dart';
import '../services/global_puzzle_service.dart';
import '../services/sound_service.dart';

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
  bool _winHandled = false;
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
    if (_winHandled || oldIndex == newIndex) return;
    SoundService.play('move.mp3');
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

  int calculateXp(int gridSize, int moves) {
    switch (gridSize) {
      case 3:
        if (moves <= 20) return 20;
        if (moves <= 30) return 15;
        if (moves <= 50) return 10;
        return 5;
      case 4:
        if (moves <= 20) return 40;
        if (moves <= 30) return 30;
        if (moves <= 50) return 20;
        return 10;
      case 5:
        if (moves <= 20) return 60;
        if (moves <= 30) return 45;
        if (moves <= 50) return 30;
        return 20;
      case 6:
        if (moves <= 20) return 90;
        if (moves <= 30) return 70;
        if (moves <= 50) return 50;
        return 30;
      case 7:
        if (moves <= 20) return 120;
        if (moves <= 30) return 100;
        if (moves <= 50) return 70;
        return 40;
      case 8:
        if (moves <= 20) return 160;
        if (moves <= 30) return 130;
        if (moves <= 50) return 100;
        return 60;
      default:
        return 10;
    }
  }

  int gridForLevel(int level) {
    if (level <= 10) return 4;
    if (level <= 40) return 5;
    if (level <= 60) return 6;
    if (level <= 75) return 7;
    return 8;
  }

  Future<void> checkWin() async {
    if (_winHandled || pieces.isEmpty) return;
    for (int i = 0; i < pieces.length; i++) {
      if (pieces[i].correctIndex != i) return;
    }

    _winHandled = true;
    timer?.cancel();
    SoundService.play('victory.mp3');
    confettiController.play();

    int coinReward;
    if (seconds <= 20 && moves <= 15) {
      coinReward = 50;
    } else if (seconds <= 40 && moves <= 30) {
      coinReward = 35;
    } else {
      coinReward = 20;
    }

    int xpReward = calculateXp(widget.gridSize, moves);
    int currentLevel = 1;
    bool levelUp = false;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref = FirebaseFirestore.instance.collection('players').doc(user.uid);
      final playerDoc = await ref.get();
      final data = playerDoc.data() ?? {};

      int currentXp = (data['xp'] as num?)?.toInt() ?? 0;
      currentLevel = (data['level'] as num?)?.toInt() ?? 1;
      int nextLevelXp = (data['nextLevelXp'] as num?)?.toInt() ?? 100;

      currentXp += xpReward;
      while (currentXp >= nextLevelXp) {
        currentXp -= nextLevelXp;
        currentLevel++;
        levelUp = true;
        switch (currentLevel) {
          case 2: nextLevelXp = 200; break;
          case 3: nextLevelXp = 300; break;
          case 4: nextLevelXp = 400; break;
          case 5: nextLevelXp = 500; break;
          case 6: nextLevelXp = 650; break;
          case 7: nextLevelXp = 800; break;
          case 8: nextLevelXp = 1000; break;
          case 9: nextLevelXp = 1250; break;
          case 10: nextLevelXp = 1500; break;
          default: nextLevelXp += 250;
        }
      }

      int score = (widget.gridSize * 1000) - (seconds * 5) - (moves * 2);
      if (score < 0) score = 0;

      final totalScore = ((data['totalScore'] as num?)?.toInt() ?? 0) + score;
      await FirebaseFirestore.instance.collection('leaderboard').doc(user.uid).set({
        'uid': user.uid,
        'playerId': data['playerId'],
        'name': data['name'],
        'score': totalScore,
        'time': seconds,
        'moves': moves,
        'gridSize': widget.gridSize,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await ref.update({
        'totalScore': FieldValue.increment(score),
        'totalPuzzlesSolved': FieldValue.increment(1),
        'coins': FieldValue.increment(coinReward),
        'bestScore': score,
        'bestTime': seconds,
        'xp': currentXp,
        'level': currentLevel,
        'nextLevelXp': nextLevelXp,
      });
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VictoryScreen(
          seconds: seconds,
          moves: moves,
          coinReward: coinReward,
          xpReward: xpReward,
          currentLevel: currentLevel,
          levelUp: levelUp,
          onNextPuzzle: () async {
            final player = FirebaseAuth.instance.currentUser;
            int level = currentLevel;
            if (player != null) {
              final snap = await FirebaseFirestore.instance.collection('players').doc(player.uid).get();
              level = (snap.data()?['level'] as num?)?.toInt() ?? currentLevel;
            }
            final nextGrid = gridForLevel(level);
            GlobalPuzzleService.currentGridSize = nextGrid;
            if (!context.mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => AssetPuzzleScreen(
                  assetPath: GlobalPuzzleService.getRandomPuzzle(),
                  gridSize: nextGrid,
                ),
              ),
              (route) => route.isFirst,
            );
          },
          onGoHome: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
    );
  }

  void startTimer() {
    timer?.cancel();
    seconds = 0;
    moves = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_winHandled) setState(() => seconds++);
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
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.touch_app_rounded, color: Color(0xFF51C8FF), size: 22), SizedBox(width: 8), Flexible(child: Text('Drag and drop pieces to solve the puzzle', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB9D9F8), fontSize: 12, fontWeight: FontWeight.w600)))]),
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
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF082D6A), Color(0xFF061D49), Color(0xFF03132F)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: -80, right: -90, child: _glow(240, const Color(0xFF008BFF))),
            Positioned(bottom: -100, left: -100, child: _glow(250, const Color(0xFF322CFF))),
          ],
        ),
      ),
    );
  }
  static Widget _glow(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(.22), blurRadius: 100, spreadRadius: 35)],
        ),
      ),
    );
  }
}
