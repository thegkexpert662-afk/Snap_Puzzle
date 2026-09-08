import 'package:flutter/material.dart';

class VictoryScreen extends StatelessWidget {
  final int seconds;
  final int moves;
  final VoidCallback onNextPuzzle;
  final VoidCallback onGoHome;
  final int coinReward;
  final int xpReward;
  final int currentLevel;
  final bool levelUp;

  const VictoryScreen({
    super.key,
    required this.seconds,
    required this.moves,
    required this.coinReward,
    required this.onNextPuzzle,
    required this.onGoHome,
    required this.xpReward,
    required this.currentLevel,
    required this.levelUp,

  });

  int getStars() {
    if (seconds <= 20 && moves <= 15) {
      return 3;
    } else if (seconds <= 40 && moves <= 30) {
      return 2;
    } else {
      return 1;
    }
  }


  @override
  Widget build(BuildContext context) {
    final stars = getStars();

    return Scaffold(
      backgroundColor: const Color(0xFF0E1320),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(

                crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (levelUp)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "🎉 LEVEL UP!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Level $currentLevel Reached",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          currentLevel == 11
                              ? "🔓 5×5 Puzzle Unlocked"
                              : currentLevel == 41
                              ? "🔓 6×6 Puzzle Unlocked"
                              : currentLevel == 61
                              ? "🔓 7×7 Puzzle Unlocked"
                              : currentLevel == 76
                              ? "🔓 8×8 Puzzle Unlocked"
                              : "",
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                const Text(
                  "🏆",
                  style: TextStyle(fontSize: 100),
                ),
                const SizedBox(height: 20),
                const Text(
                  "LEVEL COMPLETE",
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                        (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        index < stars ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 40,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer, color: Colors.cyan),
                          const SizedBox(width: 8),
                          Text(
                            "Time : ${seconds}s",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.swap_horiz, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            "Moves : $moves",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Coins : +$coinReward",
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.stars,
                            color: Colors.purpleAccent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "XP : +$xpReward",
                            style: const TextStyle(
                              color: Colors.purpleAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.workspace_premium,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Level : $currentLevel",
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),


                ),

                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: onNextPuzzle,
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      "Next Puzzle",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: onGoHome,
                    icon: const Icon(Icons.home),
                    label: const Text(
                      "Home",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Share feature बाद में जोड़ेंगे
                    },
                    icon: const Icon(Icons.share),
                    label: const Text(
                      "Share Score",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],

            ),
          ),
        ),
      ),
    );
  }
}