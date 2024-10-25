import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedYear = DateTime.now().year;
  String selectedUserType = 'User'; // ตัวแปรสำหรับ dropdown user/admin

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: _buildDrawer(context), // เพิ่ม Drawer
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // โซน 1: สถานะรวมของถังดับเพลิง พร้อม dropdown ประเภทผู้ใช้
            _buildSectionTitle('สถานะรวมของถังดับเพลิง'),
            const SizedBox(height: 10),
            _buildContainerWithPadding(
              child: _buildStatusCards(), // สถานะรวมของถังดับเพลิง
            ),
            const SizedBox(height: 20),

            // โซน 2: เลือกปีและกราฟ
            _buildSectionTitle('ข้อมูลของกราฟ'),
            const SizedBox(height: 10),
            _buildContainerWithPadding(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildYearSelector(), // ส่วนเลือกปี
                  const SizedBox(height: 20),
                  _buildSectionTitle('แผนภูมิแสดงสถานะถัง'),
                  const SizedBox(height: 10),
                  _buildBarChart(), // แผนภูมิแท่ง
                  const SizedBox(height: 20),
                  _buildSectionTitle('กราฟเส้นแสดงแนวโน้ม'),
                  const SizedBox(height: 10),
                  _buildLineChart(), // กราฟเส้น
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างเมนู Drawer
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
              Navigator.pop(context); // ยังคงอยู่ในหน้า Dashboard
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text('ตรวจสอบสถานะถัง'),
            onTap: () {
              Navigator.pushNamed(
                  context, '/firetankstatus'); // ลิงก์ไปหน้าสถานะถัง
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('ประวัติการตรวจสอบ'),
            onTap: () {
              Navigator.pushNamed(context,
                  '/inspectionhistory'); // ลิงก์ไปหน้าประวัติการตรวจสอบ
            },
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('การจัดการถังดับเพลิง'),
            onTap: () {
              Navigator.pushNamed(context,
                  '/fire_tank_management'); // ลิงก์ไปหน้าการจัดการถังดับเพลิง
            },
          ),
          const Divider(), // เส้นแบ่งเพื่อแยกปุ่มออกจากเมนูอื่น ๆ
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('ออกจากระบบ'),
            onTap: () {
              Navigator.pushReplacementNamed(
                  context, '/user'); // ลิงก์ไปหน้า user.dart
            },
          ),
        ],
      ),
    );
  }

  // ส่วนแสดงหัวข้อของแต่ละส่วน
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

  // Dropdown สำหรับเลือกประเภทผู้ใช้
  Widget _buildUserTypeDropdown() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween, // จัดให้ dropdown ไปอยู่ทางขวา
      children: [
        const Text(
          'ประเภทผู้ใช้:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        DropdownButton<String>(
          value: selectedUserType,
          items: const [
            DropdownMenuItem(
              value: 'User',
              child: Text('User'),
            ),
            DropdownMenuItem(
              value: 'Admin',
              child: Text('Admin'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              selectedUserType = value!;
            });
          },
        ),
      ],
    );
  }

  // ส่วนแสดง Container พร้อม Padding
  Widget _buildContainerWithPadding({required Widget child}) {
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
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: child,
    );
  }

  // ส่วนแสดงการ์ดสถานะ
  Widget _buildStatusCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserTypeDropdown(), // Dropdown ประเภทผู้ใช้ อยู่ในส่วนของการ์ดสถานะ
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildStatusCard(
                color: Colors.green,
                title: 'ถังที่พร้อมใช้งาน',
                count: '12',
                icon: Icons.check_circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatusCard(
                color: Colors.red,
                title:
                    'ยังไม่ตรวจสอบ', // เปลี่ยนจาก "ถังชำรุด" เป็น "ยังไม่ตรวจสอบ"
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

  // ส่วนเลือกปี
  Widget _buildYearSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'เลือกปี:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        DropdownButton<int>(
          value: selectedYear,
          items: List.generate(
            10,
            (index) {
              int year = DateTime.now().year - index;
              return DropdownMenuItem(
                value: year,
                child: Text('$year'),
              );
            },
          ),
          onChanged: (year) {
            setState(() {
              selectedYear = year!;
            });
          },
        ),
      ],
    );
  }

  // ฟังก์ชันสร้างแผนภูมิแท่ง
  Widget _buildBarChart() {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups:
              List.generate(12, (i) => _buildBarGroup(i + 1, 12 - i, i, 3)),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString());
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const monthNames = [
                    'ม.ค.',
                    'ก.พ.',
                    'มี.ค.',
                    'เม.ย.',
                    'พ.ค.',
                    'มิ.ย.',
                    'ก.ค.',
                    'ส.ค.',
                    'ก.ย.',
                    'ต.ค.',
                    'พ.ย.',
                    'ธ.ค.'
                  ];
                  return Text(monthNames[value.toInt() - 1]);
                },
              ),
            ),
            topTitles: AxisTitles(
              // เอาตัวเลขบนออก
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              // เอาตัวเลขขวาออก
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(
      int x, int ready, int notChecked, int repair) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: ready.toDouble(), color: Colors.green),
        BarChartRodData(toY: notChecked.toDouble(), color: Colors.red),
        BarChartRodData(toY: repair.toDouble(), color: Colors.orange),
      ],
    );
  }

  // ฟังก์ชันสร้างกราฟเส้น
  Widget _buildLineChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots:
                  List.generate(12, (i) => FlSpot(i + 1, (12 - i).toDouble())),
              isCurved: true,
              color: Colors.blue,
              barWidth: 4,
              belowBarData: BarAreaData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString());
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const monthNames = [
                    'ม.ค.',
                    'ก.พ.',
                    'มี.ค.',
                    'เม.ย.',
                    'พ.ค.',
                    'มิ.ย.',
                    'ก.ค.',
                    'ส.ค.',
                    'ก.ย.',
                    'ต.ค.',
                    'พ.ย.',
                    'ธ.ค.'
                  ];
                  return Text(monthNames[value.toInt() - 1]);
                },
              ),
            ),
            topTitles: AxisTitles(
              // เอาตัวเลขบนออก
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              // เอาตัวเลขขวาออก
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างการ์ดสถานะ
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
