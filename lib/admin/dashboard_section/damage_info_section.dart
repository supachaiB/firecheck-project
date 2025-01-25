import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DamageInfoSection extends StatelessWidget {
  const DamageInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('firetank_Collection')
          .where('status', isEqualTo: 'ชำรุด') // เพิ่มเงื่อนไขที่นี่
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('ไม่มีข้อมูลการชำรุด'));
        }

        final damageList = snapshot.data!.docs;

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
              ...damageList.map((damage) {
                final data = damage.data() as Map<String, dynamic>;
                return _buildDamageAlert(
                  tankId: data['tank_id'] ?? 'ไม่ระบุ',
                  type: data['type'] ?? 'ไม่ระบุ',
                  building: data['building'] ?? 'ไม่ระบุ',
                  floor: data['floor'] ?? 'ไม่ระบุ',
                  reportDate: data['reportDate'] ?? '-',
                );
              }).toList(),
            ],
          ),
        );
      },
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
