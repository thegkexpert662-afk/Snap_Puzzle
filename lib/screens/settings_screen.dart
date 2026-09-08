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

    setState(() {
      sound = prefs.getBool("sound") ?? true;
      vibration = prefs.getBool("vibration") ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "⚙️ Settings",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        children: [

          SwitchListTile(
            value: sound,
            onChanged: (value) async {
              final prefs = await SharedPreferences.getInstance();

              await prefs.setBool("sound", value);

              setState(() {
                sound = value;
              });
            },
            title: const Text(
              "🔊 Sound",
              style: TextStyle(color: Colors.white),
            ),
          ),

          SwitchListTile(
            value: vibration,
            onChanged: (value) async {
              final prefs = await SharedPreferences.getInstance();

              await prefs.setBool("vibration", value);

              setState(() {
                vibration = value;
              });
            },
            title: const Text(
              "📳 Vibration",
              style: TextStyle(color: Colors.white),
            ),
          ),

          const Divider(color: Colors.white24),

          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.white),
            title: const Text(
              "Privacy Policy",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.description, color: Colors.white),
            title: const Text(
              "Terms & Conditions",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TermsConditionsScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: const Text(
              "Rate App",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.share, color: Colors.green),
            title: const Text(
              "Share App",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {},
          ),

          const Divider(color: Colors.white24),

          const ListTile(
            leading: Icon(Icons.info, color: Colors.blue),
            title: Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}