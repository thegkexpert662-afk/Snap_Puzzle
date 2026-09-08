from pathlib import Path

p = Path('lib/screens/puzzle_screen.dart')
s = p.read_text()

if "../widgets/puzzle_banner_ad.dart" not in s:
    s = s.replace("import '../services/saved_puzzle_service.dart';", "import '../services/saved_puzzle_service.dart';\nimport '../widgets/puzzle_banner_ad.dart';")

marker = "            Padding(\n              padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),"
if "const PuzzleBannerAd()" not in s and marker in s:
    s = s.replace(
        marker,
        "            const PuzzleBannerAd(),\n" + marker,
        1,
    )

p.write_text(s)
