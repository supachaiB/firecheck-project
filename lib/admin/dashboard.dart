import 'package:flutter/material.dart';
import 'package:firecheck_setup/admin/dashboard_section/status_section.dart';
import 'package:firecheck_setup/admin/dashboard_section/damage_info_section.dart';
import 'package:firecheck_setup/admin/dashboard_section/graph_info_section.dart';
import 'package:firecheck_setup/admin/dashboard_section/trend_line_chart_section.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedYear = DateTime.now().year;
  String selectedUserType =
      'ผู้ใช้ทั่วไป'; // กำหนดค่าเริ่มต้นให้ตรงกับ Dropdown
  int inspectionCycle = 30; // รอบการตรวจสอบเริ่มต้นสำหรับผู้ใช้ทั่วไป

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusSection(), // ใช้ section ที่แยกออกมา
            const SizedBox(height: 20),
            const DamageInfoSection(),
            const SizedBox(height: 20),
            const GraphInfoSection(),
            const SizedBox(height: 20),
            const TrendLineChartSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Text(
              'เมนู',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pushNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text('ตรวจสอบสถานะถัง'),
            onTap: () {
              Navigator.pushNamed(context, '/firetankstatus');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('ประวัติการตรวจสอบ'),
            onTap: () {
              Navigator.pushNamed(context, '/inspectionhistory');
            },
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('การจัดการถังดับเพลิง'),
            onTap: () {
              Navigator.pushNamed(context, '/fire_tank_management');
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text('Qr-code'),
            onTap: () {
              Navigator.pushNamed(context, '/qr_code');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('ออกจากระบบ'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/user');
            },
          ),
        ],
      ),
    );
  }
}
