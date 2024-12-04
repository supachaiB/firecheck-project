import 'package:flutter/material.dart';

class StatusSection extends StatelessWidget {
  const StatusSection({super.key});

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
          _buildSectionTitle('สถานะรวมของถังดับเพลิง'),
          const SizedBox(height: 10),
          _buildStatusCards(),
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

  Widget _buildStatusCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserTypeDropdown(),
        const SizedBox(height: 10),
        Text('รอบการตรวจ: 30 วัน', style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildStatusCard(
                color: Colors.green,
                title: 'ตรวจสอบแล้ว',
                count: '12',
                icon: Icons.check_circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatusCard(
                color: Colors.red,
                title: 'ยังไม่ตรวจสอบ',
                count: '3',
                icon: Icons.error,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatusCard(
                color: Colors.orange,
                title: 'ถังส่งซ่อม',
                count: '2',
                icon: Icons.build,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserTypeDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'ประเภทผู้ใช้:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        DropdownButton<String>(
          value: 'ผู้ใช้ทั่วไป',
          items: const [
            DropdownMenuItem(
              value: 'ผู้ใช้ทั่วไป',
              child: Text('ผู้ใช้ทั่วไป'),
            ),
            DropdownMenuItem(
              value: 'ช่างเทคนิค',
              child: Text('ช่างเทคนิค'),
            ),
          ],
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required Color color,
    required String title,
    required String count,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            count,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
