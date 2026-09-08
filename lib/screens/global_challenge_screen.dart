import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'asset_puzzle_screen.dart';
import 'package:snap_puzzle/services/global_puzzle_service.dart';

class GlobalChallengeScreen extends StatefulWidget {
  const GlobalChallengeScreen({super.key});

  @override
  State<GlobalChallengeScreen> createState() => _GlobalChallengeScreenState();
}

class _GlobalChallengeScreenState extends State<GlobalChallengeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061B43),
      body: SafeArea(
        child: Stack(
          children: [
            const _GlobalBackground(),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('global_puzzles')
                  .where('active', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF36B9FF),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: _EmptyChallenge());
                }

                final puzzles = snapshot.data!.docs;

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Row(
                            children: [
                              _CircleButton(
                                onTap: () => Navigator.pop(context),
                                icon: Icons.arrow_back_rounded,
                              ),
                              const SizedBox(width: 13),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Global Challenge',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Compete with players worldwide',
                                      style: TextStyle(
                                        color: Color(0xFF9CCBFF),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.public_rounded,
                                color: Color(0xFF25C7FF),
                                size: 43,
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF164A9B),
                                  Color(0xFF241B83),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: const Color(0xFF387FFF),
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x553C72FF),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 62,
                                  height: 62,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF20C7FF),
                                        Color(0xFF1261DC),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.emoji_events_rounded,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Live Challenges',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 21,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Pick a challenge and start solving.',
                                        style: TextStyle(
                                          color: Color(0xFFBBD8FF),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          ...List.generate(puzzles.length, (index) {
                            final data =
                                puzzles[index].data() as Map<String, dynamic>;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _ChallengeCard(
                                data: data,
                                onPlay: () {
                                  final randomImage =
                                      GlobalPuzzleService.getRandomPuzzle();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AssetPuzzleScreen(
                                        assetPath: randomImage,
                                        gridSize: 4,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
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
}

class _ChallengeCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onPlay;

  const _ChallengeCard({
    required this.data,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D3E83),
            Color(0xFF071F4D),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF177BD5),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44006DFF),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF25C9FF),
                  Color(0xFF1255D4),
                ],
              ),
            ),
            child: const Icon(
              Icons.public_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title']?.toString() ?? 'Global Puzzle',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Difficulty : ${data['difficulty']?.toString() ?? 'Unknown'}',
                  style: const TextStyle(
                    color: Color(0xFFA8D1FF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onPlay,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22B9FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 13,
              ),
            ),
            child: const Text(
              'Play',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChallenge extends StatelessWidget {
  const _EmptyChallenge();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(25),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF092B62),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF1979D5),
          width: 2,
        ),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.public_off_rounded,
            color: Color(0xFF62C9FF),
            size: 70,
          ),
          SizedBox(height: 16),
          Text(
            'No Global Puzzle Available',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Please check again later.',
            style: TextStyle(color: Color(0xFF9CCBFF)),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const _CircleButton({
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0B438B),
                Color(0xFF061D4D),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF1167C8),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _GlobalBackground extends StatelessWidget {
  const _GlobalBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF082D6A),
              Color(0xFF061D49),
              Color(0xFF03132F),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -90,
              child: _glow(
                240,
                const Color(0xFF008BFF),
              ),
            ),
            Positioned(
              top: 430,
              left: -120,
              child: _glow(
                250,
                const Color(0xFF2250D9),
              ),
            ),
            Positioned(
              bottom: -100,
              right: -80,
              child: _glow(
                250,
                const Color(0xFF612CFF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _glow(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.22),
              blurRadius: 100,
              spreadRadius: 35,
            ),
          ],
        ),
      ),
    );
  }
}
