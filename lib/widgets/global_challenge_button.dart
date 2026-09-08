import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class GlobalChallengeButton extends StatefulWidget {
  final VoidCallback onTap;

  const GlobalChallengeButton({
    super.key,
    required this.onTap,
  });

  @override
  State<GlobalChallengeButton> createState() =>
      _GlobalChallengeButtonState();
}

class _GlobalChallengeButtonState
    extends State<GlobalChallengeButton>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.95,
      upperBound: 1.03,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return ScaleTransition(
      scale: controller,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: widget.onTap,
        child: Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [
                Color(0xffFF4081),
                Color(0xffE91E63),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(.6),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Row(
            children: [

              const SizedBox(width: 14),

              const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white24,
                child: Icon(
                  Icons.public,
                  size: 20,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Text(
                        "GLOBAL CHALLENGE\n 1st RENK PAR RAHO",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15, // 24 → 20
                        ),
                      ),

                      SizedBox(height: 4), // 6 → 4

                      Text(
                        "🏆 Climb the Global Leaderboard",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13, // 15 → 13
                        ),
                      ),

                      SizedBox(height: 2), // 4 → 2

                      Text(
                        "🔥 Beat Everyone",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(right: 18),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}