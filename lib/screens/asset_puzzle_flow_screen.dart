import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/global_puzzle_service.dart';
import 'asset_puzzle_screen.dart';

class AssetPuzzleFlowScreen extends StatefulWidget {
  const AssetPuzzleFlowScreen({super.key});

  @override
  State<AssetPuzzleFlowScreen> createState() => _AssetPuzzleFlowScreenState();
}

class _AssetPuzzleFlowScreenState extends State<AssetPuzzleFlowScreen> {
  @override
  void initState() {
    super.initState();
    _startNextPuzzle();
  }

  Future<void> _startNextPuzzle() async {
    final user = FirebaseAuth.instance.currentUser;
    int level = 1;

    if (user != null) {
      final player = await FirebaseFirestore.instance.collection('players').doc(user.uid).get();
      level = (player.data()?['level'] as num?)?.toInt() ?? 1;
    }

    final gridSize = _gridForLevel(level);
    final assetPath = GlobalPuzzleService.getRandomPuzzle(gridSize: gridSize);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AssetPuzzleScreen(assetPath: assetPath, gridSize: gridSize),
      ),
    );
  }

  int _gridForLevel(int level) {
    if (level <= 10) return 4;
    if (level <= 40) return 5;
    if (level <= 60) return 6;
    if (level <= 75) return 7;
    return 8;
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF061B43),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF168DFF)),
      ),
    );
  }
}
