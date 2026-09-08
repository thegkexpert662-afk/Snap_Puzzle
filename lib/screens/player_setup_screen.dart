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
      letters = "${letters}X";
    } else {
      letters = "XX";
    }

    while (true) {
      final number = random.nextInt(9000) + 1000;

      final playerId = "SP$number$letters";

      final doc = await FirebaseFirestore.instance
          .collection("players")
          .where("playerId", isEqualTo: playerId)
          .limit(1)
          .get();

      if (doc.docs.isEmpty) {
        return playerId;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F172A),



      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              Image.asset(
                "assets/images/logo.png",
                height: 120,
              ),

              const SizedBox(height: 25),

              const Text(
                "Welcome to Snap Pazzel",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter Your Name",
                  hintStyle: const TextStyle(color: Colors.white54),

                  filled: true,
                  fillColor: Colors.white10,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_isLoading) return;

                    setState(() => _isLoading = true);

                    try {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Enter your name"),
                          ),
                        );
                        return;
                      }

                      // Anonymous Login
                      User? user = FirebaseAuth.instance.currentUser;

                      if (user == null) {
                        final credential =
                        await FirebaseAuth.instance.signInAnonymously();
                        user = credential.user!;
                      }

                      final playerRef = FirebaseFirestore.instance
                          .collection("players")
                          .doc(user.uid);

                      final playerDoc = await playerRef.get();

                      if (playerDoc.exists) {
                        await playerRef.update({
                          "isOnline": true,
                        });
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool("setupComplete", true);

                        if (!mounted) return;

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomeScreen(),
                          ),
                        );
                        return;
                      }

                      final playerId =
                      await generateUniquePlayerId(nameController.text.trim());

                      await playerRef.set({
                        "uid": user.uid,
                        "playerId": playerId,
                        "name": nameController.text.trim(),

                        "coins": 100,

                        "bestScore": 0,
                        "bestTime": 0,
                        "totalScore": 0,
                        "totalPuzzlesSolved": 0,
                        "isOnline": true,
                        "isBanned": false,
                        "createdAt": FieldValue.serverTimestamp(),
                      });

                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool("setupComplete", true);

                      if (!mounted) return;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(),
                        ),
                      );
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _isLoading ? "Please Wait..." : "Continue",
                      key: ValueKey(_isLoading),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}