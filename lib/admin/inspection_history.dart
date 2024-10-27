import 'package:flutter/material.dart';

class InspectionHistoryPage extends StatefulWidget {
  const InspectionHistoryPage({super.key});

  @override
  _InspectionHistoryPageState createState() => _InspectionHistoryPageState();
}

class _InspectionHistoryPageState extends State<InspectionHistoryPage> {
  // ข้อมูลจำลอง (mock data)
  final List<Map<String, dynamic>> inspections = [
    {
      'tank_number': '001',
      'building': 'OPD',
      'floor': 'ชั้น 2',
      'date_checked': DateTime(2024, 10, 1),
      'inspector': 'นายสมชาย',
      'user_type': 'ผู้ใช้ทั่วไป', // เพิ่มประเภทผู้ใช้
      'remarks': 'ปกติ',
      'equipment_status': 'ตรวจสอบแล้ว'
    },
    {
      'tank_number': '002',
      'building': '10 ชั้น',
      'floor': 'ชั้น 1',
      'date_checked': DateTime(2024, 9, 15),
      'inspector': 'นายวิชัย',
      'user_type': 'ช่างเทคนิค', // เพิ่มประเภทผู้ใช้
      'remarks': 'พบการรั่วไหล',
      'equipment_status': 'ชำรุด'
    },
    {
      'tank_number': '003',
      'building': 'หลวงปู่ขาว',
      'floor': 'ชั้น 1',
      'date_checked': DateTime(2024, 8, 10),
      'inspector': 'นางสาวสมฤดี',
      'user_type': 'ช่างเทคนิค', // เพิ่มประเภทผู้ใช้
      'remarks': 'ส่งซ่อม',
      'equipment_status': 'เปลี่ยนถัง'
    },
  ];

  String? selectedBuilding;
  String? selectedFloor;
  String? selectedStatus;
  String? sortBy;

  @override
  Widget build(BuildContext context) {
    // ฟิลเตอร์ข้อมูลตามตัวเลือก
    List<Map<String, dynamic>> filteredInspections =
        inspections.where((inspection) {
      if (selectedBuilding != null &&
          inspection['building'] != selectedBuilding) {
        return false;
      }
      if (selectedFloor != null && inspection['floor'] != selectedFloor) {
        return false;
      }
      if (selectedStatus != null &&
          inspection['equipment_status'] != selectedStatus) {
        return false;
      }
      return true;
    }).toList();

    // จัดเรียงข้อมูลตามตัวเลือก
    if (sortBy == 'date') {
      filteredInspections.sort((a, b) => (b['date_checked'] as DateTime)
          .compareTo(a['date_checked'] as DateTime));
    } else if (sortBy == 'tank_number') {
      filteredInspections
          .sort((a, b) => a['tank_number'].compareTo(b['tank_number']));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติการตรวจสอบ'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ฟิลเตอร์และการจัดเรียง
              Card(
                margin: const EdgeInsets.only(bottom: 20),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ค้นหาและจัดเรียงข้อมูล',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: DropdownButton<String>(
                              value: selectedBuilding,
                              isExpanded: true,
                              hint: const Text('เลือกอาคาร'),
                              items: ['อาคาร 1', 'อาคาร 2', 'อาคาร 3']
                                  .map((building) {
                                return DropdownMenuItem<String>(
                                  value: building,
                                  child: Text(building),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedBuilding = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButton<String>(
                              value: selectedFloor,
                              isExpanded: true,
                              hint: const Text('เลือกชั้น'),
                              items:
                                  ['ชั้น 1', 'ชั้น 2', 'ชั้น 3'].map((floor) {
                                return DropdownMenuItem<String>(
                                  value: floor,
                                  child: Text(floor),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedFloor = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButton<String>(
                              value: selectedStatus,
                              isExpanded: true,
                              hint: const Text('สถานะการตรวจสอบ'),
                              items: [
                                'ตรวจสอบแล้ว',
                                'ชำรุด',
                                'ยังไมตรวจสอบ',
                                'ส่งซ่อม'
                              ].map((status) {
                                return DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(status),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedStatus = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text('เรียงตาม: '),
                          DropdownButton<String>(
                            value: sortBy,
                            hint: const Text('เลือกการจัดเรียง'),
                            items: [
                              DropdownMenuItem(
                                value: 'date',
                                child:
                                    const Text('วันที่ตรวจสอบ (ล่าสุดไปเก่า)'),
                              ),
                              DropdownMenuItem(
                                value: 'tank_number',
                                child: const Text('หมายเลขถัง'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                sortBy = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ตารางข้อมูลประวัติการตรวจสอบ
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('หมายเลขถัง')),
                        DataColumn(label: Text('อาคาร')),
                        DataColumn(label: Text('ชั้น')),
                        DataColumn(label: Text('วันที่ตรวจสอบ')),
                        DataColumn(label: Text('ผู้ตรวจสอบ')),
                        DataColumn(
                            label: Text(
                                'ประเภทผู้ใช้')), // เพิ่มคอลัมน์ประเภทผู้ใช้
                        DataColumn(label: Text('ผลการตรวจสอบ')),
                        DataColumn(label: Text('หมายเหตุ')),
                      ],
                      rows: filteredInspections.map((inspection) {
                        String tankNumber =
                            inspection['tank_number'] as String? ?? 'N/A';
                        String building =
                            inspection['building'] as String? ?? 'N/A';
                        String floor = inspection['floor'] as String? ?? 'N/A';
                        String dateChecked = inspection['date_checked'] != null
                            ? (inspection['date_checked'] as DateTime)
                                .toString()
                                .substring(0, 10)
                            : 'N/A';
                        String inspector =
                            inspection['inspector'] as String? ?? 'N/A';
                        String userType = inspection['user_type'] as String? ??
                            'N/A'; // เพิ่มประเภทผู้ใช้
                        String equipmentStatus =
                            inspection['equipment_status'] as String? ?? 'N/A';
                        String remarks =
                            inspection['remarks'] as String? ?? 'N/A';

                        return DataRow(cells: [
                          DataCell(Text(tankNumber)),
                          DataCell(Text(building)),
                          DataCell(Text(floor)),
                          DataCell(Text(dateChecked)),
                          DataCell(Text(inspector)),
                          DataCell(
                              Text(userType)), // เพิ่มข้อมูลประเภทผู้ใช้ในแถว
                          DataCell(Text(equipmentStatus)),
                          DataCell(Text(remarks)),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
