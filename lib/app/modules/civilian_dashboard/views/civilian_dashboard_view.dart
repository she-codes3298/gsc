import 'package:flutter/material.dart';
import 'package:d_m/app/common/widgets/common_scaffold.dart'; // Adjust your import path

class CivilianDashboardView extends StatelessWidget {
  const CivilianDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example Figma colors (update as needed)
    final Color accentColor = const Color(0xFF5F6898); // Updated Accent Color
    final Color communityBackground = const Color(0xFFE3F2FD); // Light Blue

    return CommonScaffold(
      title: 'Dashboard',
      currentIndex: 0, // Home index
      body: SafeArea(
        child: Column(
          children: [
            // BUTTON TILES (Predictive AI and Learn)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDashboardTile(
                  context: context,
                  title: 'PREDICTIVE AI',
                  color: accentColor,
                  routeName: '/predictive_ai',
                ),
                _buildDashboardTile(
                  context: context,
                  title: 'LEARN',
                  color: accentColor,
                  routeName: '/learn',
                ),
              ],
            ),
            const SizedBox(height: 8),
            // COMMUNITY SECTION (Post with reaction options and history button)
            Expanded(
              child: Container(
                margin:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: communityBackground,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Community Post Header
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage:
                          NetworkImage('https://via.placeholder.com/150'),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'NDRF',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            // TODO: Show post options
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Community Post Content
                    const Text(
                      'This is a sample community post showing real-time updates on disaster management. Stay alert and follow the instructions provided.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    // Reaction Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildReactionIcon(
                            icon: Icons.thumb_up_alt_outlined, label: 'Like'),
                        _buildReactionIcon(
                            icon: Icons.mode_comment_outlined, label: 'Comment'),
                        _buildReactionIcon(
                            icon: Icons.share_outlined, label: 'Share'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // History Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/community_history');
                        },
                        child: const Text('History'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // WEATHER CARD
            Container(
              margin:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud, size: 48, color: Colors.blue),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Manipur, Imphal',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text('28° | Sunny'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for dashboard tile
  Widget _buildDashboardTile({
    required BuildContext context,
    required String title,
    required Color color,
    required String routeName,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
        child: Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: Text(
              title,
              style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for reaction icons
  Widget _buildReactionIcon({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
