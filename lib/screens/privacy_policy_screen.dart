import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Privacy Policy"),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          '''
Snap Pazzel Privacy Policy

Last Updated: July 2026

Welcome to Snap Pazzel.

Your privacy is important to us. This Privacy Policy explains what information we collect and how it is used.

1. Information We Collect

• Player Name
• Player ID
• Anonymous Firebase Authentication ID
• Game Scores
• Best Time
• Puzzle Progress
• Leaderboard Data

We do not collect passwords, bank details, or payment information.

2. Permissions Used

Camera
Used to create puzzles from photos taken with your camera.

Photo Gallery
Used to select images from your device.

Internet
Used for Firebase services, Leaderboards and Global Challenge.

Audio
Used for game sound effects.

Vibration
Used for game feedback when enabled in Settings.

3. How We Use Your Data

• Save your game progress
• Display leaderboard rankings
• Sync game statistics
• Improve game performance
• Prevent cheating

4. Advertisements
Snap Pazzel uses Google AdMob to display advertisements. 
Google AdMob may collect device identifiers and other information 
as described in Google's Privacy Policy to provide and improve 
advertising services.

5. Data Security

Your game data is stored securely using Firebase services.

6. Data Sharing

We do not sell your personal information.
Your data is only used for providing game features.

7. Children's Privacy
Snap Pazzel is intended for a general audience. 
If children use the app, they should do so under the 
guidance of a parent or guardian.

8. Changes

This Privacy Policy may be updated from time to time.
Changes will be reflected inside the app.

9. Contact

Developer:
Snap Pazzel Team

Email:- snappazzel@gmail.com


Thank you for playing Snap Pazzel.

© 2026 Snap Pazzel. All Rights Reserved.
''',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}