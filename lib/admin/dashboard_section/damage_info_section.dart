import 'package:flutter/material.dart';

class DamageInfoSection extends StatelessWidget {
  const DamageInfoSection({super.key});

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
          _buildSectionTitle('ข้อมูลการชำรุด'),
          const SizedBox(height: 10),
          _buildDamageAlert(
            tankId: "fire001",
            type: "ถัง CO2",
            building: "อาคาร A",
            floor: "ชั้น 2",
            reportDate: "10/10/2024",
          ),
          _buildDamageAlert(
            tankId: "fire002",
            type: "ถังเคมี",
            building: "อาคาร B",
            floor: "ชั้น 1",
            reportDate: "11/10/2024",
          ),
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

  Widget _buildDamageAlert({
    required String tankId,
    required String type,
    required String building,
    required String floor,
    required String reportDate,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 3,
        child: ListTile(
          leading: const Icon(Icons.warning, color: Colors.red),
          title: Text('ถัง: $tankId - $type'),
          subtitle:
              Text('อาคาร: $building, ชั้น: $floor\nวันที่แจ้ง: $reportDate'),
        ),
      ),
    );
  }
}
