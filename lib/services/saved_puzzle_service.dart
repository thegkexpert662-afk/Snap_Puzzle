import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedPuzzleService {
  static const _key = 'unfinished_puzzle';

  static Future<Map<String, dynamic>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> hasSaved() async => await load() != null;

  static Future<void> save({
    required String type,
    required String source,
    required int gridSize,
    required int seconds,
    required int moves,
    required List<int> order,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode({
      'type': type,
      'source': source,
      'gridSize': gridSize,
      'seconds': seconds,
      'moves': moves,
      'order': order,
      'savedAt': DateTime.now().millisecondsSinceEpoch,
    }));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<String> persistCustomImage(File source) async {
    final directory = await getApplicationDocumentsDirectory();
    final extension = source.path.contains('.') ? source.path.split('.').last : 'jpg';
    final target = File('${directory.path}/unfinished_puzzle.$extension');
    if (source.path != target.path) {
      await source.copy(target.path);
    }
    return target.path;
  }
}
