import 'package:flutter/material.dart';
import 'package:d_m/app/common/widgets/common_scaffold.dart';
import 'package:d_m/app/modules/ai_chatbot.dart';
import 'package:d_m/app/modules/community_history/views/community_page.dart';

class CivilianDashboardView extends StatelessWidget {
  const CivilianDashboardView({Key? key}) : super(key: key);

  bool isRiskFree() {
    return DateTime.now().second % 2 == 0;
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = const Color(0xFF5F6898);
    final Color communityBackground = const Color(0xFFE3F2FD);

    bool riskFree = isRiskFree();
    Color riskCardColor = riskFree ? Colors.green[100]! : Colors.red[100]!;
    String riskText = riskFree ? "You are in a Risk-Free Zone" : "You are in a High-Risk Zone!";
    Color riskTextColor = riskFree ? Colors.green[900]! : Colors.red[900]!;

    return CommonScaffold(
      title: 'Dashboard',
      currentIndex: 0,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDashboardTile(context, 'PREDICTIVE AI', accentColor, '/predictive_ai'),
                    _buildDashboardTile(context, 'LEARN', accentColor, '/learn'),
                  ],
                ),
                const SizedBox(height: 8),
                _buildRiskStatus(riskCardColor, riskText, riskTextColor, riskFree),
                _buildCommunitySection(context, communityBackground),
                _buildWeatherCard(),
              ],
            ),
          ),
          Positioned(
            bottom: 101,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: accentColor,
              onPressed: () {
                Navigator.pushNamed(context, '/ai_chatbot');
              },
              child: Image.asset(
                'assets/images/chatbot.png',
                width: 28,
                height: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTile(BuildContext context, String title, Color color, String routeName) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
        child: Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8.0)),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRiskStatus(Color riskCardColor, String riskText, Color riskTextColor, bool riskFree) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: riskCardColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(riskFree ? Icons.check_circle : Icons.warning, color: riskTextColor, size: 32),
          const SizedBox(width: 8),
          Text(riskText, style: TextStyle(color: riskTextColor, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCommunitySection(BuildContext context, Color communityBackground) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(color: communityBackground, borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(backgroundImage: NetworkImage('assets/images/flood.jpg')),
                const SizedBox(width: 8),
                const Text('Flood', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'We have set few refugee camp near apc area',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildReactionIcon(Icons.thumb_up_alt_outlined, 'Like'),
                _buildReactionIcon(Icons.mode_comment_outlined, 'Comment'),
                _buildReactionIcon(Icons.share_outlined, 'Share'),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CommunityPage(),
                    ),
                  );

                },
                child: const Text('View Community'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(8.0)),
      child: Row(
        children: [
          const Icon(Icons.cloud, size: 48, color: Colors.blue),
          const SizedBox(width: 25),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Manipur, Imphal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('28° | Sunny'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReactionIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}