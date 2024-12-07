import 'package:flutter/material.dart';

class TrendLineChartSection extends StatelessWidget {
  const TrendLineChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('กราฟเส้นแสดงแนวโน้ม'),
          const SizedBox(height: 10),
          _buildDummyLineChart(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDummyLineChart() {
    // ตัวอย่าง: ใช้ Container เพื่อแทนที่กราฟจริง
    return Container(
      height: 200,
      color: Colors.grey.shade300,
      child: const Center(
        child: Text(
          'กราฟเส้นแนวโน้ม (Dummy)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
