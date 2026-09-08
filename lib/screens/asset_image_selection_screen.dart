import 'package:flutter/material.dart';
import 'asset_puzzle_screen.dart';

class AssetImageSelectionScreen extends StatefulWidget {
  const AssetImageSelectionScreen({super.key});

  @override
  State<AssetImageSelectionScreen> createState() => _AssetImageSelectionScreenState();
}

class _AssetImageSelectionScreenState extends State<AssetImageSelectionScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  static const int totalImages = 86;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  String get _currentAsset => 'assets/puzzles/puzzle${_currentIndex + 1}.webp';

  void _next() {
    if (_currentIndex < totalImages - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
    }
  }

  void _previous() {
    if (_currentIndex > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
    }
  }

  void _startPuzzle() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssetDifficultyScreen(assetPath: _currentAsset, imageNumber: _currentIndex + 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061B43),
      body: SafeArea(
        child: Stack(
          children: [
            const _AssetPickerBackground(),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                  child: Row(
                    children: [
                      _CircleButton(onTap: () => Navigator.pop(context), icon: Icons.arrow_back_rounded),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Choose a Photo', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
                            SizedBox(height: 3),
                            Text('Select one puzzle image', style: TextStyle(color: Color(0xFF9CCBFF), fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFF0B326C), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2385DF))),
                        child: Text('${_currentIndex + 1} / $totalImages', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: totalImages,
                    onPageChanged: (index) => setState(() => _currentIndex = index),
                    itemBuilder: (context, index) {
                      final asset = 'assets/puzzles/puzzle${index + 1}.webp';
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxHeight: 430),
                            decoration: BoxDecoration(
                              color: const Color(0xFF092D65),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: const Color(0xFF2385DF), width: 2),
                              boxShadow: const [BoxShadow(color: Color(0x55006DFF), blurRadius: 24, offset: Offset(0, 10))],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(asset, fit: BoxFit.contain),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _NavButton(icon: Icons.chevron_left_rounded, onTap: _previous, enabled: _currentIndex > 0),
                          const SizedBox(width: 18),
                          Text('Photo ${_currentIndex + 1}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                          const SizedBox(width: 18),
                          _NavButton(icon: Icons.chevron_right_rounded, onTap: _next, enabled: _currentIndex < totalImages - 1),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _startPuzzle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF168DFF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                          ),
                          icon: const Icon(Icons.extension_rounded),
                          label: const Text('USE THIS PHOTO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class AssetDifficultyScreen extends StatelessWidget {
  final String assetPath;
  final int imageNumber;

  const AssetDifficultyScreen({super.key, required this.assetPath, required this.imageNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061B43),
      body: SafeArea(
        child: CustomScrollView(
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
                      Text('Choose Difficulty', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
                      SizedBox(height: 3),
                      Text('Pick a challenge for your photo', style: TextStyle(color: Color(0xFF9CCBFF), fontSize: 13, fontWeight: FontWeight.w600)),
                    ])),
                  ]),
                  const SizedBox(height: 18),
                  Container(height: 190, decoration: BoxDecoration(color: const Color(0xFF092D65), borderRadius: BorderRadius.circular(28), border: Border.all(color: const Color(0xFF2385DF), width: 2)), clipBehavior: Clip.antiAlias, child: Image.asset(assetPath, fit: BoxFit.cover)),
                  const SizedBox(height: 18),
                  _DifficultyButton(context, 'Easy', '3 × 3', const [Color(0xFF18D890), Color(0xFF008C64)], 3),
                  const SizedBox(height: 12),
                  _DifficultyButton(context, 'Medium', '4 × 4', const [Color(0xFFFFC62B), Color(0xFFF47B00)], 4),
                  const SizedBox(height: 12),
                  _DifficultyButton(context, 'Hard', '5 × 5', const [Color(0xFFFF7A24), Color(0xFFDA2700)], 5),
                  const SizedBox(height: 12),
                  _DifficultyButton(context, 'Expert', '6 × 6', const [Color(0xFFFF4E66), Color(0xFFB20D50)], 6),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _DifficultyButton(BuildContext context, String title, String size, List<Color> colors, int gridSize) {
    return Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(22), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AssetPuzzleScreen(assetPath: assetPath, gridSize: gridSize))), child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white30)), child: Row(children: [const Icon(Icons.extension_rounded, color: Colors.white, size: 38), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)), Text(size, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))])), const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 21)]))));
  }
}

class _CircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  const _CircleButton({required this.onTap, required this.icon});
  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(onTap: onTap, customBorder: const CircleBorder(), child: Container(width: 52, height: 52, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFF0B438B), Color(0xFF061D4D)]), border: Border.all(color: const Color(0xFF1167C8), width: 2)), child: Icon(icon, color: Colors.white, size: 30))));
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  const _NavButton({required this.icon, required this.onTap, required this.enabled});
  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(onTap: enabled ? onTap : null, customBorder: const CircleBorder(), child: Container(width: 46, height: 46, decoration: BoxDecoration(shape: BoxShape.circle, color: enabled ? const Color(0xFF0B438B) : Colors.white10, border: Border.all(color: enabled ? const Color(0xFF2385DF) : Colors.white12)), child: Icon(icon, color: enabled ? Colors.white : Colors.white30, size: 30))));
}

class _AssetPickerBackground extends StatelessWidget {
  const _AssetPickerBackground();
  @override
  Widget build(BuildContext context) => Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF082D6A), Color(0xFF061D49), Color(0xFF03132F)])));
}
