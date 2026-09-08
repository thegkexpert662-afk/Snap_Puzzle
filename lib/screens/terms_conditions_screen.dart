import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const sections = <Map<String, String>>[
    {'title': 'Acceptance', 'body': 'By downloading or using Snap Pazzel, you agree to follow these Terms & Conditions.'},
    {'title': 'Fair Play', 'body': '• Cheating is not allowed.\n• Modified APKs are prohibited.\n• Fake scores may result in leaderboard removal or account restrictions.'},
    {'title': 'Player Data', 'body': 'Your game progress, score and leaderboard information are stored securely using Firebase.'},
    {'title': 'Intellectual Property', 'body': 'All logos, graphics, game design and original content of Snap Pazzel belong to the developer unless otherwise stated.'},
    {'title': 'User Content', 'body': 'Images selected from your Camera or Gallery are used only to generate puzzles on your device. We do not claim ownership of your personal photos, and we do not sell, share, or use them for any purpose other than creating puzzles within the app.'},
    {'title': 'Advertisements', 'body': 'The app may display advertisements provided by Google AdMob.'},
    {'title': 'Updates', 'body': 'Features and gameplay may change through future updates.'},
    {'title': 'Limitation of Liability', 'body': 'We are not responsible for data loss caused by device failure, operating system issues or third-party services.'},
    {'title': 'Termination', 'body': 'We reserve the right to suspend or restrict access to the leaderboard or game services if these Terms are violated, including cheating or the use of modified versions of the app.'},
    {'title': 'Contact', 'body': 'Developer:\nSnap Pazzel Team\nsnappazzel@gmail.com'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061B43),
      body: SafeArea(
        child: Stack(children: [
          const _TermsBackground(),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
                sliver: SliverList(delegate: SliverChildListDelegate([
                  Row(children: [
                    _CircleButton(onTap: () => Navigator.pop(context)),
                    const SizedBox(width: 14),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Terms & Conditions', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)), SizedBox(height: 4), Text('Rules for using Snap Pazzel', style: TextStyle(color: Color(0xFF9CCBFF), fontSize: 12, fontWeight: FontWeight.w600))])),
                    const Icon(Icons.description_rounded, color: Color(0xFFFFD447), size: 42),
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

  Widget _introCard() => Container(padding: const EdgeInsets.all(19), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF164A86), Color(0xFF092452)]), borderRadius: BorderRadius.circular(25), border: Border.all(color: const Color(0xFF2186D8), width: 2)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Snap Pazzel Terms & Conditions', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)), SizedBox(height: 8), Text('Last Updated: July 2026', style: TextStyle(color: Color(0xFFFFD447), fontSize: 12, fontWeight: FontWeight.w700)), SizedBox(height: 12), Text('Welcome to Snap Pazzel.\n\nBy using this application, you agree to the following terms.', style: TextStyle(color: Color(0xFFC1DAF7), fontSize: 14, height: 1.55))]));
}

class _SectionCard extends StatelessWidget {
  final String title; final String body;
  const _SectionCard({required this.title, required this.body});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.fromLTRB(18, 17, 18, 18), decoration: BoxDecoration(color: const Color(0xE6082A5B), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFF1C66AB), width: 1.5), boxShadow: const [BoxShadow(color: Color(0x33006DFF), blurRadius: 12, offset: Offset(0, 5))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Color(0xFFFFD447), fontSize: 17, fontWeight: FontWeight.w900)), const SizedBox(height: 9), Text(body, style: const TextStyle(color: Color(0xFFD1E4F9), fontSize: 13.5, height: 1.6))]));
}

class _CircleButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CircleButton({required this.onTap});
  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(onTap: onTap, customBorder: const CircleBorder(), child: Container(width: 55, height: 55, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFF0B438B), Color(0xFF061D4D)]), border: Border.all(color: const Color(0xFF1167C8), width: 2)), child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 32))));
}

class _TermsBackground extends StatelessWidget {
  const _TermsBackground();
  @override
  Widget build(BuildContext context) => Positioned.fill(child: DecoratedBox(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF082D6A), Color(0xFF061D49), Color(0xFF03132F)])), child: Stack(children: [Positioned(top: -90, right: -90, child: _glow(240, const Color(0xFF008BFF))), Positioned(bottom: -100, left: -100, child: _glow(250, const Color(0xFF5531DD)))]));
  static Widget _glow(double size, Color color) => IgnorePointer(child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(.22), blurRadius: 100, spreadRadius: 35)])));
}