import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marquee/marquee.dart';

import '../services/google_auth_service.dart';
import '../services/sound_service.dart';
import '../widgets/global_challenge_button.dart';
import 'difficulty_screen.dart';
import 'global_challenge_screen.dart';
import 'leaderboard_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();
  int coins = 0;
  int dailyAdCount = 0;
  int _selectedNav = 0;
  RewardedAd? rewardedAd;
  bool rewardAdReady = false;
  bool _notificationShowing = false;
  static const int maxDailyAds = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) FirebaseFirestore.instance.collection('players').doc(user.uid).update({'isOnline': true});
    checkBanStatus();
    loadCoins();
    loadDailyAds();
    checkAndResetDailyAds();
    listenGlobalNotification();
    loadRewardedAd();
  }

  void listenGlobalNotification() {
    FirebaseFirestore.instance.collection('system').doc('live').snapshots().listen((snapshot) {
      if (!mounted || !snapshot.exists || _notificationShowing) return;
      final data = snapshot.data();
      if (data == null || data['isActive'] != true) return;
      _notificationShowing = true;
      showDialog<void>(context: context, barrierDismissible: false, builder: (dialogContext) => AlertDialog(
        title: Text(data['title']?.toString() ?? '', textAlign: TextAlign.center),
        content: Text(data['message']?.toString() ?? '', textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [ElevatedButton(onPressed: () { _notificationShowing = false; Navigator.pop(dialogContext); }, child: const Text('OK'))],
      ));
    });
  }

  Future<void> checkBanStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('players').doc(user.uid).get();
    if (!doc.exists) return;
    final isBanned = doc.data()?['isBanned'] ?? false;
    if (isBanned != true || !mounted) return;
    showDialog<void>(context: context, barrierDismissible: false, builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.red.shade700,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Center(child: Text('🚫 ACCOUNT BANNED', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
      content: const Text('Your account has been banned by the Admin.\n\nPlease contact support.\nsnappazzel.support@gmail.com', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5)),
      actionsAlignment: MainAxisAlignment.center,
      actions: [ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () async {
        await GoogleAuthService.signOut();
        if (!dialogContext.mounted) return;
        Navigator.pushAndRemoveUntil(dialogContext, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
      }, child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)))],
    ));
  }

  Future<void> loadDailyAds() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('players').doc(user.uid).get();
    if (!doc.exists || !mounted) return;
    setState(() => dailyAdCount = doc.data()?['dailyAdCount'] ?? 0);
  }

  Future<void> loadCoins() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('players').doc(user.uid).get();
    if (!doc.exists || !mounted) return;
    setState(() => coins = doc.data()?['coins'] ?? 0);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final online = state == AppLifecycleState.resumed;
    if (online || state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      FirebaseFirestore.instance.collection('players').doc(user.uid).update({'isOnline': online});
    }
  }

  void loadRewardedAd() {
    RewardedAd.load(adUnitId: 'ca-app-pub-7285341203038392/2421055875', request: const AdRequest(), rewardedAdLoadCallback: RewardedAdLoadCallback(
      onAdLoaded: (ad) {
        rewardedAd = ad;
        rewardAdReady = true;
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) { ad.dispose(); rewardedAd = null; rewardAdReady = false; loadRewardedAd(); },
          onAdFailedToShowFullScreenContent: (ad, error) { ad.dispose(); rewardedAd = null; rewardAdReady = false; loadRewardedAd(); },
        );
        if (mounted) setState(() {});
      },
      onAdFailedToLoad: (error) {
        rewardedAd = null;
        rewardAdReady = false;
        Future.delayed(const Duration(seconds: 5), () { if (mounted) loadRewardedAd(); });
      },
    ));
  }

  Future<void> checkAndResetDailyAds() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final docRef = FirebaseFirestore.instance.collection('players').doc(user.uid);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;
    final data = snapshot.data()!;
    final resetAt = data['dailyAdResetAt'];
    if (resetAt == null) {
      await docRef.update({'dailyAdCount': 0, 'dailyAdResetAt': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 24)))});
      if (mounted) setState(() => dailyAdCount = 0);
      return;
    }
    final resetTime = (resetAt as Timestamp).toDate();
    if (DateTime.now().isAfter(resetTime)) {
      await docRef.update({'dailyAdCount': 0, 'dailyAdResetAt': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 24)))});
      if (mounted) setState(() => dailyAdCount = 0);
    }
  }

  Future<void> showRewardedAd() async {
    await checkAndResetDailyAds();
    if (dailyAdCount >= maxDailyAds) { _showMessage('Daily ad limit reached. Try again after 24 hours.'); return; }
    if (!rewardAdReady || rewardedAd == null) { _showMessage('Ad not ready. Please try again.'); return; }
    rewardedAd!.show(onUserEarnedReward: (ad, reward) async {
      coins += 50;
      dailyAdCount++;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docRef = FirebaseFirestore.instance.collection('players').doc(user.uid);
        final snapshot = await docRef.get();
        final data = snapshot.data();
        final updateData = <String, dynamic>{'coins': coins, 'dailyAdCount': dailyAdCount};
        if (data?['dailyAdResetAt'] == null) updateData['dailyAdResetAt'] = Timestamp.fromDate(DateTime.now().add(const Duration(hours: 24)));
        await docRef.update(updateData);
      }
      if (mounted) setState(() {});
    });
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source);
    if (file == null || !mounted) return;
    final image = File(file.path);
    SoundService.play('click.mp3');
    Navigator.push(context, MaterialPageRoute(builder: (_) => DifficultyScreen(imageFile: image)));
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openSettings() => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
  void _openStats() => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen()));

  void _handleBottomNav(int index) {
    setState(() => _selectedNav = index);
    SoundService.play('click.mp3');
    switch (index) {
      case 0: break;
      case 1: _showMessage('Your puzzles will appear here.'); break;
      case 2: showRewardedAd(); break;
      case 3: _openStats(); break;
      case 4: _openSettings(); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(extendBody: true, backgroundColor: const Color(0xFF071B43), body: SafeArea(bottom: false, child: Stack(children: [
      const _HomeBackground(),
      CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [SliverPadding(padding: const EdgeInsets.fromLTRB(18, 12, 18, 130), sliver: SliverList(delegate: SliverChildListDelegate([
        _buildHeader(), const SizedBox(height: 14), _buildAnnouncement(), const SizedBox(height: 12), _buildLogoHero(), const SizedBox(height: 14), _buildCreatePuzzleCard(), const SizedBox(height: 12), _buildQuickActions(), const SizedBox(height: 14), _buildQuoteBanner(), const SizedBox(height: 16), _buildChampionCard(), const SizedBox(height: 16), _buildRewardsCard(), const SizedBox(height: 16), _buildStatsCard(),
      ]))) ]),
      Align(alignment: Alignment.bottomCenter, child: _buildBottomNavigation()),
    ])));
  }

  Widget _buildHeader() => Row(children: [
    Container(width: 58, height: 58, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: const [BoxShadow(color: Color(0x5500B7FF), blurRadius: 14, spreadRadius: 2)], gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF18AFFF), Color(0xFF1364D9)])), child: const Icon(Icons.person, color: Colors.white, size: 36)),
    const SizedBox(width: 12), const Spacer(), _buildCoinPill(), const SizedBox(width: 8), _roundIconButton(Icons.settings, _openSettings),
  ]);

  Widget _buildCoinPill() => Container(height: 50, padding: const EdgeInsets.symmetric(horizontal: 9), decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(colors: [Color(0xFF12396D), Color(0xFF071D47)]), border: Border.all(color: const Color(0xFF2D79BD), width: 2), boxShadow: const [BoxShadow(color: Color(0x3300B7FF), blurRadius: 12)]), child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 34, height: 34, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFFFFF06A), Color(0xFFFFA900)])), child: const Icon(Icons.star, color: Colors.white, size: 22)), const SizedBox(width: 7), Text('$coins', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(width: 7), Container(width: 34, height: 34, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF8AF84E), Color(0xFF1BCB50)])), child: const Icon(Icons.add, color: Colors.white, size: 24))]));

  Widget _roundIconButton(IconData icon, VoidCallback onTap) => Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(30), onTap: onTap, child: Container(width: 52, height: 52, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF284A78), Color(0xFF071A3C)]), border: Border.all(color: Colors.white24, width: 1.5)), child: Icon(icon, color: Colors.white, size: 28))));

  Widget _buildAnnouncement() => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(stream: FirebaseFirestore.instance.collection('system').doc('announcement').snapshots(), builder: (context, snapshot) {
    if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();
    final data = snapshot.data!.data();
    if (data == null || data['isActive'] != true) return const SizedBox.shrink();
    return Container(height: 38, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: const Color(0xAA071A3C), borderRadius: BorderRadius.circular(19), border: Border.all(color: Colors.white12)), child: Row(children: [const Icon(Icons.campaign_rounded, color: Color(0xFF59D7FF), size: 21), const SizedBox(width: 9), Expanded(child: Marquee(text: data['text']?.toString() ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13), velocity: 35, blankSpace: 60, pauseAfterRound: const Duration(seconds: 1)))]));
  });

  Widget _buildLogoHero() => Column(children: [Image.asset('assets/images/logo.png', width: 270, height: 125, fit: BoxFit.contain, errorBuilder: (_, __, ___) => _fallbackLogo()), const SizedBox(height: 4), const Text('TURN YOUR PHOTOS INTO PUZZLES', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.3, shadows: [Shadow(color: Color(0xFF00BFFF), blurRadius: 10)]))]);
  Widget _fallbackLogo() => const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Snap', style: TextStyle(color: Colors.white, fontSize: 62, fontWeight: FontWeight.w900, height: .8, shadows: [Shadow(color: Color(0xFF21B9FF), blurRadius: 12)])), Text('Pazzel', style: TextStyle(color: Color(0xFFFFD51A), fontSize: 42, fontWeight: FontWeight.w900, height: .9, shadows: [Shadow(color: Color(0xFFFF8C00), blurRadius: 8)]))]);

  Widget _buildCreatePuzzleCard() => _gradientCard(gradient: const [Color(0xFF18B9FF), Color(0xFF0069EA)], padding: const EdgeInsets.fromLTRB(18, 17, 12, 17), child: Row(children: [Container(width: 94, height: 94, decoration: BoxDecoration(color: Colors.white.withOpacity(.15), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white30)), child: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white, size: 54)), const SizedBox(width: 15), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Create', style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900)), Text('New Puzzle', style: TextStyle(color: Color(0xFFFFE11A), fontSize: 27, fontWeight: FontWeight.w900, height: .95)), SizedBox(height: 9), Text('Turn your photos into\namazing jigsaw puzzles', style: TextStyle(color: Colors.white, fontSize: 13, height: 1.35))])), _circleArrow(() { SoundService.play('click.mp3'); pickImage(ImageSource.gallery); })]));

  Widget _buildQuickActions() => Column(children: [Row(children: [Expanded(child: _smallActionCard(title: 'Take Photo', subtitle: 'Capture & Play', icon: Icons.camera_alt_rounded, gradient: const [Color(0xFFFF45B6), Color(0xFFD60096)], onTap: () => pickImage(ImageSource.camera))), const SizedBox(width: 12), Expanded(child: _smallActionCard(title: 'Choose from\nGallery', subtitle: 'Select & Play', icon: Icons.photo_library_rounded, gradient: const [Color(0xFF62F126), Color(0xFF00A94B)], onTap: () => pickImage(ImageSource.gallery)))]), const SizedBox(height: 12), Row(children: [Expanded(child: _smallActionCard(title: 'Daily\nChallenge', subtitle: 'New Puzzle Every Day', icon: Icons.emoji_events_rounded, gradient: const [Color(0xFFFFD32A), Color(0xFFFF7414)], onTap: () => _showMessage('🚀 Daily Challenge - Coming Soon'))), const SizedBox(width: 12), Expanded(child: _smallActionCard(title: 'Leaderboard', subtitle: 'See Your Rank', icon: Icons.bar_chart_rounded, gradient: const [Color(0xFF9A49FF), Color(0xFF5A14D8)], onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())); }))])]);

  Widget _smallActionCard({required String title, required String subtitle, required IconData icon, required List<Color> gradient, required VoidCallback onTap}) => Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(22), onTap: () { SoundService.play('click.mp3'); onTap(); }, child: Container(height: 106, padding: const EdgeInsets.all(13), decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white38, width: 1.2), boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 10, offset: Offset(0, 6))]), child: Row(children: [Icon(icon, color: Colors.white, size: 42), const SizedBox(width: 10), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 2, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900, height: 1.05)), const SizedBox(height: 5), Text(subtitle, maxLines: 2, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))])), const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 28)]))));

  Widget _buildQuoteBanner() => Container(height: 104, padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: const Color(0xFFF3F7FC), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white, width: 2)), child: Row(children: [const Icon(Icons.extension_rounded, color: Color(0xFF058CF4), size: 54), const SizedBox(width: 13), const Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('“Small Pieces,', style: TextStyle(color: Color(0xFF173D78), fontSize: 20, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)), Text('Big Happiness”', style: TextStyle(color: Color(0xFF173D78), fontSize: 20, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)), SizedBox(height: 5), Text('Solve  •  Collect  •  Relax', style: TextStyle(color: Color(0xFF1266B5), fontSize: 11, fontWeight: FontWeight.w700))])), const Icon(Icons.favorite_border_rounded, color: Color(0xFF173D78), size: 28)]));

  Widget _buildChampionCard() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: FirebaseFirestore.instance.collection('leaderboard').orderBy('score', descending: true).limit(1).snapshots(), builder: (context, snapshot) {
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();
    final data = snapshot.data!.docs.first.data();
    return _gradientCard(gradient: const [Color(0xFFFFE45A), Color(0xFFFFA900)], child: Column(children: [const Text('👑 CURRENT GLOBAL CHAMPION', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900)), const SizedBox(height: 9), Text('🥇 ${data['name'] ?? 'Champion'}', style: const TextStyle(color: Colors.black, fontSize: 21, fontWeight: FontWeight.w900)), Text('🏆 Score: ${data['score'] ?? 0}   •   ⏱ ${data['time'] ?? 0} sec', style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w700)), const SizedBox(height: 5), const Text('🔥 Beat the Champion', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900))]));
  });

  Widget _buildRewardsCard() => _gradientCard(gradient: const [Color(0xFF0A82FF), Color(0xFF0048B8)], child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 25), const SizedBox(width: 9), const Expanded(child: Text('FREE COINS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16))), Text('$dailyAdCount/$maxDailyAds', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700))]), const SizedBox(height: 9), const Text('Watch Ad • Earn +50 Coins', style: TextStyle(color: Color(0xFFB9FF62), fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 11), SizedBox(width: double.infinity, height: 45, child: ElevatedButton.icon(onPressed: showRewardedAd, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF005ED1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))), icon: const Icon(Icons.play_circle_fill_rounded), label: const Text('WATCH AD', style: TextStyle(fontWeight: FontWeight.w900))))]));

  Widget _buildStatsCard() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(stream: FirebaseFirestore.instance.collection('players').doc(user.uid).snapshots(), builder: (context, snapshot) {
      if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();
      final data = snapshot.data!.data() ?? {};
      return Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: const Color(0xD9071A3C), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Center(child: Text('📊 YOUR STATS', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))), const SizedBox(height: 13), Text('👤 ${data['name'] ?? 'Player'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text('🏆 Total Score: ${data['totalScore'] ?? 0}', style: const TextStyle(color: Colors.white70)), Text('🧩 Puzzles Solved: ${data['totalPuzzlesSolved'] ?? 0}', style: const TextStyle(color: Colors.white70)), Text('⏱ Best Time: ${data['bestTime'] ?? 0} sec', style: const TextStyle(color: Colors.white70)), const SizedBox(height: 10), Row(children: [Text('⭐ Level ${data['level'] ?? 1}', style: const TextStyle(color: Color(0xFFFFD52A), fontSize: 17, fontWeight: FontWeight.w900)), const Spacer(), Text('${data['xp'] ?? 0} / ${data['nextLevelXp'] ?? 100} XP', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700))]), const SizedBox(height: 8), ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(minHeight: 9, value: (((data['xp'] ?? 0) as num) / ((data['nextLevelXp'] ?? 100) as num)).clamp(0.0, 1.0).toDouble(), backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF42F56C))))]));
    });
  }

  Widget _gradientCard({required List<Color> gradient, required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(16)}) => Container(width: double.infinity, padding: padding, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white38, width: 1.2), boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 12, offset: Offset(0, 6))]), child: child);
  Widget _circleArrow(VoidCallback onTap) => Material(color: Colors.transparent, child: InkWell(customBorder: const CircleBorder(), onTap: onTap, child: Container(width: 58, height: 58, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFFFFF15B), Color(0xFFFFA400)]), boxShadow: [BoxShadow(color: Color(0x66FFD000), blurRadius: 14)]), child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF9A4A00), size: 34))));

  Widget _buildBottomNavigation() {
    const items = [(Icons.home_rounded, 'Home'), (Icons.photo_library_rounded, 'My Puzzles'), (Icons.emoji_events_rounded, 'Rewards'), (Icons.bar_chart_rounded, 'Stats'), (Icons.person_rounded, 'Profile')];
    return Container(margin: const EdgeInsets.fromLTRB(16, 0, 16, 12), padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8), decoration: BoxDecoration(color: const Color(0xF20A1C3B), borderRadius: BorderRadius.circular(34), border: Border.all(color: Colors.white12, width: 1.5), boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 22, offset: Offset(0, 8))]), child: Row(children: List.generate(items.length, (index) { final selected = _selectedNav == index; final item = items[index]; return Expanded(child: GestureDetector(onTap: () => _handleBottomNav(index), behavior: HitTestBehavior.opaque, child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.symmetric(vertical: 8), margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(color: selected ? const Color(0xFF0753A9) : Colors.transparent, borderRadius: BorderRadius.circular(26), border: selected ? Border.all(color: const Color(0xFF168DFF), width: 1.5) : null), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(item.$1, color: selected ? Colors.white : Colors.white60, size: 25), const SizedBox(height: 3), FittedBox(child: Text(item.$2, style: TextStyle(color: selected ? Colors.white : Colors.white60, fontSize: 10, fontWeight: selected ? FontWeight.w900 : FontWeight.w600)))])))); }));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    rewardedAd?.dispose();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) FirebaseFirestore.instance.collection('players').doc(user.uid).update({'isOnline': false});
    super.dispose();
  }
}

class _HomeBackground extends StatelessWidget {
  const _HomeBackground();
  @override
  Widget build(BuildContext context) => Positioned.fill(child: DecoratedBox(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF062C66), Color(0xFF0B1B3D), Color(0xFF030B1C)], stops: [0, .48, 1])), child: Stack(children: [Positioned(top: -90, left: -70, child: _glow(220, const Color(0xFF006EFF))), Positioned(top: 190, right: -90, child: _glow(220, const Color(0xFF009DFF))), Positioned(bottom: 180, left: -120, child: _glow(260, const Color(0xFF073B8A))])));
  static Widget _glow(double size, Color color) => IgnorePointer(child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(.22), blurRadius: 100, spreadRadius: 35)])));
}
