import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InspectionHistoryPage extends StatefulWidget {
  const InspectionHistoryPage({super.key});

  @override
  _InspectionHistoryPageState createState() => _InspectionHistoryPageState();
}

class _InspectionHistoryPageState extends State<InspectionHistoryPage> {
  String? selectedBuilding;
  String? selectedFloor;
  String? selectedStatus;
  String? sortBy;

  @override
  Widget build(BuildContext context) {
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
              // ส่วนตัวกรอง
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
                              items: ['10 ชั้น', 'หลวงปู่ขาว'].map((building) {
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
                              items: ['1', '2', '3'].map((building) {
                                return DropdownMenuItem<String>(
                                  value: building.toString(),
                                  child: Text(building.toString()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedFloor = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: DropdownButton<String>(
                              value: selectedStatus,
                              isExpanded: true,
                              hint: const Text('เลือกสถานะการตรวจสอบ'),
                              items: [
                                'ตรวจสอบแล้ว',
                                'ส่งซ่อม',
                                'ชำรุด',
                                'ยังไม่ตรวจสอบ'
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
                          const SizedBox(width: 10),
                        ],
                      ),
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

              // ส่วนแสดงข้อมูล
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('firetank_Collection')
                    .snapshots(),
                builder: (context, firetankSnapshot) {
                  if (firetankSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!firetankSnapshot.hasData ||
                      firetankSnapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('ไม่มีข้อมูลใน Firetank Collection'));
                  }

                  List<Map<String, dynamic>> firetankData = firetankSnapshot
                      .data!.docs
                      .map((doc) => doc.data() as Map<String, dynamic>)
                      .toList();

                  // ดึงข้อมูลจาก form_checks
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('form_checks')
                        .snapshots(),
                    builder: (context, formChecksSnapshot) {
                      if (formChecksSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!formChecksSnapshot.hasData ||
                          formChecksSnapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('ไม่มีข้อมูลใน Form Checks'));
                      }

                      List<Map<String, dynamic>> formChecksData =
                          formChecksSnapshot.data!.docs
                              .map((doc) => doc.data() as Map<String, dynamic>)
                              .toList();

                      // รวมข้อมูลจากทั้งสอง collection
                      List<Map<String, dynamic>> combinedData =
                          firetankData.map((firetank) {
                        String tankId = firetank['tank_id'] ?? 'N/A';

                        // หา form_check ที่ตรงกับ tank_id
                        var formCheck = formChecksData.firstWhere(
                            (check) => check['tank_id'] == tankId,
                            orElse: () => {
                                  'date_checked': 'N/A',
                                  'inspector': 'N/A',
                                  'user_type': 'N/A',
                                  'equipment_status': 'N/A',
                                  'remarks': 'N/A'
                                });

                        return {
                          'tank_id': tankId,
                          'building': firetank['building'] ?? 'N/A',
                          'floor': firetank['floor'] ?? 'N/A',
                          'date_checked': formCheck['date_checked'] ?? 'N/A',
                          'inspector': formCheck['inspector'] ?? 'N/A',
                          'user_type': formCheck['user_type'] ?? 'N/A',
                          'equipment_status':
                              formCheck['equipment_status'] ?? 'N/A',
                          'remarks': formCheck['remarks'] ?? 'N/A',
                        };
                      }).toList();

                      // กรองข้อมูลตามตัวเลือก
                      if (selectedBuilding != null &&
                          selectedBuilding!.isNotEmpty) {
                        combinedData = combinedData.where((inspection) {
                          return inspection['building'] == selectedBuilding;
                        }).toList();
                      }
                      if (selectedFloor != null && selectedFloor!.isNotEmpty) {
                        combinedData = combinedData.where((inspection) {
                          return inspection['floor'] == selectedFloor;
                        }).toList();
                      }
                      if (selectedStatus != null &&
                          selectedStatus!.isNotEmpty) {
                        combinedData = combinedData.where((inspection) {
                          return inspection['equipment_status'] ==
                              selectedStatus;
                        }).toList();
                      }

                      // การจัดเรียงข้อมูล
                      if (sortBy == 'date') {
                        combinedData.sort((a, b) {
                          DateTime? dateA = a['date_checked'] is Timestamp
                              ? (a['date_checked'] as Timestamp).toDate()
                              : DateTime.tryParse(a['date_checked']);
                          DateTime? dateB = b['date_checked'] is Timestamp
                              ? (b['date_checked'] as Timestamp).toDate()
                              : DateTime.tryParse(b['date_checked']);
                          return dateB!.compareTo(dateA!); // ล่าสุดก่อน
                        });
                      } else if (sortBy == 'tank_number') {
                        combinedData.sort((a, b) {
                          return a['tank_id'].compareTo(b['tank_id']);
                        });
                      }

                      return DataTable(
                        columns: const [
                          DataColumn(label: Text('หมายเลขถัง')),
                          DataColumn(label: Text('อาคาร')),
                          DataColumn(label: Text('ชั้น')),
                          DataColumn(label: Text('วันที่ตรวจสอบ')),
                          DataColumn(label: Text('ผู้ตรวจสอบ')),
                          DataColumn(label: Text('ประเภทผู้ใช้')),
                          DataColumn(label: Text('ผลการตรวจสอบ')),
                          DataColumn(label: Text('หมายเหตุ')),
                        ],
                        rows: combinedData.map((inspection) {
                          return DataRow(cells: [
                            DataCell(Text(inspection['tank_id']?.toString() ??
                                'N/A')), // ใช้ .toString()
                            DataCell(Text(
                                inspection['building']?.toString() ?? 'N/A')),
                            DataCell(
                                Text(inspection['floor']?.toString() ?? 'N/A')),
                            DataCell(Text(
                                inspection['date_checked'] is Timestamp
                                    ? (inspection['date_checked'] as Timestamp)
                                        .toDate()
                                        .toString()
                                    : inspection['date_checked']?.toString() ??
                                        'N/A')),
                            DataCell(Text(
                                inspection['inspector']?.toString() ?? 'N/A')),
                            DataCell(Text(
                                inspection['user_type']?.toString() ?? 'N/A')),
                            DataCell(Text(
                                inspection['equipment_status']?.toString() ??
                                    'N/A')),
                            DataCell(Text(
                                inspection['remarks']?.toString() ?? 'N/A')),
                          ]);
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
