import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF061B43),
      body: SafeArea(
        child: Stack(
          children: [
            const _StatsBackground(),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Row(
                        children: [
                          _CircleButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.bar_chart_rounded, color: Color(0xFF83D9FF), size: 48),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Your Stats', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
                                SizedBox(height: 3),
                                Text('Track your puzzle journey', style: TextStyle(color: Color(0xFF9BCBFF), fontSize: 14, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (user == null)
                        const _EmptyCard()
                      else
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance.collection('players').doc(user.uid).snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator(color: Color(0xFF42BFFF))));
                            }
                            if (!snapshot.hasData || !snapshot.data!.exists) return const _EmptyCard();

                            final data = snapshot.data!.data() ?? {};
                            final level = _number(data['level'], 1);
                            final xp = _number(data['xp']);
                            final nextXp = _number(data['nextLevelXp'], 100);
                            final progress = nextXp > 0 ? (xp / nextXp).clamp(0.0, 1.0).toDouble() : 0.0;

                            return Column(
                              children: [
                                _PlayerCard(name: data['name']?.toString() ?? 'Player', level: level, xp: xp, nextXp: nextXp, progress: progress),
                                const SizedBox(height: 18),
                                GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 14,
                                  crossAxisSpacing: 14,
                                  childAspectRatio: 1.55,
                                  children: [
                                    _StatCard(Icons.extension_rounded, 'Puzzles Solved', '${_number(data['totalPuzzlesSolved'])}', [const Color(0xFF16B9FF), const Color(0xFF0867D8)]),
                                    _StatCard(Icons.emoji_events_rounded, 'Total Score', '${_number(data['totalScore'])}', [const Color(0xFFFFD83D), const Color(0xFFFF9E16)]),
                                    _StatCard(Icons.timer_rounded, 'Best Time', '${_number(data['bestTime'])} sec', [const Color(0xFF5CE1E6), const Color(0xFF1478D8)]),
                                    _StatCard(Icons.star_rounded, 'Coins', '${_number(data['coins'])}', [const Color(0xFFB45CFF), const Color(0xFF6519D9)]),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                _ProgressCard(xp: xp, nextXp: nextXp, progress: progress),
                              ],
                            );
                          },
                        ),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static int _number(dynamic value, [int fallback = 0]) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class _PlayerCard extends StatelessWidget {
  final String name;
  final int level;
  final int xp;
  final int nextXp;
  final double progress;
  const _PlayerCard({required this.name, required this.level, required this.xp, required this.nextXp, required this.progress});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF168FF2), Color(0xFF123A91)]),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: const Color(0xFF63CFFF), width: 1.5),
      boxShadow: const [BoxShadow(color: Color(0x550078FF), blurRadius: 20, offset: Offset(0, 8))],
    ),
    child: Row(
      children: [
        Container(width: 70, height: 70, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF7EE8FF), Color(0xFF0074E8)])), child: const Icon(Icons.person_rounded, color: Colors.white, size: 42)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text('LEVEL $level', style: const TextStyle(color: Color(0xFFFFE15B), fontSize: 15, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(minHeight: 8, value: progress, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF55F56B)))),
          const SizedBox(height: 5),
          Text('$xp / $nextXp XP', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700)),
        ])),
      ],
    ),
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final List<Color> colors;
  const _StatCard(this.icon, this.title, this.value, this.colors);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Colors.white30),
      boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 12, offset: Offset(0, 5))],
    ),
    child: Row(children: [
      Icon(icon, color: Colors.white, size: 34),
      const SizedBox(width: 10),
      Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
      ])),
    ]),
  );
}

class _ProgressCard extends StatelessWidget {
  final int xp;
  final int nextXp;
  final double progress;
  const _ProgressCard({required this.xp, required this.nextXp, required this.progress});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(color: const Color(0xD9092450), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF1979D0), width: 1.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.trending_up_rounded, color: Color(0xFF5CE1E6), size: 25), SizedBox(width: 8), Text('XP PROGRESS', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900))]),
      const SizedBox(height: 13),
      ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(minHeight: 12, value: progress, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF42F56C)))),
      const SizedBox(height: 9),
      Row(children: [Text('$xp XP earned', style: const TextStyle(color: Color(0xFF9CCBFF), fontWeight: FontWeight.w700)), const Spacer(), Text('$nextXp XP goal', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700))]),
    ]),
  );
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(onTap: onTap, customBorder: const CircleBorder(), child: Container(width: 56, height: 56, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFF124C91), Color(0xFF061B43)]), border: Border.all(color: const Color(0xFF168DFF), width: 1.8)), child: Icon(icon, color: Colors.white, size: 34))));
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: const Color(0xD9092450), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white12)), child: const Column(children: [Icon(Icons.bar_chart_rounded, color: Color(0xFF7ED8FF), size: 58), SizedBox(height: 12), Text('No stats available yet', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)), SizedBox(height: 6), Text('Complete a puzzle to start building your stats.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70))]));
}

class _StatsBackground extends StatelessWidget {
  const _StatsBackground();
  @override
  Widget build(BuildContext context) => Positioned.fill(child: DecoratedBox(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF073271), Color(0xFF061D49), Color(0xFF03132F),], stops: [0, .5, 1])), child: Stack(children: [
    Positioned(top: -70, right: -90, child: _glow(220, const Color(0xFF0073FF))),
    Positioned(top: 380, left: -120, child: _glow(240, const Color(0xFF0054C8))),
    Positioned(bottom: -60, right: -100, child: _glow(230, const Color(0xFF3120B5))),
  ])));

  static Widget _glow(double size, Color color) => IgnorePointer(child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(.22), blurRadius: 100, spreadRadius: 35)])));
}
