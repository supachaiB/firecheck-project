import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firecheck_setup/admin/dashboard_section/status_section.dart';

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
            _buildSectionTitle('ข้อมูลการชำรุด'),
            const SizedBox(height: 10),
            _buildContainerWithPadding(
              child: Column(
                children: [
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
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('ข้อมูลของกราฟ'),
            const SizedBox(height: 10),
            _buildContainerWithPadding(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildYearSelector(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('แผนภูมิแสดงสถานะถัง'),
                  const SizedBox(height: 10),
                  _buildBarChart(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('กราฟเส้นแสดงแนวโน้ม'),
                  const SizedBox(height: 10),
                  _buildLineChart(),
                ],
              ),
            ),
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

  Widget _buildUserTypeDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'ประเภทผู้ใช้:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        DropdownButton<String>(
          value: selectedUserType,
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
          onChanged: (value) {
            setState(() {
              selectedUserType = value!;
              inspectionCycle = (value == 'ผู้ใช้ทั่วไป') ? 30 : 90;
            });
          },
        ),
      ],
    );
  }

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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatusCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserTypeDropdown(),
        const SizedBox(height: 10),
        Text('รอบการตรวจ: $inspectionCycle วัน',
            style: const TextStyle(fontSize: 16)),
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

  Widget _buildDamageAlert({
    required String tankId,
    required String type,
    required String building,
    required String floor,
    required String reportDate,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0), // ระยะห่างระหว่างกล่อง
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!), // กรอบสีอ่อน
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ถังชำรุด: $tankId",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              Text(
                "วันที่แจ้ง: $reportDate",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const Divider(
              color: Color.fromARGB(255, 231, 129, 129), thickness: 1.0),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.red[300]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "ประเภทถัง: $type",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.location_city,
                  color: const Color.fromARGB(255, 226, 166, 166)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "อาคาร: $building, ชั้น: $floor",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
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
