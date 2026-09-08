import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import '../models/puzzle_piece.dart';

class ImageSplitter {
  static Future<List<PuzzlePiece>> splitImage(
      File imageFile,
      int gridSize,
      ) async {

    final bytes = await imageFile.readAsBytes();

    final original = img.decodeImage(bytes);

    if (original == null) {
      throw Exception("Image decode failed");
    }

    final List<PuzzlePiece> pieces = [];

    final int rows = gridSize;
    final int cols = gridSize;

    final pieceWidth = original.width ~/ cols;
    final pieceHeight = original.height ~/ rows;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final startX = col * pieceWidth;
        final startY = row * pieceHeight;

        final cropWidth =
        (col == cols - 1) ? original.width - startX : pieceWidth;

        final cropHeight =
        (row == rows - 1) ? original.height - startY : pieceHeight;

        final cropped = img.copyCrop(
          original,
          x: startX,
          y: startY,
          width: cropWidth,
          height: cropHeight,
        );

        pieces.add(
          PuzzlePiece(
            image: Uint8List.fromList(
              img.encodePng(cropped),
            ),
            correctIndex: row * cols + col,
            currentIndex: row * cols + col,
          ),
        );
      }
    }

    return pieces;
  }
}