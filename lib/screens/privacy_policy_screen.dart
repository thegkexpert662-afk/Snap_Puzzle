import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const sections = <Map<String, String>>[
    {'title': 'Information We Collect', 'body': '• Player Name\n• Player ID\n• Anonymous Firebase Authentication ID\n• Game Scores\n• Best Time\n• Puzzle Progress\n• Leaderboard Data\n\nWe do not collect passwords, bank details, or payment information.'},
    {'title': 'Permissions Used', 'body': 'Camera\nUsed to create puzzles from photos taken with your camera.\n\nPhoto Gallery\nUsed to select images from your device.\n\nInternet\nUsed for Firebase services, Leaderboards and Global Challenge.\n\nAudio\nUsed for game sound effects.\n\nVibration\nUsed for game feedback when enabled in Settings.'},
    {'title': 'How We Use Your Data', 'body': '• Save your game progress\n• Display leaderboard rankings\n• Sync game statistics\n• Improve game performance\n• Prevent cheating'},
    {'title': 'Advertisements', 'body': 'Snap Pazzel uses Google AdMob to display advertisements. Google AdMob may collect device identifiers and other information as described in Google\'s Privacy Policy to provide and improve advertising services.'},
    {'title': 'Data Security', 'body': 'Your game data is stored securely using Firebase services.'},
    {'title': 'Data Sharing', 'body': 'We do not sell your personal information.\nYour data is only used for providing game features.'},
    {'title': 'Children\'s Privacy', 'body': 'Snap Pazzel is intended for a general audience. If children use the app, they should do so under the guidance of a parent or guardian.'},
    {'title': 'Changes', 'body': 'This Privacy Policy may be updated from time to time. Changes will be reflected inside the app.'},
    {'title': 'Contact', 'body': 'Developer:\nSnap Pazzel Team\n\nEmail:- snappazzel@gmail.com'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061B43),
      body: SafeArea(
        child: Stack(children: [
          const _PolicyBackground(),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
                sliver: SliverList(delegate: SliverChildListDelegate([
                  Row(children: [
                    _CircleButton(onTap: () => Navigator.pop(context)),
                    const SizedBox(width: 14),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Privacy Policy', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)), SizedBox(height: 4), Text('How Snap Pazzel handles your information', style: TextStyle(color: Color(0xFF9CCBFF), fontSize: 12, fontWeight: FontWeight.w600))])),
                    const Icon(Icons.shield_rounded, color: Color(0xFF35E49B), size: 42),
                  ]),
                  const SizedBox(height: 20),
                  _introCard(),
                  const SizedBox(height: 14),
                  ...sections.map((s) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _SectionCard(title: s['title']!, body: s['body']!))),
                  const SizedBox(height: 8),
                  const Center(child: Text('© 2026 Snap Pazzel. All Rights Reserved.', style: TextStyle(color: Color(0xFF7197C3), fontSize: 11))),
                ])),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _introCard() => Container(padding: const EdgeInsets.all(19), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF164A86), Color(0xFF092452)]), borderRadius: BorderRadius.circular(25), border: Border.all(color: const Color(0xFF2186D8), width: 2)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Snap Pazzel Privacy Policy', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)), SizedBox(height: 8), Text('Last Updated: July 2026', style: TextStyle(color: Color(0xFF75C9FF), fontSize: 12, fontWeight: FontWeight.w700)), SizedBox(height: 12), Text('Welcome to Snap Pazzel.\n\nYour privacy is important to us. This Privacy Policy explains what information we collect and how it is used.', style: TextStyle(color: Color(0xFFC1DAF7), fontSize: 14, height: 1.55))]));
}

class _SectionCard extends StatelessWidget {
  final String title; final String body;
  const _SectionCard({required this.title, required this.body});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.fromLTRB(18, 17, 18, 18), decoration: BoxDecoration(color: const Color(0xE6082A5B), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFF1C66AB), width: 1.5), boxShadow: const [BoxShadow(color: Color(0x33006DFF), blurRadius: 12, offset: Offset(0, 5))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Color(0xFF62C8FF), fontSize: 17, fontWeight: FontWeight.w900)), const SizedBox(height: 9), Text(body, style: const TextStyle(color: Color(0xFFD1E4F9), fontSize: 13.5, height: 1.6))]));
}

class _CircleButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CircleButton({required this.onTap});
  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(onTap: onTap, customBorder: const CircleBorder(), child: Container(width: 55, height: 55, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFF0B438B), Color(0xFF061D4D)]), border: Border.all(color: const Color(0xFF1167C8), width: 2)), child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 32))));
}

class _PolicyBackground extends StatelessWidget {
  const _PolicyBackground();
  @override
  Widget build(BuildContext context) => Positioned.fill(child: DecoratedBox(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF082D6A), Color(0xFF061D49), Color(0xFF03132F)])), child: Stack(children: [Positioned(top: -90, right: -90, child: _glow(240, const Color(0xFF008BFF))), Positioned(bottom: -100, left: -100, child: _glow(250, const Color(0xFF2B43D9)))]));
  static Widget _glow(double size, Color color) => IgnorePointer(child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(.22), blurRadius: 100, spreadRadius: 35)])));
}