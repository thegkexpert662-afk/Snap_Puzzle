import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import '../models/puzzle_piece.dart';

class AssetImageSplitter {
  static Future<List<PuzzlePiece>> splitImage(
      String assetPath,
      int gridSize,
      ) async {

    final ByteData data = await rootBundle.load(assetPath);

    final bytes = data.buffer.asUint8List();

    final original = img.decodeImage(bytes);

    if (original == null) {
      throw Exception("Image decode failed");
    }

    final List<PuzzlePiece> pieces = [];

    final pieceWidth = original.width ~/ gridSize;
    final pieceHeight = original.height ~/ gridSize;

    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {

        final cropped = img.copyCrop(
          original,
          x: col * pieceWidth,
          y: row * pieceHeight,
          width: pieceWidth,
          height: pieceHeight,
        );

        pieces.add(
          PuzzlePiece(
            image: Uint8List.fromList(
              img.encodePng(cropped),
            ),
            correctIndex: row * gridSize + col,
            currentIndex: row * gridSize + col,
          ),
        );
      }
    }

    return pieces;
  }
}