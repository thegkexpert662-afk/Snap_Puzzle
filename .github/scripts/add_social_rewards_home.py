from pathlib import Path

p = Path('lib/screens/home_screen.dart')
s = p.read_text()

if "social_rewards_screen.dart" not in s:
    s = s.replace("import 'settings_screen.dart';\n", "import 'settings_screen.dart';\nimport 'social_rewards_screen.dart';\n")

marker = "  Widget _buildQuoteBanner() =>"
if "_buildSocialRewardsCard()" not in s:
    card = '''  Widget _buildSocialRewardsCard() {\n    return _gradientCard(\n      gradient: const [Color(0xFF7B2CFF), Color(0xFF3B0CA3)],\n      padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),\n      child: Row(children: [\n        Container(width: 58, height: 58, decoration: BoxDecoration(color: Colors.white.withOpacity(.14), shape: BoxShape.circle), child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 34)),\n        const SizedBox(width: 13),\n        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [\n          Text('Follow & Earn', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),\n          SizedBox(height: 4),\n          Text('YouTube +200 • Instagram +500 • Facebook +300 Coins', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700), maxLines: 2),\n        ])),\n        _circleArrow(() {\n          SoundService.play('click.mp3');\n          Navigator.push(context, MaterialPageRoute(builder: (_) => const SocialRewardsScreen()));\n        }),\n      ]),\n    );\n  }\n\n'''
    s = s.replace(marker, card + marker)

if "_buildSocialRewardsCard()," not in s:
    s = s.replace("                      _buildQuoteBanner(),", "                      _buildSocialRewardsCard(),\n                      const SizedBox(height: 14),\n                      _buildQuoteBanner(),")

p.write_text(s)
# trigger patch workflow
