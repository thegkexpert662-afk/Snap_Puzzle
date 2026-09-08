import 'dart:io';

import 'package:flutter/material.dart';

import 'puzzle_screen.dart';

class DifficultyScreen extends StatelessWidget {
  final File imageFile;

  const DifficultyScreen({
    super.key,
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xff0F172A),

      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,

          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff0F172A),
                Color(0xff1E293B),
              ],
            ),
          ),

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                const SizedBox(height: 20),

                const Text(
                  "🎮 Choose Difficulty",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Select your challenge",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 35),

                difficultyCard(
                  context,
                  Icons.sentiment_satisfied_alt,
                  "Easy",
                  "3 × 3",
                  Colors.green,
                  3,
                ),

                const SizedBox(height: 18),

                difficultyCard(
                  context,
                  Icons.flash_on,
                  "Medium",
                  "4 × 4",
                  Colors.orange,
                  4,
                ),

                const SizedBox(height: 18),

                difficultyCard(
                  context,
                  Icons.local_fire_department,
                  "Hard",
                  "5 × 5",
                  Colors.deepOrange,
                  5,
                ),

                const SizedBox(height: 18),

                difficultyCard(
                  context,
                  Icons.workspace_premium,
                  "Expert",
                  "6 × 6",
                  Colors.red,
                  6,
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget difficultyCard(
      BuildContext context,
      IconData icon,
      String title,
      String subTitle,
      Color color,
      int gridSize,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PuzzleScreen(
              imageFile: imageFile,
              gridSize: gridSize,
            ),
          ),
        );
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white24,
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            subTitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}