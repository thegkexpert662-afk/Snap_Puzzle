import 'dart:io';

import 'package:flutter/material.dart';

import '../services/saved_puzzle_service.dart';
import 'asset_puzzle_screen.dart';
import 'puzzle_screen.dart';

class MyPuzzlesScreen extends StatefulWidget {
  const MyPuzzlesScreen({super.key});

  @override
  State<MyPuzzlesScreen> createState() => _MyPuzzlesScreenState();
}

class _MyPuzzlesScreenState extends State<MyPuzzlesScreen> {
  Map<String, dynamic>? saved;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await SavedPuzzleService.load();
    if (!mounted) return;
    setState(() {
      saved = data;
      loading = false;
    });
  }

  Future<void> _resume() async {
    final data = await SavedPuzzleService.load();
    if (!mounted || data == null) return;

    final type = data['type']?.toString();
    final source = data['source']?.toString() ?? '';
    final grid = (data['gridSize'] as num?)?.toInt() ?? 4;

    if (type == 'asset') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AssetPuzzleScreen(
            assetPath: source,
            gridSize: grid,
            resume: true,
          ),
        ),
      ).then((_) => _load());
      return;
    }

    final file = File(source);
    if (!await file.exists()) {
      await SavedPuzzleService.clear();
      await _load();
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PuzzleScreen(
          imageFile: file,
          gridSize: grid,
          resume: true,
        ),
      ),
    ).then((_) => _load());
  }

  Future<void> _discard() async {
    await SavedPuzzleService.clear();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061B43),
      body: SafeArea(
        child: Stack(
          children: [
            const _MyPuzzlesBackground(),
            loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF36B9FF)))
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            Row(
                              children: [
                                _CircleButton(onTap: () => Navigator.pop(context), icon: Icons.arrow_back_rounded),
                                const SizedBox(width: 13),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('My Puzzles', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                                      SizedBox(height: 4),
                                      Text('Continue puzzles you left unfinished', style: TextStyle(color: Color(0xFF9CCBFF), fontSize: 13, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.bookmark_rounded, color: Color(0xFF35C7FF), size: 40),
                              ],
                            ),
                            const SizedBox(height: 24),
                            if (saved == null) const _EmptySavedPuzzles() else _SavedPuzzleCard(data: saved!, onResume: _resume, onDiscard: _discard),
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
}

class _SavedPuzzleCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onResume;
  final VoidCallback onDiscard;

  const _SavedPuzzleCard({required this.data, required this.onResume, required this.onDiscard});

  @override
  Widget build(BuildContext context) {
    final type = data['type']?.toString() ?? 'custom';
    final source = data['source']?.toString() ?? '';
    final grid = (data['gridSize'] as num?)?.toInt() ?? 4;
    final seconds = (data['seconds'] as num?)?.toInt() ?? 0;
    final moves = (data['moves'] as num?)?.toInt() ?? 0;

    Widget preview;
    if (type == 'asset') {
      preview = Image.asset(source, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.extension_rounded, color: Colors.white, size: 55));
    } else {
      preview = Image.file(File(source), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.photo_rounded, color: Colors.white, size: 55));
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0E438C), Color(0xFF071F4D)]),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF238FE5), width: 2),
        boxShadow: const [BoxShadow(color: Color(0x44006DFF), blurRadius: 18, offset: Offset(0, 7))],
      ),
      child: Column(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(18), child: SizedBox(height: 210, width: double.infinity, child: preview)),
          const SizedBox(height: 15),
          Row(children: [
            Expanded(child: Text('${grid} × $grid Puzzle', style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900))),
            IconButton(onPressed: onDiscard, tooltip: 'Remove saved puzzle', icon: const Icon(Icons.delete_outline_rounded, color: Colors.white70)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            _InfoPill(icon: Icons.timer_rounded, text: '${seconds}s'),
            const SizedBox(width: 8),
            _InfoPill(icon: Icons.swap_horiz_rounded, text: '$moves moves'),
            const Spacer(),
            const Text('UNFINISHED', style: TextStyle(color: Color(0xFF58E0FF), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ]),
          const SizedBox(height: 15),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: onResume, icon: const Icon(Icons.play_arrow_rounded), label: const Text('Continue Puzzle', style: TextStyle(fontWeight: FontWeight.w900)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1BB9FF), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoPill({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: const Color(0xFF092B62), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white12)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: const Color(0xFF58D9FF), size: 16), const SizedBox(width: 5), Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700))]));
}

class _EmptySavedPuzzles extends StatelessWidget {
  const _EmptySavedPuzzles();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: const Color(0xFF092B62), borderRadius: BorderRadius.circular(26), border: Border.all(color: const Color(0xFF1979D5), width: 2)), child: const Column(children: [Icon(Icons.check_circle_outline_rounded, color: Color(0xFF55D7FF), size: 70), SizedBox(height: 16), Text('No Unfinished Puzzles', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)), SizedBox(height: 7), Text('Start a puzzle and leave it unfinished to see it here.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF9CCBFF), fontSize: 13))]));
}

class _CircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  const _CircleButton({required this.onTap, required this.icon});
  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(onTap: onTap, customBorder: const CircleBorder(), child: Container(width: 55, height: 55, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFF0B438B), Color(0xFF061D4D)]), border: Border.all(color: const Color(0xFF1167C8), width: 2)), child: Icon(icon, color: Colors.white, size: 32))));
}

class _MyPuzzlesBackground extends StatelessWidget {
  const _MyPuzzlesBackground();
  @override
  Widget build(BuildContext context) => Positioned.fill(child: DecoratedBox(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF082D6A), Color(0xFF061D49), Color(0xFF03132F)]))));
}
