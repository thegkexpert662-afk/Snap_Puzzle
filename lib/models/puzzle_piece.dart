import 'dart:typed_data';

class PuzzlePiece {
  Uint8List image;

  int correctIndex;
  int currentIndex;

  bool isGlow;

  PuzzlePiece({
    required this.image,
    required this.correctIndex,
    required this.currentIndex,
    this.isGlow = false,
  });
}