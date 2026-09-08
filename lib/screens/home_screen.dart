import 'dart:io';
import 'difficulty_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'global_challenge_screen.dart';
import 'leaderboard_screen.dart';
import '../widgets/global_challenge_button.dart';
import 'settings_screen.dart';
import '../services/sound_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/google_auth_service.dart';
import 'login_screen.dart';
import 'package:marquee/marquee.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  final TextEditingController nameController = TextEditingController();
  int coins = 0;
  RewardedAd? rewardedAd;

  bool rewardAdReady = false;
  bool _notificationShowing = false;

  int dailyAdCount = 0;

  static const int maxDailyAds = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    FirebaseFirestore.instance
        .collection("players")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      "isOnline": true,
    });

    checkBanStatus();

    loadCoins();

    listenGlobalNotification();

    loadRewardedAd();

    loadDailyAds();

    checkAndResetDailyAds();
  }
  void listenGlobalNotification() {
    FirebaseFirestore.instance
        .collection("system")
        .doc("live")
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;

      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data == null) return;

      if (data["isActive"] != true) return;

      if (_notificationShowing) return;

      _notificationShowing = true;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(
              data["title"] ?? "",
              textAlign: TextAlign.center,
            ),
            content: Text(
              data["message"] ?? "",
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () {
                  _notificationShowing = false;
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    });
  }

  Future<void> checkBanStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("players")
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    final isBanned = doc["isBanned"] ?? false;

    if (!isBanned) return;

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.red.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Center(
            child: Text(
              "🚫 ACCOUNT BANNED",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: const Text(
            "Your account has been banned by the Admin.\n\nPlease contact support.\n snappazzel.support@gmail.com",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.5,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: 120,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await GoogleAuthService.signOut();

                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                        (route) => false,
                  );
                },
                child: const Text(
                  "OK",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> loadDailyAds() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("players")
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    setState(() {
      dailyAdCount = doc.data()?["dailyAdCount"] ?? 0;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (state == AppLifecycleState.resumed) {
      FirebaseFirestore.instance
          .collection("players")
          .doc(user.uid)
          .update({
        "isOnline": true,
      });
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      FirebaseFirestore.instance
          .collection("players")
          .doc(user.uid)
          .update({
        "isOnline": false,
      });
    }
  }
  void loadRewardedAd() {
    print("Loading Rewarded Ad...");

    RewardedAd.load(
      adUnitId: "ca-app-pub-7285341203038392/2421055875",
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(

        onAdLoaded: (ad) {
          print("SUCCESS: Rewarded Ad Loaded");

          rewardedAd = ad;
          rewardAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(

            onAdDismissedFullScreenContent: (ad) {
              print("Rewarded Ad Closed");

              ad.dispose();
              rewardedAd = null;
              rewardAdReady = false;

              // Next Ad Load
              loadRewardedAd();
            },

            onAdFailedToShowFullScreenContent: (ad, error) {
              print("Rewarded Ad Failed To Show");

              ad.dispose();
              rewardedAd = null;
              rewardAdReady = false;

              loadRewardedAd();
            },

          );
        },

        onAdFailedToLoad: (LoadAdError error) {
          rewardedAd = null;
          rewardAdReady = false;

          print("FAILED");
          print("Code: ${error.code}");
          print("Domain: ${error.domain}");
          print("Message: ${error.message}");

          // Retry after 5 seconds
          Future.delayed(
            const Duration(seconds: 5),
                () {
              loadRewardedAd();
            },
          );
        },

      ),
    );
  }
  Future<void> checkAndResetDailyAds() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection("players")
        .doc(user.uid);

    final snapshot = await docRef.get();

    if (!snapshot.exists) return;

    final data = snapshot.data()!;

    final resetAt = data["dailyAdResetAt"];

    if (resetAt == null) {
      await docRef.update({
        "dailyAdCount": 0,
        "dailyAdResetAt": Timestamp.fromDate(
          DateTime.now().add(const Duration(hours: 24)),
        ),
      });

      if (!mounted) return;

      setState(() {
        dailyAdCount = 0;
      });

      return;
    }

    final resetTime = (resetAt as Timestamp).toDate();

    if (DateTime.now().isAfter(resetTime)) {
      await docRef.update({
        "dailyAdCount": 0,
        "dailyAdResetAt": Timestamp.fromDate(
          DateTime.now().add(const Duration(hours: 24)),
        ),
      });

      if (!mounted) return;

      setState(() {
        dailyAdCount = 0;
      });
    }
  }

  Future<void> showRewardedAd() async {

    // Check 24-hour reset first
    await checkAndResetDailyAds();

    print("rewardAdReady = $rewardAdReady");

    if (!rewardAdReady || rewardedAd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ad not ready. Please try again."),
        ),
      );

      return;
    }

    if (dailyAdCount >= maxDailyAds) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Daily ad limit reached. Try again after 24 hours."),
        ),
      );

      return;
    }

    rewardedAd!.show(
      onUserEarnedReward: (ad, reward) async {

        coins += 50;
        dailyAdCount++;

        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {

          final docRef = FirebaseFirestore.instance
              .collection("players")
              .doc(user.uid);

          // First ad starts the 24-hour window
          final snapshot = await docRef.get();

          final data = snapshot.data();

          final existingResetAt = data?["dailyAdResetAt"];

          final Map<String, dynamic> updateData = {
            "coins": coins,
            "dailyAdCount": dailyAdCount,
          };

          if (existingResetAt == null) {
            updateData["dailyAdResetAt"] =
                Timestamp.fromDate(
                  DateTime.now().add(
                    const Duration(hours: 24),
                  ),
                );
          }

          await docRef.update(updateData);
        }

        if (!mounted) return;

        setState(() {});
      },
    );
  }

  Future<void> loadCoins() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("players")
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    setState(() {
      coins = doc.data()?["coins"] ?? 0;
    });

  }
  Future<void> pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source);

    if (file != null) {
      final image = File(file.path);

      setState(() {
        _image = image;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>DifficultyScreen(
            imageFile: image,
          )
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "🧩 Photo Puzzle 🧩",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        actions: [

          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.amber.shade700,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                  size: 18,
                ),

                const SizedBox(width: 3),

                Text(
                  "$coins",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),

        body: Container(
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
          child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),

              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("system")
                    .doc("announcement")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const SizedBox();
                  }

                  final data =
                  snapshot.data!.data() as Map<String, dynamic>;

                  if (data["isActive"] != true) {
                    return const SizedBox();
                  }

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827), // Black Dark
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white24,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.campaign,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 24,
                            child: Marquee(
                              text: data["text"] ?? "",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              blankSpace: 80,
                              velocity: 35,
                              pauseAfterRound: const Duration(seconds: 1),
                              startPadding: 10,
                              accelerationDuration: const Duration(milliseconds: 500),
                              decelerationDuration: const Duration(milliseconds: 500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Text(
                "Challenge Your Mind",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 25),

              CircleAvatar(
                radius: 90,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    "assets/images/logo.png",
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("leaderboard")
                    .orderBy("score", descending: true)
                    .limit(1)
                    .snapshots(),
                builder: (context, snapshot) {

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return const SizedBox();
                  }

                  final data = snapshot.data!.docs.first.data()
                  as Map<String, dynamic>;

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xffFFD400),
                          Color(0xffFFB300),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Center(
                          child: Text(
                            "👑 CURRENT GLOBAL CHAMPION",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          "🥇 ${data["name"]}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "🆔 ${data["playerId"]}",
                          style: const TextStyle(fontSize: 16),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "🏆 Score : ${data["score"]}",
                        ),

                        Text(
                          "⏱ Time : ${data["time"]} sec",
                        ),

                        const SizedBox(height: 8),

                        const Center(
                          child: Text(
                            "🔥 Beat the Champion",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                },

              ),


              const SizedBox(height: 15),

              GlobalChallengeButton(
                onTap: () async {

                  SoundService.play("click.mp3");

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GlobalChallengeScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),

              Card(
                color: Colors.orange.shade700,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 20),

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    children: [

                      const Row(
                        children: [

                          Icon(
                            Icons.card_giftcard,
                            color: Colors.white,
                            size: 22,
                          ),

                          SizedBox(width: 10),

                          Text(
                            "FREE COINS",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                        ],
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Watch Ad Earn Coines",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        "🪙 Earn +50 Coins",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Today's Ads : $dailyAdCount / $maxDailyAds",
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),
                      Center(
                        child: SizedBox(
                          width: 150,
                          height: 40,
                          child: ElevatedButton.icon(
                            onPressed: showRewardedAd,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepOrange,
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),

                            icon: const Icon(
                              Icons.play_circle_fill,
                              size: 22,
                            ),

                            label: const Text(
                              "WATCH AD",
                              style: TextStyle(
                                fontSize: 12,
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

              const SizedBox(height: 15),

              ElevatedButton.icon(
                onPressed: () {
                  SoundService.play("click.mp3");
                  pickImage(ImageSource.camera);
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text("Take Photo"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              ElevatedButton.icon(
                onPressed: () {
                  SoundService.play("click.mp3");
                  pickImage(ImageSource.gallery);
                },
                icon: const Icon(Icons.photo),
                label: const Text("Choose From Gallery"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("🚀 Daily Challenge - Coming Soon"),
                    ),
                  );
                },
                icon: const Icon(Icons.emoji_events),
                label: const Text("Daily Challenge"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LeaderboardScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.leaderboard),
                label: const Text("Global Leaderboard"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 16),


              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("players")
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const SizedBox();
                  }

                  final data =
                  snapshot.data!.data() as Map<String, dynamic>;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Center(
                          child: Text(
                            "📊 YOUR STATS",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          "👤 ${data["name"]}",
                          style: const TextStyle(color: Colors.white),
                        ),

                        Text(
                          "🆔 ${data["playerId"]}",
                          style: const TextStyle(color: Colors.white70),
                        ),

                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("players")
                              .orderBy("totalScore", descending: true)
                              .snapshots(),
                          builder: (context, rankSnapshot) {

                            if (!rankSnapshot.hasData) {
                              return const SizedBox();
                            }

                            final docs = rankSnapshot.data!.docs;

                            int rank = 0;

                            for (int i = 0; i < docs.length; i++) {
                              if (docs[i].id ==
                                  FirebaseAuth.instance.currentUser!.uid) {
                                rank = i + 1;
                                break;
                              }
                            }

                            String rankText;

                            if (rank == 1) {
                              rankText = "🥇 Global Rank : #1";
                            } else if (rank == 2) {
                              rankText = "🥈 Global Rank : #2";
                            } else if (rank == 3) {
                              rankText = "🥉 Global Rank : #3";
                            } else {
                              rankText = "🏅 Global Rank : #$rank";
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                rankText,
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "🏆 Total Score : ${data["totalScore"]}",
                          style: const TextStyle(color: Colors.white),
                        ),

                        Text(
                          "🧩 Puzzles Solved : ${data["totalPuzzlesSolved"]}",
                          style: const TextStyle(color: Colors.white),
                        ),

                        Text(
                          "⏱ Best Time : ${data["bestTime"]} sec",
                          style: const TextStyle(color: Colors.white),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "⭐ Level : ${data["level"] ?? 1}",
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "✨ XP : ${data["xp"] ?? 0} / ${data["nextLevelXp"] ?? 100}",
                          style: const TextStyle(
                            color: Colors.purpleAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        LinearProgressIndicator(
                          value: ((data["xp"] ?? 0) / (data["nextLevelXp"] ?? 100)).clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.greenAccent,
                          ),
                        ),

                      ],
                    ),
                  );
                },
              ),


            ],
          ),
        ),
      ),
        ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseFirestore.instance
          .collection("players")
          .doc(user.uid)
          .update({
        "isOnline": false,
      });
    }

    super.dispose();
  }
}