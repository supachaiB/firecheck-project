import 'package:flutter/material.dart';

class FireTankStatusPage extends StatefulWidget {
  @override
  _FireTankStatusPageState createState() => _FireTankStatusPageState();
}

class _FireTankStatusPageState extends State<FireTankStatusPage> {
  // ข้อมูลจำลอง
  final List<Map<String, dynamic>> buildings =
      List.generate(14, (buildingIndex) {
    return {
      "building": "Building ${buildingIndex + 1}",
      "floors": List.generate(15, (floorIndex) {
        return {
          "floor": "Floor ${floorIndex + 1}",
          "tanks": List.generate(3, (tankIndex) {
            return {
              "tankNumber":
                  "${buildingIndex + 1}-${floorIndex + 1}-${tankIndex + 1}",
              "status": (tankIndex % 3 == 0)
                  ? "พร้อมใช้งาน"
                  : (tankIndex % 3 == 1)
                      ? "ส่งซ่อม"
                      : "ยังไม่ตรวจสอบ",
              "lastChecked": "2024-10-${(tankIndex + 1) * 2}",
            };
          })
        };
      })
    };
  });

  String? selectedBuilding;
  String? selectedFloor;
  String? selectedStatus;
  String? selectedDate;
  List<Map<String, String>> filteredTanks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('สถานะถังดับเพลิง'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // กล่องสรุปภาพรวมสถานะถัง
            _buildStatusSummaryBox(),

            SizedBox(height: 10),

            // กล่องกรองข้อมูล
            _buildFilterBox(),

            // แสดงข้อมูลถังดับเพลิงในรูปแบบตาราง
            if (selectedFloor != null && selectedBuilding != null)
              Expanded(
                child: _buildDataTable(),
              ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างกล่องสรุปภาพรวมสถานะ
  Widget _buildStatusSummaryBox() {
    int readyCount = 0;
    int repairCount = 0;
    int brokenCount = 0;

    for (var building in buildings) {
      for (var floor in building['floors']) {
        for (var tank in floor['tanks']) {
          if (tank['status'] == 'พร้อมใช้งาน') readyCount++;
          if (tank['status'] == 'ส่งซ่อม') repairCount++;
          if (tank['status'] == 'ชำรุด') brokenCount++;
          if (tank['status'] == 'ยังไม่ตรวจสอบ') brokenCount++;
        }
      }
    }

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryCard("พร้อมใช้งาน", readyCount, Colors.green),
            _buildSummaryCard("ส่งซ่อม", repairCount, Colors.orange),
            _buildSummaryCard("ชำรุด", brokenCount, Colors.red),
            _buildSummaryCard("ยังไม่ตรวจสอบ", brokenCount, Colors.grey),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างการ์ดแสดงสรุปสถานะ
  Widget _buildSummaryCard(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        SizedBox(height: 8),
        Text(
          '$count',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // กล่องกรองข้อมูล
  Widget _buildFilterBox() {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // ตัวกรองสถานที่ (อาคาร)
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedBuilding,
                    hint: Text("เลือกอาคาร"),
                    isExpanded: true,
                    items: buildings.map((building) {
                      return DropdownMenuItem<String>(
                        value: building["building"],
                        child: Text(building["building"]),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBuilding = value;
                        selectedFloor = null;
                        filteredTanks.clear();
                      });
                    },
                  ),
                ),

                SizedBox(width: 10),

                // ตัวกรองสถานที่ (ชั้น)
                if (selectedBuilding != null)
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedFloor,
                      hint: Text("เลือกชั้น"),
                      isExpanded: true,
                      items: buildings
                          .firstWhere((building) =>
                              building["building"] ==
                              selectedBuilding)["floors"]
                          .map<DropdownMenuItem<String>>((floor) {
                        return DropdownMenuItem<String>(
                          value: floor["floor"],
                          child: Text(floor["floor"]),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedFloor = value;
                          _filterTanks();
                        });
                      },
                    ),
                  ),
              ],
            ),

            SizedBox(height: 10),

            // ตัวกรองสถานะ
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedStatus,
                    hint: Text("กรองตามสถานะ"),
                    isExpanded: true,
                    items: ['พร้อมใช้งาน', 'ส่งซ่อม', 'ชำรุด', 'ยังไม่ตรวจสอบ']
                        .map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value;
                        _filterTanks();
                      });
                    },
                  ),
                ),

                SizedBox(width: 10),

                // ตัวกรองวันที่ตรวจสอบล่าสุด
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedDate,
                    hint: Text("เลือกวันที่ตรวจสอบ"),
                    isExpanded: true,
                    items: List.generate(31, (index) {
                      final day = index + 1;
                      return DropdownMenuItem<String>(
                        value: '2024-10-$day',
                        child: Text('2024-10-$day'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDate = value;
                        _filterTanks();
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันแสดงข้อมูลในรูปแบบตาราง
  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('หมายเลขถัง')),
          DataColumn(label: Text('สถานะ')),
          DataColumn(label: Text('วันที่ตรวจสอบ')),
          DataColumn(label: Text('อัปเดตสถานะ')),
        ],
        rows: filteredTanks.map((tank) {
          return DataRow(
            cells: [
              DataCell(Text(tank['tankNumber'] ?? '')),
              DataCell(
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: _getStatusColor(tank['status'] ?? ''),
                      size: 12,
                    ),
                    const SizedBox(width: 8),
                    Text(tank['status'] ?? ''),
                  ],
                ),
              ),
              DataCell(Text(tank['lastChecked'] ?? '')),
              DataCell(
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _showUpdateStatusDialog(tank);
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ฟังก์ชันกำหนดสีของจุดตามสถานะ
  Color _getStatusColor(String status) {
    switch (status) {
      case 'พร้อมใช้งาน':
        return Colors.green;
      case 'ส่งซ่อม':
        return Colors.orange;
      case 'ชำรุด':
        return Colors.red;
      case 'ยังไม่ตรวจสอบ':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // ฟังก์ชันกรองข้อมูลถังดับเพลิง
  void _filterTanks() {
    if (selectedBuilding != null && selectedFloor != null) {
      var floors = buildings.firstWhere(
          (building) => building["building"] == selectedBuilding)["floors"];
      filteredTanks = floors
          .firstWhere((floor) => floor["floor"] == selectedFloor)["tanks"]
          .cast<Map<String, String>>();

      if (selectedStatus != null) {
        filteredTanks = filteredTanks
            .where((tank) => tank["status"] == selectedStatus)
            .toList();
      }

      if (selectedDate != null && selectedDate!.isNotEmpty) {
        filteredTanks = filteredTanks
            .where((tank) => tank["lastChecked"] == selectedDate)
            .toList();
      }
    }
  }

  // ฟังก์ชันแสดง Dialog สำหรับอัปเดตสถานะถัง
  void _showUpdateStatusDialog(Map<String, String> tank) {
    String? updatedStatus;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('อัปเดตสถานะถังหมายเลข ${tank['tankNumber']}'),
          content: DropdownButton<String>(
            value: updatedStatus,
            hint: Text("เลือกสถานะใหม่"),
            isExpanded: true,
            items: ['พร้อมใช้งาน', 'ส่งซ่อม', 'ชำรุด', 'ยังไม่ตรวจสอบ']
                .map((status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                updatedStatus = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  tank['status'] = updatedStatus ?? tank['status']!;
                });
                Navigator.of(context).pop();
              },
              child: Text('บันทึก'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('ยกเลิก'),
            ),
          ],
        );
      },
    );
  }
}
