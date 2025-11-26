// ============================================================================
// FILE: pie_chart_screen.dart
// MÔ TẢ: Màn hình hiển thị biểu đồ tròn (demo/example)
// CHỨC NĂNG:
//   - Hiển thị PieChart với fl_chart package
//   - Demo data mẫu cho 3 categories
//   - Touch interaction (tap vào section)
//   - Có thể mở rộng để hiển thị thống kê thực tế
// ============================================================================

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// ===== CLASS: PieChartScreen =====
/// Màn hình demo biểu đồ tròn (StatelessWidget)
class PieChartScreen extends StatelessWidget {
  const PieChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pie Chart Example'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  color: Colors.blue,
                  value: 40,
                  title: '40%',
                  radius: 50,
                  titleStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.red,
                  value: 30,
                  title: '30%',
                  radius: 50,
                  titleStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.green,
                  value: 20,
                  title: '20%',
                  radius: 50,
                  titleStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.yellow,
                  value: 10,
                  title: '10%',
                  radius: 50,
                  titleStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
