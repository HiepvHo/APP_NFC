// ============================================================================
// FILE: home_screen.dart
// MÔ TẢ: Màn hình trang chủ - Dashboard
// CHỨC NĂNG:
//   - Hiển thị "Word of the Moment" (từ vựng xoay vòng mỗi 15s)
//   - Biểu đồ tròn (PieChart) thống kê tiến độ học tập
//   - Learning Stats (Words Learned, Practice Score, Quiz Score)
//   - Top Users Leaderboard (Bảng xếp hạng 6 người dùng)
//   - Auto-rotate từ vựng với Timer
// ============================================================================

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

/// ===== CLASS: HomeScreen =====
/// StatefulWidget vì cần quản lý Timer và rotate từ vựng
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentWordIndex = 0;
  late Timer _timer;

  final List<Map<String, String>> _vocabularyList = [
    {'en': 'Apple', 'vi': 'Quả táo'},
    {'en': 'Banana', 'vi': 'Quả chuối'},
    {'en': 'Orange', 'vi': 'Quả cam'},
    {'en': 'Potato', 'vi': 'Củ khoai tây'},
  ];

  @override
  void initState() {
    super.initState();
    _startWordRotation();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startWordRotation() {
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      setState(() {
        _currentWordIndex = (_currentWordIndex + 1) % _vocabularyList.length;
      });
    });
  }

  Widget _buildVocabularyCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 89, 206).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFFC2D1).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Word of the Moment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _vocabularyList[_currentWordIndex]['en']!,
            style: const TextStyle(
              fontSize: 32, // Increased font size
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _vocabularyList[_currentWordIndex]['vi']!,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> userStats = [
      {'name': 'Words Learned', 'value': 30, 'color': Colors.blue},
      {'name': 'Practice Score', 'value': 45, 'color': Colors.green},
      {'name': 'Quiz Score', 'value': 25, 'color': Colors.orange},
    ];

    final List<Map<String, dynamic>> topUsers = [
      {'name': 'Viết Hiệp', 'score': 980, 'rank': 1},
      {'name': 'Trương Minh', 'score': 850, 'rank': 2},
      {'name': 'Đình KhanhKhanh', 'score': 720, 'rank': 3},
      {'name': 'hehehehe', 'score': 600, 'rank': 4},
      {'name': 'HihiHihi', 'score': 520, 'rank': 5},
      {'name': 'haha', 'score': 480, 'rank': 6},
      // Add more top users as needed
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFDAC1),
      body: SafeArea(
        child: Column(
          children: [
            // Stats overview container
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Left side - Pie Chart
                  Expanded(
                    flex: 3,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: PieChart(
                        PieChartData(
                          sections: userStats.map((stat) {
                            return PieChartSectionData(
                              color: stat['color'],
                              value: stat['value'].toDouble(),
                              title: '${stat['value']}%',
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 25,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Right side - Learning Stats
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 55, 115, 243)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStatItem(
                              'Learning Ability', '95%', Icons.trending_up),
                          const SizedBox(height: 8),
                          _buildStatItem('Best Response', '1.2s', Icons.timer),
                          const SizedBox(height: 8),
                          _buildStatItem('Daily Streak', '7 days',
                              Icons.local_fire_department),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Top Users Section
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top Learners This Month',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: topUsers.length + 1, // +1 for vocabulary card
                        itemBuilder: (context, index) {
                          // Show vocabulary card at the end
                          if (index == topUsers.length) {
                            return _buildVocabularyCard();
                          }
                          
                          final user = topUsers[index];
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            leading: CircleAvatar(
                              backgroundColor: Colors.pink.shade200,
                              radius: 20,
                              child: Text(
                                '#${user['rank']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            title: Text(
                              user['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              '${user['score']} points',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
