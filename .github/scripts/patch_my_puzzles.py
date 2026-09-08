from pathlib import Path
import re

# Home navigation
p = Path('lib/screens/home_screen.dart')
s = p.read_text()
if "import 'my_puzzles_screen.dart';" not in s:
    s = s.replace("import 'login_screen.dart';", "import 'login_screen.dart';\nimport 'my_puzzles_screen.dart';")
s = s.replace("case 1: _showMessage('Your puzzles will appear here.'); break;", "case 1: Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPuzzlesScreen())); break;")
p.write_text(s)

# Custom puzzle
p = Path('lib/screens/puzzle_screen.dart')
s = p.read_text()
if "../services/saved_puzzle_service.dart" not in s:
    s = s.replace("import '../services/sound_service.dart';", "import '../services/sound_service.dart';\nimport '../services/saved_puzzle_service.dart';")
s = s.replace("const PuzzleScreen({super.key, required this.imageFile, required this.gridSize});", "const PuzzleScreen({super.key, required this.imageFile, required this.gridSize, this.resume = false});")
s = s.replace("  final int gridSize;\n  const PuzzleScreen", "  final int gridSize;\n  final bool resume;\n  const PuzzleScreen")
if "String? _saveSourcePath;" not in s:
    s = s.replace("  late ConfettiController confettiController;", "  late ConfettiController confettiController;\n  String? _saveSourcePath;")

custom_load = '''  Future<void> loadPuzzle() async {
    final saved = widget.resume ? await SavedPuzzleService.load() : null;
    final canResume = saved != null && saved['type'] == 'custom' && saved['gridSize'] == widget.gridSize && saved['source'] == widget.imageFile.path && saved['order'] is List;
    _saveSourcePath = widget.resume ? widget.imageFile.path : await SavedPuzzleService.persistCustomImage(widget.imageFile);
    pieces = await ImageSplitter.splitImage(widget.imageFile, widget.gridSize);
    if (canResume) {
      final order = (saved!['order'] as List).map((e) => (e as num).toInt()).toList();
      final byCorrect = <int, PuzzlePiece>{for (final piece in pieces) piece.correctIndex: piece};
      if (order.length == pieces.length && order.every(byCorrect.containsKey)) {
        pieces = order.map((correct) => byCorrect[correct]!).toList();
        for (int i = 0; i < pieces.length; i++) pieces[i].currentIndex = i;
        seconds = (saved['seconds'] as num?)?.toInt() ?? 0;
        moves = (saved['moves'] as num?)?.toInt() ?? 0;
      } else {
        shufflePieces();
        seconds = 0;
        moves = 0;
      }
    } else {
      shufflePieces();
      seconds = 0;
      moves = 0;
    }
    startTimer(initialSeconds: seconds);
    final bytes = await widget.imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded != null) {
      imageWidth = decoded.width.toDouble();
      imageHeight = decoded.height.toDouble();
    }
    if (mounted) setState(() => loading = false);
    if (!canResume) await _saveProgress();
  }
'''
s = re.sub(r"  Future<void> loadPuzzle\(\) async \{.*?\n  \}\n\n  @override\n  Widget build", custom_load + "\n  @override\n  Widget build", s, count=1, flags=re.S)
s = re.sub(r"  void startTimer\(\) \{.*?\n  \}\n\n  Future<void> loadPuzzle", '''  void startTimer({int initialSeconds = 0}) {
    timer?.cancel();
    seconds = initialSeconds;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_winHandled) {
        setState(() => seconds++);
        _saveProgress();
      }
    });
  }

  Future<void> loadPuzzle''', s, count=1, flags=re.S)
custom_swap = '''  void swapPieces(int oldIndex, int newIndex) {
    if (_winHandled || oldIndex == newIndex) return;
    SoundService.play('move.mp3');
    setState(() {
      final temp = pieces[oldIndex];
      pieces[oldIndex] = pieces[newIndex];
      pieces[newIndex] = temp;
      pieces[oldIndex].currentIndex = oldIndex;
      pieces[newIndex].currentIndex = newIndex;
      moves++;
    });
    checkWin();
    if (!_winHandled) _saveProgress();
  }
'''
s = re.sub(r"  void swapPieces\(int oldIndex, int newIndex\) \{.*?\n  \}\n\n  int calculateXp", custom_swap + "\n  int calculateXp", s, count=1, flags=re.S)
if "Future<void> _saveProgress() async" not in s:
    methods = '''  Future<void> _saveProgress() async {
    if (_winHandled || _saveSourcePath == null || pieces.isEmpty) return;
    await SavedPuzzleService.save(type: 'custom', source: _saveSourcePath!, gridSize: widget.gridSize, seconds: seconds, moves: moves, order: pieces.map((p) => p.correctIndex).toList());
  }

  Future<void> _exitPuzzle() async {
    await _saveProgress();
    if (mounted) Navigator.pop(context);
  }

'''
    s = s.replace("  int calculateXp(int gridSize, int moves) {", methods + "  int calculateXp(int gridSize, int moves) {")
