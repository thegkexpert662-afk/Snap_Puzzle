import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await MobileAds.instance.initialize();
  final prefs = await SharedPreferences.getInstance();
  final bool setupComplete = prefs.getBool("setupComplete") ?? false;

  runApp(
    PhotoPuzzleApp(
      setupComplete: setupComplete,
    ),
  );
}

class PhotoPuzzleApp extends StatelessWidget {
  final bool setupComplete;

  const PhotoPuzzleApp({
    super.key,
    required this.setupComplete,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snap Pazzel',
      home: const HomeScreen(),
    );
  }
}
