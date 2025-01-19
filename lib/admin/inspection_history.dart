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
  String? sortBy = 'tank_number'; // เริ่มต้นการเรียงตามหมายเลขถัง

  // ฟังก์ชันสำหรับการแก้ไขสถานะการตรวจสอบ
  Future<void> _updateStatus(String tankId, String newStatus) async {
    try {
      // ค้นหาถังที่มี tank_id ตรงกับที่ระบุ
      var docSnapshot = await FirebaseFirestore.instance
          .collection('firetank_Collection')
          .where('tank_id', isEqualTo: tankId) // ค้นหาจากฟิลด์ tank_id
          .get();

      if (docSnapshot.docs.isNotEmpty) {
        // ถ้ามีข้อมูลตรงกับ tank_id
        var docRef = docSnapshot.docs.first.reference;
        // อัปเดตสถานะใน firetank_Collection
        await docRef.update({'status': newStatus});

        // อัปเดตสถานะใน form_checks
        await FirebaseFirestore.instance
            .collection('form_checks')
            .where('tank_id', isEqualTo: tankId)
            .get()
            .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.update({'status': newStatus});
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('สถานะการตรวจสอบได้รับการอัปเดต')));
      } else {
        throw Exception('ไม่พบถังที่มี tank_id: $tankId');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

  Future<void> _deleteTank(String tankId) async {
    try {
      // ลบจาก firetank_Collection
      var firetankDocs = await FirebaseFirestore.instance
          .collection('firetank_Collection')
          .where('tank_id', isEqualTo: tankId)
          .get();
      for (var doc in firetankDocs.docs) {
        await doc.reference.delete();
      }

      // ลบจาก form_checks
      var formCheckDocs = await FirebaseFirestore.instance
          .collection('form_checks')
          .where('tank_id', isEqualTo: tankId)
          .get();
      for (var doc in formCheckDocs.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบถังและข้อมูลการตรวจสอบเรียบร้อย')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

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
                        .orderBy('date_checked',
                            descending: true) // เรียงจากวันที่ล่าสุด

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

// ดึงข้อมูลล่าสุดสำหรับ tank_id แต่ละรายการ
                      Map<String, Map<String, dynamic>> latestFormChecks = {};
                      for (var doc in formChecksSnapshot.data!.docs) {
                        Map<String, dynamic> data =
                            doc.data() as Map<String, dynamic>;
                        String tankId = data['tank_id'] ?? 'N/A';

                        // เก็บข้อมูลล่าสุดของแต่ละ tank_id
                        if (!latestFormChecks.containsKey(tankId)) {
                          latestFormChecks[tankId] = data;
                        }
                      }
                      List<Map<String, dynamic>> formChecksData =
                          formChecksSnapshot.data!.docs
                              .map((doc) => doc.data() as Map<String, dynamic>)
                              .toList();

                      // รวมข้อมูลจากทั้งสอง collection โดยใช้วันที่ตรวจสอบล่าสุด
                      List<Map<String, dynamic>> combinedData =
                          firetankData.map((firetank) {
                        String tankId = firetank['tank_id'] ?? 'N/A';

                        // หา form_check ที่มี date_checked ล่าสุดและ tank_id ตรงกัน
                        var relevantFormChecks = formChecksData
                            .where((check) => check['tank_id'] == tankId);
                        var latestFormCheck = relevantFormChecks.isNotEmpty
                            ? relevantFormChecks.reduce((a, b) {
                                DateTime dateA =
                                    DateTime.tryParse(a['date_checked']) ??
                                        DateTime.fromMillisecondsSinceEpoch(0);
                                DateTime dateB =
                                    DateTime.tryParse(b['date_checked']) ??
                                        DateTime.fromMillisecondsSinceEpoch(0);
                                return dateA.isAfter(dateB) ? a : b;
                              })
                            : {
                                'date_checked': 'N/A',
                                'inspector': 'N/A',
                                'user_type': 'N/A',
                                'status': 'N/A',
                                'remarks': 'N/A'
                              };

                        return {
                          'tank_id': tankId,
                          'building': firetank['building']?.toString() ??
                              'N/A', // แปลงเป็น String
                          'floor': firetank['floor']?.toString() ??
                              'N/A', // แปลงเป็น String
                          'date_checked':
                              latestFormCheck['date_checked']?.toString() ??
                                  'N/A', // แปลงเป็น String
                          'inspector':
                              latestFormCheck['inspector']?.toString() ??
                                  'N/A', // แปลงเป็น String
                          'user_type':
                              latestFormCheck['user_type']?.toString() ??
                                  'N/A', // แปลงเป็น String
                          'status': firetank['status']?.toString() ??
                              'N/A', // แปลงเป็น String
                          'remarks': latestFormCheck['remarks']?.toString() ??
                              'N/A', // แปลงเป็น String
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
                          return inspection['status'] == selectedStatus;
                        }).toList();
                      }

                      // การจัดเรียงข้อมูล
                      if (sortBy == 'tank_number') {
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
                          DataColumn(
                              label: Text('การกระทำ')), // เพิ่มคอลัมน์การกระทำ
                        ],
                        rows: combinedData.map((inspection) {
                          Color statusColor = Colors.grey; // ค่าเริ่มต้นสีเทา

                          if (inspection['status'] == 'ตรวจสอบแล้ว') {
                            statusColor = Colors.green;
                          } else if (inspection['status'] == 'ชำรุด') {
                            statusColor = Colors.red;
                          } else if (inspection['status'] == 'ส่งซ่อม') {
                            statusColor = Colors.orange;
                          }

                          return DataRow(cells: [
                            DataCell(Text(inspection['tank_id']?.toString() ??
                                'N/A')), // ใช้ .toString()
                            DataCell(Text(
                                inspection['building']?.toString() ?? 'N/A')),
                            DataCell(
                                Text(inspection['floor']?.toString() ?? 'N/A')),
                            DataCell(Text(
                                inspection['date_checked']?.toString() ??
                                    'N/A')),
                            DataCell(Text(
                                inspection['inspector']?.toString() ?? 'N/A')),
                            DataCell(Text(
                                inspection['user_type']?.toString() ?? 'N/A')),
                            DataCell(
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color:
                                          inspection['status'] == 'ตรวจสอบแล้ว'
                                              ? Colors.green
                                              : inspection['status'] == 'ชำรุด'
                                                  ? Colors.red
                                                  : inspection['status'] ==
                                                          'ส่งซ่อม'
                                                      ? Colors.orange
                                                      : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(inspection['status']?.toString() ??
                                      'N/A'), // ใช้ text จาก field status
                                ],
                              ),
                            ),
                            DataCell(Text(
                                inspection['remarks']?.toString() ?? 'N/A')),
                            DataCell(
                              // คอลัมน์การกระทำ
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _showStatusDialog(
                                          inspection['tank_id'] ?? '',
                                          inspection['status'] ?? '');
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      _deleteTank(inspection['tank_id'] ?? '');
                                    },
                                  ),
                                ],
                              ),
                            ),
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

  // Dialog ให้ผู้ใช้เลือกสถานะใหม่
  void _showStatusDialog(String tankId, String currentStatus) {
    String? newStatus = currentStatus;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('เลือกสถานะใหม่'),
          content: DropdownButton<String>(
            value: newStatus,
            isExpanded: true,
            items: ['ตรวจสอบแล้ว', 'ส่งซ่อม', 'ชำรุด', 'ยังไม่ตรวจสอบ']
                .map((status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                newStatus = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                // ตรวจสอบว่า newStatus ไม่เป็น null ก่อนบันทึก
                if (newStatus != null) {
                  _updateStatus(
                      tankId, newStatus!); // เพิ่ม ! เพื่อบอกว่าไม่เป็น null
                  Navigator.pop(context);
                } else {
                  // จัดการกรณีที่ newStatus เป็น null
                  // เช่น แสดงข้อความผิดพลาดหรือไม่ทำอะไร
                }
              },
              child: const Text('บันทึก'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('ยกเลิก'),
            ),
          ],
        );
      },
    );
  }
}
