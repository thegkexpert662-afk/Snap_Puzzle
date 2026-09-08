import 'dart:math';

class GlobalPuzzleService {
  static const int totalImages = 86;

  static final List<int> _remainingImages = [];

  static void _resetImages() {
    _remainingImages.clear();
    _remainingImages.addAll(
      List.generate(totalImages, (index) => index + 1),
    );
    _remainingImages.shuffle();
  }

  // Repeat नहीं होगी जब तक सभी images खत्म न हो जाएँ
  static String getRandomPuzzle() {
    if (_remainingImages.isEmpty) {
      _resetImages();
    }

    final number = _remainingImages.removeLast();
    return "assets/puzzles/puzzle$number.webp";
  }

  // Level के हिसाब से Image
  static String getPuzzleByLevel(int level) {
    if (level > totalImages) {
      level = ((level - 1) % totalImages) + 1;
    }

    return "assets/puzzles/puzzle$level.webp";
  }
}