import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'victory_screen.dart';
import '../models/puzzle_piece.dart';
import '../services/asset_image_splitter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/global_puzzle_service.dart';
import '../services/sound_service.dart';

class AssetPuzzleScreen extends StatefulWidget {
  final String assetPath;
  final int gridSize;

  const AssetPuzzleScreen({
    super.key,
    required this.assetPath,
    required this.gridSize,
  });

  @override
  State<AssetPuzzleScreen> createState() => _AssetPuzzleScreenState();
}

class _AssetPuzzleScreenState extends State<AssetPuzzleScreen> {

  List<PuzzlePiece> pieces = [];
  late BannerAd bannerAd;
  bool isBannerReady = false;

  bool loading = true;


  int coins = 100;
  static const int glowHintCost = 20;
  bool freeImageHintUsed = false;
  bool paidImageHintUsed = false;

  static const int fullImageHintCost = 100;

  bool glowHintRunning = false;

  double imageWidth = 1;
  double imageHeight = 1;

  Timer? timer;

  int seconds = 0;
  int moves = 0;

  RewardedAd? rewardedAd;

  bool rewardAdReady = false;

  @override
  void initState() {
    super.initState();

    loadPuzzle();

    loadCoins();

    loadRewardedAd();
  }

    void showRewardedAd() {

      if (!rewardAdReady || rewardedAd == null) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ad not available. Try again."),
          ),
        );

        return;
      }

      rewardedAd!.show(

        onUserEarnedReward: (ad, reward) async {

          coins += 50;

          final user = FirebaseAuth.instance.currentUser;

          if (user != null) {
            await FirebaseFirestore.instance
                .collection("players")
                .doc(user.uid)
                .update({
              "coins": coins,
            });
          }

          if (!mounted) return;

          setState(() {});

          rewardedAd?.dispose();

          rewardAdReady = false;

          loadRewardedAd();
        },
      );


    bannerAd = BannerAd(
      adUnitId: "ca-app-pub-7285341203038392/8867080119",
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isBannerReady = true;
          });
        },
      ),
    )..load();
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
      coins = doc.data()?["coins"] ?? 100;
    });

  }

  Future<void> useGlowHint() async {

    if (glowHintRunning) return;

    if (coins < glowHintCost) {
      showCoinDialog();
      return;
    }

    List<int> wrongTiles = [];

    for (int i = 0; i < pieces.length; i++) {
      if (pieces[i].correctIndex != i) {
        wrongTiles.add(i);
      }
    }

    if (wrongTiles.isEmpty) return;

    wrongTiles.shuffle();

    int hintCount = 1;

    if (widget.gridSize >= 4) hintCount = 2;
    if (widget.gridSize >= 5) hintCount = 3;
    if (widget.gridSize >= 6) hintCount = 4;

    wrongTiles = wrongTiles.take(hintCount).toList();

    setState(() {
      glowHintRunning = true;
      coins -= glowHintCost;

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {

        FirebaseFirestore.instance
            .collection("players")
            .doc(user.uid)
            .update({

          "coins": coins,

        });

      }

      for (var tile in wrongTiles) {
        pieces[tile].isGlow = true;
      }
    });

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    setState(() {

      for (var tile in wrongTiles) {
        pieces[tile].isGlow = false;
      }

      glowHintRunning = false;
    });
  }

  Future<void> showFullImageHint() async {

    // Third time not allowed
    if (freeImageHintUsed && paidImageHintUsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Image Hint limit reached for this puzzle."),
        ),
      );
      return;
    }

    // Second time → Coins
    if (freeImageHintUsed && !paidImageHintUsed) {

      if (coins < fullImageHintCost) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Need 100 Coins"),
          ),
        );
        return;
      }

      setState(() {
        coins -= fullImageHintCost;
        paidImageHintUsed = true;
      });

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection("players")
            .doc(user.uid)
            .update({
          "coins": coins,
        });
      }

    }

    // First time → Free
    if (!freeImageHintUsed) {
      setState(() {
        freeImageHintUsed = true;
      });
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              widget.assetPath,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void showCoinDialog() {

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Text("Not Enough Coins"),

          content: const Text(
            "You need 20 Coins to use Glow Hint.",
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton.icon(

              onPressed: () {

                Navigator.pop(context);

                showRewardedAd();

              },

              icon: const Icon(Icons.play_circle),

              label: const Text("Watch Ad"),

            ),

          ],

        );

      },

    );

  }



  Future<void> loadPuzzle() async {

    freeImageHintUsed = false;
    paidImageHintUsed = false;

    pieces = await AssetImageSplitter.splitImage(
      widget.assetPath,
      widget.gridSize,
    );
    shufflePieces();
    startTimer();

    final bytes =
    (await rootBundle.load(widget.assetPath))
        .buffer
        .asUint8List();

    final decoded = img.decodeImage(bytes);

    if (decoded != null) {
      imageWidth = decoded.width.toDouble();
      imageHeight = decoded.height.toDouble();
    }

    setState(() {
      loading = false;
    });
  }
  void shufflePieces() {
    pieces.shuffle();

    for (int i = 0; i < pieces.length; i++) {
      pieces[i].currentIndex = i;
    }
  }

  void swapPieces(int oldIndex, int newIndex) {
    SoundService.play("move.mp3");

    setState(() {
      final temp = pieces[oldIndex];
      pieces[oldIndex] = pieces[newIndex];
      pieces[newIndex] = temp;

      pieces[oldIndex].currentIndex = oldIndex;
      pieces[newIndex].currentIndex = newIndex;

      moves++;
      checkWin();
    });
  }
  Future<void> checkWin() async {
    bool win = true;

    for (int i = 0; i < pieces.length; i++) {
      if (pieces[i].correctIndex != i) {
        win = false;
        break;
      }
    }

    if (win) {
      timer?.cancel();


      SoundService.play("victory.mp3");

      int coinReward;

      if (seconds <= 20 && moves <= 15) {
        coinReward = 50; // ⭐⭐⭐
      } else if (seconds <= 40 && moves <= 30) {
        coinReward = 35; // ⭐⭐
      } else {
        coinReward = 20; // ⭐
      }

      final user = FirebaseAuth.instance.currentUser;

      int xpReward = 0;
      int currentLevel = 1;
      bool levelUp = false;

      if (user != null) {

        final playerDoc = await FirebaseFirestore.instance
            .collection("players")
            .doc(user.uid)
            .get();

        final playerData = playerDoc.data();

        int currentXp = playerData?["xp"] ?? 0;
        currentLevel = playerData?["level"] ?? 1;
        int nextLevelXp = playerData?["nextLevelXp"] ?? 100;

        xpReward = calculateXp(widget.gridSize, moves);

        print("Grid Size = ${widget.gridSize}");
        print("XP Reward = $xpReward");
        print("Current Level = $currentLevel");
        print("Current XP = $currentXp");

        currentXp += xpReward;
        while (currentXp >= nextLevelXp) {

          currentXp -= nextLevelXp;

          currentLevel++;
          levelUp = true;

          switch (currentLevel) {

            case 2:
              nextLevelXp = 200;
              break;

            case 3:
              nextLevelXp = 300;
              break;

            case 4:
              nextLevelXp = 400;
              break;

            case 5:
              nextLevelXp = 500;
              break;

            case 6:
              nextLevelXp = 650;
              break;

            case 7:
              nextLevelXp = 800;
              break;

            case 8:
              nextLevelXp = 1000;
              break;

            case 9:
              nextLevelXp = 1250;
              break;

            case 10:
              nextLevelXp = 1500;
              break;

            default:
              nextLevelXp += 250;
          }
        }
        int score =
            (widget.gridSize * 1000) -
                (seconds * 5) -
                (moves * 2);

        if (score < 0) score = 0;



        final totalScore =
            (playerData?["totalScore"] ?? 0) + score;
        await FirebaseFirestore.instance
            .collection("leaderboard")
            .doc(user.uid)
            .set({
          "uid": user.uid,
          "playerId": playerData?["playerId"],
          "name": playerData?["name"],
          "score": totalScore,
          "time": seconds,
          "moves": moves,
          "gridSize": widget.gridSize,
          "updatedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        print("Seconds = $seconds");
        print("Score = $score");
        await FirebaseFirestore.instance
            .collection("players")
            .doc(user.uid)
            .update({
          "totalScore": FieldValue.increment(score),
          "totalPuzzlesSolved": FieldValue.increment(1),
          "coins": FieldValue.increment(coinReward),
          "bestScore": score,
          "bestTime": seconds,
          "xp": currentXp,
          "level": currentLevel,
          "nextLevelXp": nextLevelXp,

        });
      }
      print("Sending XP = $xpReward");
      print("Sending Level = $currentLevel");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VictoryScreen(
            seconds: seconds,
            moves: moves,
            coinReward: coinReward,
            xpReward: xpReward,
            currentLevel: currentLevel,
            levelUp: levelUp,


            onNextPuzzle: () async {

              final player = await FirebaseFirestore.instance
                  .collection("players")
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .get();

              final level = player.data()?["level"] ?? 1;

              int gridSize;

              if (level <= 10) {
                gridSize = 4;
              } else if (level <= 40) {
                gridSize = 5;
              } else if (level <= 60) {
                gridSize = 6;
              } else if (level <= 75) {
                gridSize = 7;
              } else {
                gridSize = 8;
              }

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => AssetPuzzleScreen(
                    assetPath: GlobalPuzzleService.getRandomPuzzle(),
                    gridSize: gridSize,
                  ),
                ),
                    (route) => route.isFirst,
              );
            },


            onGoHome: () {
              Navigator.popUntil(
                context,
                    (route) => route.isFirst,
              );
            },

          ),
        ),
      );
    }
  }
  int calculateXp(int gridSize, int moves) {
    switch (gridSize) {
      case 3:
        if (moves <= 20) return 20;
        if (moves <= 30) return 15;
        if (moves <= 50) return 10;
        return 5;

      case 4:
        if (moves <= 20) return 40;
        if (moves <= 30) return 30;
        if (moves <= 50) return 20;
        return 10;

      case 5:
        if (moves <= 20) return 60;
        if (moves <= 30) return 45;
        if (moves <= 50) return 30;
        return 20;

      case 6:
        if (moves <= 20) return 90;
        if (moves <= 30) return 70;
        if (moves <= 50) return 50;
        return 30;

      case 7:
        if (moves <= 20) return 120;
        if (moves <= 30) return 100;
        if (moves <= 50) return 70;
        return 40;

      case 8:
        if (moves <= 20) return 160;
        if (moves <= 30) return 130;
        if (moves <= 50) return 100;
        return 60;

      default:
        return 10;
    }
  }

  void startTimer() {
    timer?.cancel();

    seconds = 0;
    moves = 0;

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        setState(() {
          seconds++;
        });
      },
    );
  }
  void loadRewardedAd() {

    RewardedAd.load(

      adUnitId: "ca-app-pub-7285341203038392/2421055875",

      request: const AdRequest(),

      rewardedAdLoadCallback: RewardedAdLoadCallback(

        onAdLoaded: (ad) {

          rewardedAd = ad;

          rewardAdReady = true;

        },

        onAdFailedToLoad: (error) {

          rewardAdReady = false;

        },

      ),

    );

  }
  @override
  void dispose() {
    timer?.cancel();
    rewardedAd?.dispose();
    bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),

        title: Text(
          "⏱️ ${seconds}s",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [

          // 🔄 Moves
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                "🔄 $moves",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 🪙 Coins
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 2),
                Text(
                  "$coins",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            visualDensity: VisualDensity.compact,
            iconSize: 28,
            tooltip: "Glow Hint (20 Coins)",
            onPressed: useGlowHint,
            icon: const Icon(
              Icons.lightbulb,
              color: Colors.amber,
            ),
          ),

          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            visualDensity: VisualDensity.compact,
            iconSize: 28,
            tooltip: "Image Hint",
            onPressed: showFullImageHint,
            icon: const Icon(
              Icons.image,
              color: Colors.blue,
            ),
          ),
        ],
      ),



        body: loading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : LayoutBuilder(
          builder: (context, constraints) {
            final boardWidth = constraints.maxWidth - 20;
            final boardHeight =
                boardWidth * (imageHeight / imageWidth);

            return SingleChildScrollView(
              child: Column(
                children: [

                SizedBox(
                width: boardWidth,
                height: boardHeight,
                child: Table(
                  border: TableBorder.all(
                    color: Colors.black12,
                    width: 1,
                  ),
                  children: List.generate(widget.gridSize, (row) {
                    return TableRow(
                      children: List.generate(widget.gridSize, (col) {
                        final index = row * widget.gridSize + col;

                        return AspectRatio(
                          aspectRatio:
                          (imageWidth / widget.gridSize) /
                              (imageHeight / widget.gridSize),
                          child: DragTarget<int>(
                            onAcceptWithDetails: (details) {
                              swapPieces(details.data, index);
                            },
                            builder: (
                                context,
                                candidateData,
                                rejectedData,
                                ) {
                              return Draggable<int>(
                                data: index,
                                feedback: SizedBox(
                                  width: boardWidth / widget.gridSize,
                                  height: boardHeight / widget.gridSize,
                                  child: Image.memory(
                                    pieces[index].image,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                childWhenDragging: Container(
                                  color: Colors.black12,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),

                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: pieces[index].isGlow
                                          ? Colors.amber
                                          : Colors.white,
                                      width: pieces[index].isGlow ? 5 : 1,
                                    ),

                                    boxShadow: pieces[index].isGlow
                                        ? [
                                      BoxShadow(
                                        color: Colors.amber.withValues(alpha: 0.8),
                                        blurRadius: 20,
                                        spreadRadius: 4,
                                      ),
                                    ]
                                        : [],

                                    borderRadius: BorderRadius.circular(6),
                                  ),

                                  child: Image.memory(
                                    pieces[index].image,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    );
                  }),
                ),
                ),

                  const SizedBox(height: 20),

                  if (isBannerReady)
                    SizedBox(
                      width: bannerAd.size.width.toDouble(),
                      height: bannerAd.size.height.toDouble(),
                      child: AdWidget(ad: bannerAd),
                    ),

                  const SizedBox(height: 10),

                ],
              ),
            );
          },
        ),
    );
  }
}