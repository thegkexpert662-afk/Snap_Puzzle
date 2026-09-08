import 'package:flutter/material.dart';
import '../services/google_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'player_setup_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

bool _isLoading = false;

@override
Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Stack(
          children: [
         Center(
          child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(
                Icons.extension_rounded,
                size: 120,
                color: Colors.pinkAccent,
              ),

              const SizedBox(height: 25),

              const Text(
                "Snap Puzzle",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Play • Solve • Win",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 60),

              SizedBox(
                width: 320,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final user = await GoogleAuthService.signInWithGoogle();

                    if (!context.mounted) return;

                    if (user == null) return;

                    final playerDoc = await FirebaseFirestore.instance
                        .collection("players")
                        .doc(user.uid)
                        .get();

                    if (!context.mounted) return;

                    if (playerDoc.exists) {

                      final isBanned = playerDoc.data()?["isBanned"] ?? false;

                      if (isBanned) {

                        await GoogleAuthService.signOut();

                        if (!context.mounted) return;

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => AlertDialog(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Center(
                              child: Text(
                                "🚫 ACCOUNT BANNED",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            content: const Text(
                              "Your account has been banned by the Admin.\n\nPlease contact support.\n snappazzel.support@gmail.com",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 18,
                              ),
                            ),
                            actionsAlignment: MainAxisAlignment.center,
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "OK",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );

                        return;
                      }

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(),
                        ),
                      );

                    } else {

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PlayerSetupScreen(),
                        ),
                      );

                    }
                  },

                  icon: const Icon(Icons.login),

                  label: const Text(
                    "Continue with Google",
                    style: TextStyle(fontSize: 18),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                )
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: 320,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person_outline),
                  label: const Text(
                    "Continue as Guest",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      color: Colors.white24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "By continuing you agree to\nPrivacy Policy & Terms of Service",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
           if (_isLoading)
               Container(
                   color: Colors.black54,
                  child: const Center(
                   child: CircularProgressIndicator(),
               ),
           ),
        ],
      ),





    );
  }
}