import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialRewardsScreen extends StatefulWidget {
  const SocialRewardsScreen({super.key});

  @override
  State<SocialRewardsScreen> createState() => _SocialRewardsScreenState();
}

class _SocialRewardsScreenState extends State<SocialRewardsScreen> {
  static const _tasks = <Map<String, dynamic>>[
    {
      'key': 'youtube',
      'title': 'YouTube',
      'subtitle': 'Subscribe to Kopersay Tech',
      'coins': 200,
      'icon': Icons.play_circle_fill_rounded,
      'url': 'https://www.youtube.com/@kopersaytech',
    },
    {
      'key': 'instagram',
      'title': 'Instagram',
      'subtitle': 'Follow @kopersaytech',
      'coins': 500,
      'icon': Icons.camera_alt_rounded,
      'url': 'https://www.instagram.com/kopersaytech?stkn=MXVxbXJsZ2hpeW1uYg%3D%3D',
    },
    {
      'key': 'facebook',
      'title': 'Facebook',
      'subtitle': 'Follow Kopersay Technologies',
      'coins': 300,
      'icon': Icons.facebook_rounded,
      'url': 'https://www.facebook.com/people/Kopersay-Technologies/61593931361565/?rdid=nOdNEwy9stlQoiej&share_url=https%3A%2F%2Fwww.facebook.com%2Fshare%2F1DFtjNQct4%2F',
    },
  ];

  bool _busy = false;

  Future<void> _claim(Map<String, dynamic> task) async {
    if (_busy) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _busy = true);
    try {
      final uri = Uri.parse(task['url'] as String);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not open link');
      }

      // Opening the social link is the client-side completion signal.
      // Actual subscribe/follow verification is not available through these public links.
      final ref = FirebaseFirestore.instance.collection('players').doc(user.uid);
      final rewardKey = 'socialReward_${task['key']}';
      final reward = (task['coins'] as int);
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final data = snap.data() ?? <String, dynamic>{};
        if (data[rewardKey] == true) return;
        final current = (data['coins'] as num?)?.toInt() ?? 0;
        tx.set(ref, {'coins': current + reward, rewardKey: true}, SetOptions(merge: true));
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('+${task['coins']} Coins added!')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open this link. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071B43),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071B43),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Follow & Earn', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF18B9FF), Color(0xFF0069EA)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 42),
                SizedBox(height: 10),
                Text('Support Kopersay & Earn Coins', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                SizedBox(height: 6),
                Text('Open our social pages and claim each reward once.', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ]),
            ),
            const SizedBox(height: 18),
            ..._tasks.map((task) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RewardCard(task: task, busy: _busy, onClaim: () => _claim(task)),
            )),
          ],
        ),
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final bool busy;
  final VoidCallback onClaim;

  const _RewardCard({required this.task, required this.busy, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    final key = 'socialReward_${task['key']}';
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseAuth.instance.currentUser == null
          ? null
          : FirebaseFirestore.instance.collection('players').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        final claimed = snapshot.data?.data()?[key] == true;
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF0A285B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: Colors.white.withOpacity(.10), shape: BoxShape.circle),
              child: Icon(task['icon'] as IconData, color: Colors.white, size: 31),
            ),
            const SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(task['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(task['subtitle'] as String, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 7),
              Text('+${task['coins']} Coins', style: const TextStyle(color: Color(0xFFFFE11A), fontWeight: FontWeight.w900)),
            ])),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: claimed || busy ? null : onClaim,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF18B9FF), foregroundColor: Colors.white),
              child: Text(claimed ? 'Claimed' : 'Open'),
            ),
          ]),
        );
      },
    );
  }
}
