import 'dart:io';
import 'package:flutter/material.dart';
import 'puzzle_screen.dart';

class DifficultyScreen extends StatelessWidget {
  final File imageFile;
  const DifficultyScreen({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061B43),
      body: SafeArea(
        child: Stack(
          children: [
            const _DifficultyBackground(),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Row(children: [
                        _CircleButton(onTap: () => Navigator.pop(context), icon: Icons.arrow_back_rounded),
                        const SizedBox(width: 14),
                        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Choose Difficulty', style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900)),
                          SizedBox(height: 5),
                          Text('Select your challenge', style: TextStyle(color: Color(0xFF9CCBFF), fontSize: 14, fontWeight: FontWeight.w600)),
                        ])),
                        const Icon(Icons.tune_rounded, color: Color(0xFF42C5FF), size: 38),
                      ]),
                      const SizedBox(height: 22),
                      Container(
                        height: 190,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFF2385DF), width: 2),
                          boxShadow: const [BoxShadow(color: Color(0x55006DFF), blurRadius: 20, offset: Offset(0, 8))],
                          color: const Color(0xFF092D65),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(children: [
                          Positioned.fill(child: Image.file(imageFile, fit: BoxFit.cover)),
                          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, const Color(0xDD061B43)])))),
                          const Positioned(left: 18, bottom: 15, child: Text('Your Puzzle', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900))),
                        ]),
                      ),
                      const SizedBox(height: 22),
                      _difficultyCard(context, Icons.sentiment_satisfied_alt_rounded, 'Easy', '3 × 3', 'Relaxed start', const [Color(0xFF18D890), Color(0xFF008C64)], 3),
                      const SizedBox(height: 14),
                      _difficultyCard(context, Icons.flash_on_rounded, 'Medium', '4 × 4', 'A little more focus', const [Color(0xFFFFC62B), Color(0xFFF47B00)], 4),
                      const SizedBox(height: 14),
                      _difficultyCard(context, Icons.local_fire_department_rounded, 'Hard', '5 × 5', 'Test your skills', const [Color(0xFFFF7A24), Color(0xFFDA2700)], 5),
                      const SizedBox(height: 14),
                      _difficultyCard(context, Icons.workspace_premium_rounded, 'Expert', '6 × 6', 'Ultimate challenge', const [Color(0xFFFF4E66), Color(0xFFB20D50)], 6),
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

  Widget _difficultyCard(BuildContext context, IconData icon, String title, String subtitle, String hint, List<Color> colors, int gridSize) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PuzzleScreen(imageFile: imageFile, gridSize: gridSize))),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white24, width: 1.5),
            boxShadow: [BoxShadow(color: colors.last.withOpacity(.32), blurRadius: 17, offset: const Offset(0, 7))],
          ),
          child: Row(children: [
            Container(width: 58, height: 58, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(.18), border: Border.all(color: Colors.white38)), child: Icon(icon, color: Colors.white, size: 31)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(hint, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
            ])),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 23),
          ]),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final VoidCallback onTap; final IconData icon;
  const _CircleButton({required this.onTap, required this.icon});
  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(onTap: onTap, customBorder: const CircleBorder(), child: Container(width: 55, height: 55, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFF0B438B), Color(0xFF061D4D)]), border: Border.all(color: const Color(0xFF1167C8), width: 2)), child: Icon(icon, color: Colors.white, size: 32))));
}

class _DifficultyBackground extends StatelessWidget {
  const _DifficultyBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF082D6A), Color(0xFF061D49), Color(0xFF03132F)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: -80, right: -90, child: _glow(230, const Color(0xFF008BFF))),
            Positioned(top: 410, left: -120, child: _glow(250, const Color(0xFF1455D9))),
            Positioned(bottom: -90, right: -80, child: _glow(240, const Color(0xFF6D2AFF))),
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
          boxShadow: [BoxShadow(color: color.withOpacity(.23), blurRadius: 100, spreadRadius: 35)],
        ),
      ),
    );
  }
}
