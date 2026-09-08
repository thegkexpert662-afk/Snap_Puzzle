import 'package:flutter/material.dart';
import '../services/global_puzzle_service.dart';
import 'asset_puzzle_screen.dart';

class VictoryScreen extends StatelessWidget {
  final int seconds;
  final int moves;
  final VoidCallback onNextPuzzle;
  final VoidCallback onGoHome;
  final int coinReward;
  final int xpReward;
  final int currentLevel;
  final bool levelUp;

  const VictoryScreen({super.key, required this.seconds, required this.moves, required this.coinReward, required this.onNextPuzzle, required this.onGoHome, required this.xpReward, required this.currentLevel, required this.levelUp});

  int getStars() {
    if (seconds <= 20 && moves <= 15) return 3;
    if (seconds <= 40 && moves <= 30) return 2;
    return 1;
  }

  int _gridForLevel(int level) {
    if (level <= 10) return 4;
    if (level <= 40) return 5;
    if (level <= 60) return 6;
    if (level <= 75) return 7;
    return 8;
  }

  void _nextPuzzle() {
    GlobalPuzzleService.currentGridSize = _gridForLevel(currentLevel);
    onNextPuzzle();
  }

  void _playAgain(BuildContext context) {
    final assetPath = GlobalPuzzleService.currentPuzzlePath;
    if (assetPath == null) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AssetPuzzleScreen(assetPath: assetPath, gridSize: GlobalPuzzleService.currentGridSize)));
  }

  @override
  Widget build(BuildContext context) {
    final stars = getStars();
    final unlockText = currentLevel == 11 ? '🔓 5×5 Puzzle Unlocked' : currentLevel == 41 ? '🔓 6×6 Puzzle Unlocked' : currentLevel == 61 ? '🔓 7×7 Puzzle Unlocked' : currentLevel == 76 ? '🔓 8×8 Puzzle Unlocked' : '';
    return Scaffold(
      backgroundColor: const Color(0xFF061B43),
      body: SafeArea(
        child: Stack(children: [
          const _VictoryBackground(),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Column(children: [
              if (levelUp) ...[
                Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF16B86D), Color(0xFF07804E)]), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF49F0A8), width: 2)), child: Column(children: [const Text('🎉 LEVEL UP!', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)), const SizedBox(height: 7), Text('Level $currentLevel Reached', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)), if (unlockText.isNotEmpty) ...[const SizedBox(height: 7), Text(unlockText, style: const TextStyle(color: Color(0xFFFFF16A), fontSize: 16, fontWeight: FontWeight.w900))]])),
                const SizedBox(height: 16),
              ],
              Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const RadialGradient(colors: [Color(0xFFFFE875), Color(0xFFFFA300)]), border: Border.all(color: Colors.white, width: 3)), child: const Center(child: Text('🏆', style: TextStyle(fontSize: 68)))),
              const SizedBox(height: 18),
              const Text('LEVEL COMPLETE', style: TextStyle(color: Color(0xFF63E8FF), fontSize: 29, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Great job! Puzzle solved.', style: TextStyle(color: Color(0xFFA8D1FF), fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 18),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (index) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Icon(index < stars ? Icons.star_rounded : Icons.star_border_rounded, color: const Color(0xFFFFD447), size: 44)))),
              const SizedBox(height: 20),
              Container(width: double.infinity, padding: const EdgeInsets.fromLTRB(18, 18, 18, 8), decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0D3D7E), Color(0xFF061D49)]), borderRadius: BorderRadius.circular(28), border: Border.all(color: const Color(0xFF1979D5), width: 2)), child: Column(children: [_StatRow(Icons.timer_rounded, 'Time', '${seconds}s', const Color(0xFF4DD7FF)), _StatRow(Icons.swap_horiz_rounded, 'Moves', '$moves', const Color(0xFF58E69B)), _StatRow(Icons.monetization_on_rounded, 'Coins', '+$coinReward', const Color(0xFFFFD447)), _StatRow(Icons.stars_rounded, 'XP', '+$xpReward', const Color(0xFFD08BFF)), _StatRow(Icons.workspace_premium_rounded, 'Level', '$currentLevel', const Color(0xFFFF9D55))])),
              const SizedBox(height: 20),
              _ActionButton(label: 'Next Puzzle', icon: Icons.arrow_forward_rounded, colors: const [Color(0xFF18D890), Color(0xFF008F63)], onTap: _nextPuzzle),
              const SizedBox(height: 12),
              _ActionButton(label: 'Play Again', icon: Icons.replay_rounded, colors: const [Color(0xFFFFC62B), Color(0xFFF47B00)], onTap: () => _playAgain(context)),
              const SizedBox(height: 12),
              _ActionButton(label: 'Home', icon: Icons.home_rounded, colors: const [Color(0xFF23B9FF), Color(0xFF1457D6)], onTap: onGoHome),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, height: 56, child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.share_rounded), label: const Text('Share Score', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Color(0xFF4C82BA), width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))))),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon; final String title; final String value; final Color color;
  const _StatRow(this.icon, this.title, this.value, this.color);
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x332C6BA5)))), child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(.16), border: Border.all(color: color.withOpacity(.5))), child: Icon(icon, color: color, size: 24)), const SizedBox(width: 13), Expanded(child: Text(title, style: const TextStyle(color: Color(0xFFA8CFF5), fontSize: 15, fontWeight: FontWeight.w700))), Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900))]));
}

class _ActionButton extends StatelessWidget {
  final String label; final IconData icon; final List<Color> colors; final VoidCallback onTap;
  const _ActionButton({required this.label, required this.icon, required this.colors, required this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity, height: 58, child: ElevatedButton.icon(onPressed: onTap, icon: Icon(icon), label: Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), style: ElevatedButton.styleFrom(backgroundColor: colors.first, foregroundColor: Colors.white, elevation: 7, shadowColor: colors.first.withOpacity(.45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))));
}

class _VictoryBackground extends StatelessWidget {
  const _VictoryBackground();
  @override
  Widget build(BuildContext context) => Positioned.fill(child: DecoratedBox(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF082D6A), Color(0xFF061D49), Color(0xFF03132F)])), child: Stack(children: [Positioned(top: -80, right: -90, child: _glow(240, const Color(0xFF008BFF))), Positioned(bottom: -100, left: -100, child: _glow(250, const Color(0xFF6C2CFF)))])));
  static Widget _glow(double size, Color color) => IgnorePointer(child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(.22), blurRadius: 100, spreadRadius: 35)])));
}
