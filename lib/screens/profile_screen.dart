import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProfile>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Me & Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 35, backgroundColor: Color(0xFF6366F1), child: Icon(Icons.person, size: 35)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('VIP Reader Tier 1', style: TextStyle(color: Colors.amber, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Coins', '${user.coins}', Icons.monetization_on, Colors.amber),
              _buildStatCard('Streak', '${user.readingStreak} Days', Icons.local_fire_department, Colors.deepOrange),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), minimumSize: const Size(double.infinity, 50)),
            onPressed: () {
              user.addCoins(50);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎁 Claimed 50 Daily Reward Coins!')));
            },
            icon: const Icon(Icons.card_giftcard, color: Colors.amber),
            label: const Text('Claim Daily Check-In Bonus (+50 Coins)'),
          ),
          const SizedBox(height: 24),
          const Text('App Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Dark Reading Mode'),
            value: true,
            onChanged: (val) {},
            secondary: const Icon(Icons.dark_mode),
          ),
          SwitchListTile(
            title: const Text('Push Notifications for New Chapters'),
            value: true,
            onChanged: (val) {},
            secondary: const Icon(Icons.notifications),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('App Language'),
            trailing: const Text('English', style: TextStyle(color: Colors.grey)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About StoryLand'),
            trailing: const Text('v1.0.2', style: TextStyle(color: Colors.grey)),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}