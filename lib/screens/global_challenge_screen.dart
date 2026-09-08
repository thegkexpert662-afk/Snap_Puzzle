import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'asset_puzzle_screen.dart';
import 'package:snap_puzzle/services/global_puzzle_service.dart';

class GlobalChallengeScreen extends StatefulWidget {
  const GlobalChallengeScreen({super.key});

  @override
  State<GlobalChallengeScreen> createState() =>
      _GlobalChallengeScreenState();
}

class _GlobalChallengeScreenState
    extends State<GlobalChallengeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F172A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "🌍 Global Challenge",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("global_puzzles")
            .where("active", isEqualTo: true)
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Global Puzzle Available",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final puzzles = snapshot.data!.docs;

          return ListView.builder(
            itemCount: puzzles.length,
            itemBuilder: (context, index) {

              final data =
              puzzles[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  leading: const Icon(Icons.public),

                  title: Text(data["title"]),

                  subtitle: Text(
                    "Difficulty : ${data["difficulty"]}",
                  ),

                  trailing: ElevatedButton(
                    onPressed: () {

                      final randomImage = GlobalPuzzleService.getRandomPuzzle();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AssetPuzzleScreen(
                            assetPath: randomImage,
                            gridSize: 4,
                          ),
                        ),
                      );

                    },
                    child: const Text("Play"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}