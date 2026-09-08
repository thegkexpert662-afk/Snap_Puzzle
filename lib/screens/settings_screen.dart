import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool sound = true;
  bool vibration = true;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      sound = prefs.getBool('sound') ?? true;
      vibration = prefs.getBool('vibration') ?? true;
    });
  }

  Future<void> setSound(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound', value);
    if (mounted) setState(() => sound = value);
  }

  Future<void> setVibration(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibration', value);
    if (mounted) setState(() => vibration = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061B43),
      body: SafeArea(
        child: Stack(
          children: [
            const _SettingsBackground(),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _header(),
                      const SizedBox(height: 24),
                      _soundPanel(),
                      const SizedBox(height: 20),
                      _linksPanel(),
                      const SizedBox(height: 20),
                      _versionPanel(),
                      const SizedBox(height: 20),
                      _thanksPanel(),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Row(
        children: [
          _BackButton(onTap: () => Navigator.pop(context)),
          const SizedBox(width: 15),
          const Icon(Icons.settings_rounded,
              color: Color(0xFF8DDCFF), size: 60),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Customize your experience',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF9CCBFF),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _soundPanel() => _Panel(
        child: Column(
          children: [
            _ToggleRow(
              Icons.volume_up_rounded,
              const [Color(0xFF1AAEFF), Color(0xFF075BCB)],
              'Sound',
              'Play game sounds',
              sound,
              setSound,
            ),
            const _DividerLine(),
            _ToggleRow(
              Icons.vibration_rounded,
              const [Color(0xFFB83DFF), Color(0xFF6410D9)],
              'Vibration',
              'Feel the game feedback',
              vibration,
              setVibration,
            ),
          ],
        ),
      );

  Widget _linksPanel() => _Panel(
        child: Column(
          children: [
            _LinkRow(
              Icons.shield_rounded,
              const [Color(0xFF18D890), Color(0xFF00A85D)],
              'Privacy Policy',
              'Learn how we protect your data',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen()),
              ),
            ),
            const _DividerLine(),
            _LinkRow(
              Icons.description_rounded,
              const [Color(0xFFFFD52B), Color(0xFFFF9800)],
              'Terms & Conditions',
              'Read our terms and rules',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const TermsConditionsScreen()),
              ),
            ),
            const _DividerLine(),
            _LinkRow(
              Icons.star_rounded,
              const [Color(0xFFFFDF3A), Color(0xFFFFA000)],
              'Rate App',
              'Support us with a 5 star rating',
              () => _info('Rate App'),
            ),
            const _DividerLine(),
            _LinkRow(
              Icons.share_rounded,
              const [Color(0xFFFF43B0), Color(0xFFE30087)],
              'Share App',
              'Tell your friends about Snap Pazzel',
              () => _info('Share App'),
            ),
          ],
        ),
      );

  Widget _versionPanel() => const _Panel(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        child: Row(
          children: [
            _GradientIcon(
              Icons.info_rounded,
              [Color(0xFF18C9FF), Color(0xFF0069D9)],
              56,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'version: 1.0.2',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'You are using the latest version',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Color(0xFF9BC9FF),
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _thanksPanel() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4330EA), Color(0xFF181A8B)],
          ),
          borderRadius: BorderRadius.circular(27),
          border: Border.all(color: const Color(0xFF704FFF), width: 2),
          boxShadow: const [
            BoxShadow(color: Color(0x664D3AFF), blurRadius: 20),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 68,
              height: 64,
              child: Stack(
                children: [
                  Positioned(
                      left: 0,
                      top: 0,
                      child: Text('🧩', style: TextStyle(fontSize: 28))),
                  Positioned(
                      right: 0,
                      top: 2,
                      child: Text('🧩', style: TextStyle(fontSize: 25))),
                  Positioned(
                      left: 20,
                      bottom: 0,
                      child: Text('🧩', style: TextStyle(fontSize: 30))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thank you for playing!',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Small Pieces, Big Happiness 💜',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Color(0xFFC2D7FF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  void _info(String title) => showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: const Color(0xFF092452),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Text(
            '$title is available in Snap Pazzel.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('OK'),
            ),
          ],
        ),
      );
}

class _Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Panel({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF092B62), Color(0xFF061D48)],
          ),
          borderRadius: BorderRadius.circular(29),
          border: Border.all(color: const Color(0xFF167AD7), width: 2),
          boxShadow: const [
            BoxShadow(
                color: Color(0x44006DFF),
                blurRadius: 17,
                offset: Offset(0, 7)),
          ],
        ),
        child: child,
      );
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final List<Color> colors;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow(
    this.icon,
    this.colors,
    this.title,
    this.subtitle,
    this.value,
    this.onChanged,
  );

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 94,
        child: Row(
          children: [
            _GradientIcon(icon, colors, 56),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0xFF91C5FF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 9),
            _AppSwitch(value: value, onChanged: onChanged),
          ],
        ),
      );
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final List<Color> colors;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LinkRow(
      this.icon, this.colors, this.title, this.subtitle, this.onTap);

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 82,
            child: Row(
              children: [
                _GradientIcon(icon, colors, 52),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFF91C5FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF9DD4FF), size: 32),
              ],
            ),
          ),
        ),
      );
}

class _GradientIcon extends StatelessWidget {
  final IconData icon;
  final List<Color> colors;
  final double size;

  const _GradientIcon(this.icon, this.colors, this.size);

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors),
          border: Border.all(color: Colors.white24, width: 1.5),
          boxShadow: [
            BoxShadow(color: colors.last.withOpacity(.45), blurRadius: 12),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * .58),
      );
}

class _AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AppSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 76,
          height: 37,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: value
                  ? const [Color(0xFF762BFF), Color(0xFFB63CFF)]
                  : const [Color(0xFF304A72), Color(0xFF162B4C)],
            ),
            border: Border.all(
                color: value ? const Color(0xFFE056FF) : Colors.white24,
                width: 1.5),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            alignment:
                value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 29,
              height: 29,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Color(0x66000000), blurRadius: 7),
                ],
              ),
            ),
          ),
        ),
      );
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) => Container(
        height: 1.5,
        color: const Color(0xFF24548B),
      );
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                  colors: [Color(0xFF0C448E), Color(0xFF061E4E)]),
              border: Border.all(color: const Color(0xFF0F66C6), width: 2),
              boxShadow: const [
                BoxShadow(color: Color(0x44000000), blurRadius: 10),
              ],
            ),
            child: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 36),
          ),
        ),
      );
}

class _SettingsBackground extends StatelessWidget {
  const _SettingsBackground();

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF072D6B),
                Color(0xFF061D49),
                Color(0xFF03132F),
              ],
              stops: [0, .48, 1],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -70,
                right: -80,
                child: _glow(210, const Color(0xFF0073FF)),
              ),
              Positioned(
                top: 450,
                left: -100,
                child: _glow(230, const Color(0xFF0054C8)),
              ),
              Positioned(
                bottom: 100,
                right: -90,
                child: _glow(220, const Color(0xFF3120B5)),
              ),
            ],
          ),
        ),
      );

  static Widget _glow(double size, Color color) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(.22),
                  blurRadius: 100,
                  spreadRadius: 35),
            ],
          ),
        ),
      );
}
