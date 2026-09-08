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
            const _LeaderboardBackground(),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('players')
                  .orderBy('totalScore', descending: true)
                  .limit(100)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Unable to load leaderboard',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF36B9FF),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 32),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _header(context),
                          const SizedBox(height: 20),
                          if (docs.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 100),
                              child: Center(
                                child: Text(
                                  'No players yet',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...List.generate(
                              docs.length,
                              (i) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _PlayerCard(
                                  rank: i + 1,
                                  data: docs[i].data(),
                                ),
                              ),
                            ),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CircleButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(width: 9),
        const Icon(
          Icons.emoji_events_rounded,
          color: Color(0xFFFFB928),
          size: 53,
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Global ',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'Leaderboard',
                        style: TextStyle(color: Color(0xFFFFD42A)),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Top Players from Around the World',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFFB8D4FF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 7),
        const Icon(
          Icons.public_rounded,
          color: Color(0xFF19C7FF),
          size: 51,
        ),
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
    final first = rank == 1;
    final second = rank == 2;
    final third = rank == 3;

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

    final badge = first
        ? '👑 Legend'
        : second
            ? '★ Pro'
            : third
                ? '★ Rising Star'
                : '★ Player';

    return Container(
      padding: EdgeInsets.fromLTRB(10, first ? 10 : 12, 10, 13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: bg,
        ),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: border, width: 2),
        boxShadow: [
          BoxShadow(
            color: bg.first.withOpacity(.34),
            blurRadius: 17,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (first)
            const Align(
              alignment: Alignment.topRight,
              child: _WorldNumber(),
            )
          else
            const SizedBox(height: 2),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 360;
              final side = compact ? 55.0 : 58.0;
              final avatar = compact ? 55.0 : 60.0;
              final scoreWidth = compact ? 73.0 : 82.0;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _Rank(rank: rank, size: side),
                  SizedBox(width: compact ? 5 : 7),
                  _Avatar(size: avatar),
                  SizedBox(width: compact ? 7 : 9),
                  Expanded(
                    child: _PlayerDetails(
                      data: data,
                      badge: badge,
                      badgeColor: first || third
                          ? const Color(0xFFFFC91B)
                          : const Color(0xFF2FE7FF),
                      badgeTextColor: first || third
                          ? const Color(0xFFFFF3A0)
                          : const Color(0xFFB8F6FF),
                    ),
                  ),
                  SizedBox(width: compact ? 5 : 7),
                  SizedBox(
                    width: scoreWidth,
                    child: _ScoreBox(
                      score: data['totalScore'] ?? 0,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PlayerDetails extends StatelessWidget {
  final Map<String, dynamic> data;
  final String badge;
  final Color badgeColor;
  final Color badgeTextColor;

  const _PlayerDetails({
    required this.data,
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data['name']?.toString().trim().isNotEmpty == true
              ? data['name'].toString()
              : 'Unknown Player',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 6),
        _Info(
          icon: Icons.badge_rounded,
          color: const Color(0xFFE34AFF),
          text: data['playerId']?.toString() ?? '--',
        ),
        const SizedBox(height: 4),
        _Info(
          icon: Icons.timer_rounded,
          color: Colors.white,
          text: '${data['bestTime'] ?? 0} sec',
        ),
        const SizedBox(height: 6),
        Container(
          constraints: const BoxConstraints(maxWidth: 125),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.18),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: badgeColor, width: 1.6),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              badge,
              maxLines: 1,
              style: TextStyle(
                color: badgeTextColor,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final dynamic score;

  const _ScoreBox({required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.emoji_events_rounded,
          color: Color(0xFFFFD13A),
          size: 36,
        ),
        const SizedBox(height: 3),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.21),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: Colors.white12, width: 2),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$score',
              maxLines: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFFE01B),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Rank extends StatelessWidget {
  final int rank;
  final double size;

  const _Rank({required this.rank, required this.size});

  @override
  Widget build(BuildContext context) {
    final c = rank == 1
        ? const Color(0xFFFFC928)
        : rank == 2
            ? const Color(0xFFDCE7F2)
            : rank == 3
                ? const Color(0xFFFFAA5A)
                : const Color(0xFF5AB8FF);

    return SizedBox(
      width: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(.92),
                  c,
                  c.withOpacity(.7),
                ],
              ),
              border: Border.all(
                color: const Color(0xFFFFD23C),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: c.withOpacity(.55),
                  blurRadius: 11,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: rank == 2
                      ? const Color(0xFF18325D)
                      : const Color(0xFF7A2800),
                  fontSize: size * .43,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const Icon(
            Icons.local_florist_rounded,
            color: Color(0xFFFFD13A),
            size: 16,
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final double size;

  const _Avatar({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF168FFF), Color(0xFF0053C7)],
        ),
        border: Border.all(
          color: const Color(0xFFFFB51B),
          width: 3,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 8,
          ),
        ],
      ),
      child: Icon(
        Icons.person_rounded,
        color: Colors.white,
        size: size * .62,
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _Info({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 17),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _WorldNumber extends StatelessWidget {
  const _WorldNumber();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      decoration: const BoxDecoration(
        color: Color(0xFFFFD94A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(19),
          bottomLeft: Radius.circular(19),
        ),
      ),
      child: const Text(
        '👑 World #1',
        maxLines: 1,
        style: TextStyle(
          color: Color(0xFF703300),
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF0B438B), Color(0xFF061D4D)],
            ),
            border: Border.all(
              color: const Color(0xFF1167C8),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 10,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 35),
        ),
      ),
    );
  }
}

class _LeaderboardBackground extends StatelessWidget {
  const _LeaderboardBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A2E70), Color(0xFF041431)],
              ),
            ),
            child: SizedBox.expand(),
          ),
          Positioned(
            top: -90,
            left: -90,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF168FFF).withOpacity(.12),
              ),
            ),
          ),
          Positioned(
            top: 150,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF19C7FF).withOpacity(.07),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