s = s.replace("_CircleButton(onTap: () => Navigator.pop(context), icon: Icons.arrow_back_rounded)", "_CircleButton(onTap: _exitPuzzle, icon: Icons.arrow_back_rounded)", 1)
s = s.replace("    if (!mounted) return;\n    Navigator.push(\n      context,", "    if (!mounted) return;\n    await SavedPuzzleService.clear();\n    Navigator.push(\n      context,", 1)
p.write_text(s)

# Asset puzzle
p = Path('lib/screens/asset_puzzle_screen.dart')
s = p.read_text()
if "../services/saved_puzzle_service.dart" not in s:
    s = s.replace("import '../services/sound_service.dart';", "import '../services/sound_service.dart';\nimport '../services/saved_puzzle_service.dart';")
s = s.replace("    required this.gridSize,\n  });", "    required this.gridSize,\n    this.resume = false,\n  });", 1)
s = s.replace("  final int gridSize;\n\n  const AssetPuzzleScreen", "  final int gridSize;\n  final bool resume;\n\n  const AssetPuzzleScreen")
if "bool _winHandled = false;" not in s:
    s = s.replace("  bool loading = true;", "  bool loading = true;\n  bool _winHandled = false;", 1)
asset_load = '''  Future<void> loadPuzzle() async {
    freeImageHintUsed = false;
    paidImageHintUsed = false;
    final saved = widget.resume ? await SavedPuzzleService.load() : null;
    final canResume = saved != null && saved['type'] == 'asset' && saved['source'] == widget.assetPath && saved['gridSize'] == widget.gridSize && saved['order'] is List;
    pieces = await AssetImageSplitter.splitImage(widget.assetPath, widget.gridSize);
    if (canResume) {
      final order = (saved!['order'] as List).map((e) => (e as num).toInt()).toList();
      final byCorrect = <int, PuzzlePiece>{for (final piece in pieces) piece.correctIndex: piece};
      if (order.length == pieces.length && order.every(byCorrect.containsKey)) {
        pieces = order.map((correct) => byCorrect[correct]!).toList();
        for (int i = 0; i < pieces.length; i++) pieces[i].currentIndex = i;
        seconds = (saved['seconds'] as num?)?.toInt() ?? 0;
        moves = (saved['moves'] as num?)?.toInt() ?? 0;
      } else {
        shufflePieces();
        seconds = 0;
        moves = 0;
      }
    } else {
      shufflePieces();
      seconds = 0;
      moves = 0;
    }
    startTimer(initialSeconds: seconds);
    final bytes = (await rootBundle.load(widget.assetPath)).buffer.asUint8List();
    final decoded = img.decodeImage(bytes);
    if (decoded != null) {
      imageWidth = decoded.width.toDouble();
      imageHeight = decoded.height.toDouble();
    }
    if (mounted) setState(() => loading = false);
    if (!canResume) await _saveProgress();
  }
'''
s = re.sub(r"  Future<void> loadPuzzle\(\) async \{.*?\n  \}\n  void shufflePieces", asset_load + "\n  void shufflePieces", s, count=1, flags=re.S)
s = re.sub(r"  void startTimer\(\) \{.*?\n  \}", '''  void startTimer({int initialSeconds = 0}) {
    timer?.cancel();
    seconds = initialSeconds;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_winHandled) {
        setState(() => seconds++);
        _saveProgress();
      }
    });
  }''', s, count=1, flags=re.S)
asset_swap = '''  void swapPieces(int oldIndex, int newIndex) {
    if (_winHandled || oldIndex == newIndex) return;
    SoundService.play("move.mp3");
    setState(() {
      final temp = pieces[oldIndex];
      pieces[oldIndex] = pieces[newIndex];
      pieces[newIndex] = temp;
      pieces[oldIndex].currentIndex = oldIndex;
      pieces[newIndex].currentIndex = newIndex;
      moves++;
    });
    checkWin();
    if (!_winHandled) _saveProgress();
  }
'''
s = re.sub(r"  void swapPieces\(int oldIndex, int newIndex\) \{.*?\n  \}\n  Future<void> checkWin", asset_swap + "  Future<void> checkWin", s, count=1, flags=re.S)
if "Future<void> _saveProgress() async" not in s:
    methods = '''  Future<void> _saveProgress() async {
    if (_winHandled || pieces.isEmpty) return;
    await SavedPuzzleService.save(type: 'asset', source: widget.assetPath, gridSize: widget.gridSize, seconds: seconds, moves: moves, order: pieces.map((p) => p.correctIndex).toList());
  }

  Future<void> _exitPuzzle() async {
    await _saveProgress();
    if (mounted) Navigator.pop(context);
  }

'''
    s = s.replace("  int calculateXp(int gridSize, int moves) {", methods + "  int calculateXp(int gridSize, int moves) {")
s = s.replace("_CircleButton(onTap: () => Navigator.pop(context), icon: Icons.arrow_back_rounded)", "_CircleButton(onTap: _exitPuzzle, icon: Icons.arrow_back_rounded)", 1)
s = s.replace('      print("Sending XP = $xpReward");', '      await SavedPuzzleService.clear();\n      print("Sending XP = $xpReward");', 1)
p.write_text(s)
