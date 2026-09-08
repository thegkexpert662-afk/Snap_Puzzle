import 'package:flutter/material.dart';
import '../services/google_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'player_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061B43),
      body: SafeArea(
        child: Stack(
          children: [
            const _LoginBackground(),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 35, 24, 35),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    children: [
                      Container(
                        width: 122,
                        height: 122,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF18B9FF), Color(0xFF1452D4)],
                          ),
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(color: Color(0x6600B7FF), blurRadius: 30, spreadRadius: 3),
                          ],
                        ),
                        child: const Icon(Icons.extension_rounded, color: Colors.white, size: 72),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Snap Pazzel',
                        style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Play • Solve • Win',
                        style: TextStyle(color: Color(0xFF9CCBFF), fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 38),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(22, 25, 22, 24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF0B397A), Color(0xFF061D49)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: const Color(0xFF1979D5), width: 2),
                          boxShadow: const [BoxShadow(color: Color(0x55006DFF), blurRadius: 24, offset: Offset(0, 10))],
                        ),
                        child: Column(
                          children: [
                            const Text('Welcome back!', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 7),
                            const Text('Choose how you want to start playing', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFA8D1FF), fontSize: 14)),
                            const SizedBox(height: 25),
                            SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : () async {
                                  setState(() => _isLoading = true);
                                  try {
                                    final user = await GoogleAuthService.signInWithGoogle();
                                    if (!context.mounted) return;
                                    if (user == null) return;

                                    final playerDoc = await FirebaseFirestore.instance
                                        .collection('players')
                                        .doc(user.uid)
                                        .get();
                                    if (!context.mounted) return;

                                    if (playerDoc.exists) {
                                      final isBanned = playerDoc.data()?['isBanned'] ?? false;
                                      if (isBanned) {
                                        await GoogleAuthService.signOut();
                                        if (!context.mounted) return;
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (_) => AlertDialog(
                                            backgroundColor: const Color(0xFF3B0A20),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                            title: const Center(child: Text('🚫 ACCOUNT BANNED', textAlign: TextAlign.center, style: TextStyle(color: Colors.redAccent, fontSize: 22, fontWeight: FontWeight.w900))),
                                            content: const Text('Your account has been banned by the Admin.\n\nPlease contact support.\nsnappazzel.support@gmail.com', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
                                            actionsAlignment: MainAxisAlignment.center,
                                            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))],
                                          ),
                                        );
                                        return;
                                      }
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                                    } else {
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PlayerSetupScreen()));
                                    }
                                  } finally {
                                    if (mounted) setState(() => _isLoading = false);
                                  }
                                },
                                icon: const Icon(Icons.login_rounded),
                                label: const Text('Continue with Google', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2DB8FF),
                                  foregroundColor: Colors.white,
                                  elevation: 8,
                                  shadowColor: const Color(0x6600B7FF),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.person_outline_rounded),
                                label: const Text('Continue as Guest', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Color(0xFF4B82BA), width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'By continuing you agree to\nPrivacy Policy & Terms of Service',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF7EA8D6), fontSize: 12, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator(color: Color(0xFF35BCFF))),
              ),
          ],
        ),
      ),
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();
  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF082E6D), Color(0xFF061D49), Color(0xFF03132F)]),
          ),
          child: Stack(children: [
            Positioned(top: -100, right: -80, child: _glow(260, const Color(0xFF008BFF))),
            Positioned(top: 330, left: -120, child: _glow(240, const Color(0xFF2450E8))),
            Positioned(bottom: -100, right: -70, child: _glow(250, const Color(0xFF6C2CFF))),
          ]),
        ),
      );

  static Widget _glow(double size, Color color) => IgnorePointer(
        child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(.22), blurRadius: 110, spreadRadius: 35)])),
      );
}