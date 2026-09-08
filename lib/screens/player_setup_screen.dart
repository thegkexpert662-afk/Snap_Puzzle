import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'home_screen.dart';

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});
  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final TextEditingController nameController = TextEditingController();
  bool _isLoading = false;

  Future<String> generateUniquePlayerId(String playerName) async {
    final random = Random();
    String letters = playerName.trim().toUpperCase();
    if (letters.length >= 2) {
      letters = letters.substring(0, 2);
    } else if (letters.length == 1) {
      letters = '${letters}X';
    } else {
      letters = 'XX';
    }
    while (true) {
      final number = random.nextInt(9000) + 1000;
      final playerId = 'SP$number$letters';
      final doc = await FirebaseFirestore.instance.collection('players').where('playerId', isEqualTo: playerId).limit(1).get();
      if (doc.docs.isEmpty) return playerId;
    }
  }

  Future<void> _continue() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      if (nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter your name')));
        return;
      }
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        final credential = await FirebaseAuth.instance.signInAnonymously();
        user = credential.user!;
      }
      final playerRef = FirebaseFirestore.instance.collection('players').doc(user.uid);
      final playerDoc = await playerRef.get();
      if (playerDoc.exists) {
        await playerRef.update({'isOnline': true});
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('setupComplete', true);
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        return;
      }
      final playerId = await generateUniquePlayerId(nameController.text.trim());
      await playerRef.set({
        'uid': user.uid,
        'playerId': playerId,
        'name': nameController.text.trim(),
        'coins': 100,
        'bestScore': 0,
        'bestTime': 0,
        'totalScore': 0,
        'totalPuzzlesSolved': 0,
        'isOnline': true,
        'isBanned': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('setupComplete', true);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061B43),
      body: SafeArea(
        child: Stack(
          children: [
            const _SetupBackground(),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0C3B7D), Color(0xFF061D49)]),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: const Color(0xFF2385DF), width: 2),
                      boxShadow: const [BoxShadow(color: Color(0x55006DFF), blurRadius: 25, offset: Offset(0, 10))],
                    ),
                    child: Column(children: [
                      Container(width: 105, height: 105, padding: const EdgeInsets.all(12), decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFF1AB9FF), Color(0xFF1454D8)]), border: Border.all(color: Colors.white, width: 2.5), boxShadow: const [BoxShadow(color: Color(0x6600B7FF), blurRadius: 22)]), child: Image.asset('assets/images/logo.png', fit: BoxFit.contain)),
                      const SizedBox(height: 20),
                      const Text('Welcome to Snap Pazzel', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 7),
                      const Text('Create your player profile to continue', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFA8D1FF), fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 26),
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Player Name',
                          hintText: 'Enter your name',
                          prefixIcon: const Icon(Icons.person_rounded, color: Color(0xFF55C9FF)),
                          labelStyle: const TextStyle(color: Color(0xFF9CCBFF)),
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white.withOpacity(.07),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFF2C6EAB), width: 1.5)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFF2AC0FF), width: 2)),
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(width: double.infinity, height: 58, child: ElevatedButton.icon(onPressed: _continue, icon: const Icon(Icons.arrow_forward_rounded), label: AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: Text(_isLoading ? 'Please Wait...' : 'Continue', key: ValueKey(_isLoading), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF21B9FF), foregroundColor: Colors.white, elevation: 8, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))))),
                    ]),
                  ),
                ),
              ),
            ),
            if (_isLoading) Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator(color: Color(0xFF39C1FF)))),
          ],
        ),
      ),
    );
  }
}

class _SetupBackground extends StatelessWidget {
  const _SetupBackground();
  @override
  Widget build(BuildContext context) => Positioned.fill(child: DecoratedBox(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF082E6D), Color(0xFF061D49), Color(0xFF03132F)])), child: Stack(children: [Positioned(top: -90, right: -90, child: _glow(260, const Color(0xFF008BFF))), Positioned(bottom: -100, left: -100, child: _glow(260, const Color(0xFF522CFF)))]));
  static Widget _glow(double size, Color color) => IgnorePointer(child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(.23), blurRadius: 110, spreadRadius: 35)])));
}