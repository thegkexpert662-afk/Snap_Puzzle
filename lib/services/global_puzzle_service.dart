import 'dart:math';

class GlobalPuzzleService {
  static const int totalImages = 86;

  static final List<int> _remainingImages = [];
  static String? currentPuzzlePath;
  static int currentGridSize = 4;

  static void _resetImages() {
    _remainingImages.clear();
    _remainingImages.addAll(List.generate(totalImages, (index) => index + 1));
    _remainingImages.shuffle();
  }

  static String getRandomPuzzle({int gridSize = 4}) {
    if (_remainingImages.isEmpty) _resetImages();
    final number = _remainingImages.removeLast();
    currentPuzzlePath = 'assets/puzzles/puzzle$number.webp';
    currentGridSize = gridSize;
    return currentPuzzlePath!;
  }

  static void setCurrentPuzzle(String assetPath, int gridSize) {
    currentPuzzlePath = assetPath;
    currentGridSize = gridSize;
  }

  static String getPuzzleByLevel(int level) {
    if (level > totalImages) level = ((level - 1) % totalImages) + 1;
    currentPuzzlePath = 'assets/puzzles/puzzle$level.webp';
    return currentPuzzlePath!;
  }
}
