import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061B43),
      body: SafeArea(
        child: Stack(
          children: [
            const _Background(),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('players')
                  .orderBy('totalScore', descending: true)
                  .limit(100)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Unable to load leaderboard', style: TextStyle(color: Colors.white70)));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF36B9FF)));
                }
                final docs = snapshot.data!.docs;
                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 35),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _header(context),
                          const SizedBox(height: 22),
                          if (docs.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 100),
                              child: Center(child: Text('No players yet', style: TextStyle(color: Colors.white70, fontSize: 18))),
                            )
                          else
                            ...List.generate(docs.length, (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: _PlayerCard(rank: i + 1, data: docs[i].data()),
                            )),
                          const SizedBox(height: 8),
                          const _ComingSoonCard(),
                        ]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        _CircleButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
        const SizedBox(width: 12),
        const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFB928), size: 62),
        const SizedBox(width: 9),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(TextSpan(children: [
                TextSpan(text: 'Global ', style: TextStyle(color: Colors.white)),
                TextSpan(text: 'Leaderboard', style: TextStyle(color: Color(0xFFFFD42A))),
              ]), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1)),
              SizedBox(height: 8),
              Text('Top Players from Around the World', maxLines: 2, style: TextStyle(color: Color(0xFFB8D4FF), fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const Icon(Icons.public_rounded, color: Color(0xFF19C7FF), size: 58),
      ],
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> data;
  const _PlayerCard({required this.rank, required this.data});

  @override
  Widget build(BuildContext context) {
    final first = rank == 1, second = rank == 2, third = rank == 3;
    final bg = first
        ? const [Color(0xFFFF2D91), Color(0xFFB90062)]
        : second
            ? const [Color(0xFF138FF5), Color(0xFF0750B8)]
            : third
                ? const [Color(0xFFFF7414), Color(0xFFC84608)]
                : const [Color(0xFF123F85), Color(0xFF08265A)];
    final border = first
        ? const Color(0xFFFF45B0)
        : second
            ? const Color(0xFF18A9FF)
            : third
                ? const Color(0xFFFF8622)
                : const Color(0xFF126CC7);
    final badge = first ? '👑 Legend' : second ? '★ Pro' : third ? '★ Rising Star' : '★ Player';

    return Container(
      padding: const EdgeInsets.fromLTRB(11, 13, 11, 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: bg),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: border, width: 2),
        boxShadow: [BoxShadow(color: bg.first.withOpacity(.35), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          if (first) const Align(alignment: Alignment.topRight, child: _WorldNumber()) else const SizedBox(height: 4),
          const SizedBox(height: 4),
          Row(
            children: [
              _Rank(rank: rank),
              const SizedBox(width: 8),
              const _Avatar(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['name']?.toString() ?? 'Unknown Player', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    _Info(icon: Icons.badge_rounded, color: const Color(0xFFE34AFF), text: data['playerId']?.toString() ?? '--'),
                    const SizedBox(height: 6),
                    _Info(icon: Icons.timer_rounded, color: Colors.white, text: '${data['bestTime'] ?? 0} sec'),
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(.2), borderRadius: BorderRadius.circular(18), border: Border.all(color: first || third ? const Color(0xFFFFC91B) : const Color(0xFF2FE7FF), width: 1.7)),
                      child: Text(badge, style: TextStyle(color: first || third ? const Color(0xFFFFF3A0) : const Color(0xFFB8F6FF), fontSize: 11, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD13A), size: 40),
                  const SizedBox(height: 3),
                  Container(
                    constraints: const BoxConstraints(minWidth: 76),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(.22), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white12, width: 2)),
                    child: Text('${data['totalScore'] ?? 0}', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFFFE01B), fontSize: 21, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Rank extends StatelessWidget {
  final int rank;
  const _Rank({required this.rank});
  @override
  Widget build(BuildContext context) {
    final c = rank == 1 ? const Color(0xFFFFC928) : rank == 2 ? const Color(0xFFDCE7F2) : rank == 3 ? const Color(0xFFFFAA5A) : const Color(0xFF5AB8FF);
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Colors.white.withOpacity(.9), c, c.withOpacity(.7)]), border: Border.all(color: const Color(0xFFFFD23C), width: 3), boxShadow: [BoxShadow(color: c.withOpacity(.6), blurRadius: 13)]),
            child: Center(child: Text('$rank', style: TextStyle(color: rank == 2 ? const Color(0xFF18325D) : const Color(0xFF7A2800), fontSize: 30, fontWeight: FontWeight.w900))),
          ),
          const Icon(Icons.local_florist_rounded, color: Color(0xFFFFD13A), size: 18),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();
  @override
  Widget build(BuildContext context) => Container(width: 70, height: 70, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFF168FFF), Color(0xFF0053C7)]), border: Border.all(color: const Color(0xFFFFB51B), width: 3), boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 9)]), child: const Icon(Icons.person_rounded, color: Colors.white, size: 44));
}

class _Info extends StatelessWidget {
  final IconData icon; final Color color; final String text;
  const _Info({required this.icon, required this.color, required this.text});
  @override
  Widget build(BuildContext context) => Row(children: [Icon(icon, color: color, size: 19), const SizedBox(width: 6), Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)))]);
}

class _WorldNumber extends StatelessWidget {
  const _WorldNumber();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7), decoration: const BoxDecoration(color: Color(0xFFFFD94A), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))), child: const Text('👑 World #1', style: TextStyle(color: Color(0xFF703300), fontSize: 15, fontWeight: FontWeight.w900)));
}

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 19), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF262A9C), Color(0xFF092C76)]), borderRadius: BorderRadius.circular(28), border: Border.all(color: const Color(0xFF4539D4), width: 2), boxShadow: const [BoxShadow(color: Color(0x553D35FF), blurRadius: 16)]), child: Row(children: [const Text('🚀', style: TextStyle(fontSize: 43)), const SizedBox(width: 10), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Daily Challenge - Coming Soon', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)), SizedBox(height: 6), Text('New challenges and rewards are on the way!', style: TextStyle(color: Color(0xFFC3C7FF), fontSize: 11))])), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(22)), child: const Text('Stay Tuned', style: TextStyle(color: Color(0xFFC58BFF), fontWeight: FontWeight.w800, fontSize: 11)))]));
}

class _CircleButton extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(onTap: onTap, customBorder: const CircleBorder(), child: Container(width: 58, height: 58, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFF0B438B), Color(0xFF061D4D)]), border: Border.all(color: const Color(0xFF1167C8), width: 2), boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 10)]), child: Icon(icon, color: Colors.white, size: 35))));
}

class _Background extends StatelessWidget {
  const _Background();
  @override
  Widget build(BuildContext context) => Positioned.fill(child: DecoratedBox(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF082D6A), Color(0xFF061D49), Color(0xFF03132F)], stops: [0, .48, 1])), child: Stack(children: [Positioned(top: 100, left: -100, child: _glow(230, const Color(0xFF005DFF))), Positioned(top: 420, right: -120, child: _glow(260, const Color(0xFF0055B9))), Positioned(bottom: 80, left: 30, child: _glow(210, const Color(0xFF1623A7)))]));
  static Widget _glow(double size, Color color) => IgnorePointer(child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(.25), blurRadius: 100, spreadRadius: 30)])));
}
