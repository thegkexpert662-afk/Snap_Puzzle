import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Terms & Conditions"),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          '''
Snap Pazzel Terms & Conditions

Last Updated: July 2026

Welcome to Snap Pazzel.

By using this application, you agree to the following terms.

1. Acceptance

By downloading or using Snap Pazzel, you agree to follow these Terms & Conditions.

2. Fair Play

• Cheating is not allowed.
• Modified APKs are prohibited.
• Fake scores may result in leaderboard removal or account restrictions.

3. Player Data

Your game progress, score and leaderboard information are stored securely using Firebase.

4. Intellectual Property

All logos, graphics, game design and original content of Snap Pazzel belong to the developer unless otherwise stated.

5. User Content

Images selected from your Camera or Gallery are used only to generate puzzles on your device. We do not claim ownership of your personal photos, and we do not sell, share, or use them for any purpose other than creating puzzles within the app.

6. Advertisements

The app may display advertisements provided by Google AdMob.

7. Updates

Features and gameplay may change through future updates.

8. Limitation of Liability

We are not responsible for data loss caused by device failure, operating system issues or third-party services.

9. Termination

We reserve the right to suspend or restrict access to the leaderboard or game 
services if these Terms are violated, including cheating or the use of modified 
versions of the app.

10. Contact

Developer:
Snap Pazzel Team
snappazzel@gmail.com

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