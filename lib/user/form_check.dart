import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // สำหรับฟอร์แมตวันที่
import 'package:cloud_firestore/cloud_firestore.dart'; // สำหรับ Firestore
import 'firetank_details.dart'; // นำเข้าไฟล์ที่แสดงประวัติการตรวจสอบ

class FormCheckPage extends StatefulWidget {
  final String tankId; // เพิ่มพารามิเตอร์ ID ของถัง

  const FormCheckPage({Key? key, required this.tankId}) : super(key: key);

  @override
  _FormCheckPageState createState() => _FormCheckPageState();
}

class _FormCheckPageState extends State<FormCheckPage> {
  final TextEditingController _dateController = TextEditingController();
  final Map<String, String> equipmentStatus = {
    'สายวัด': 'ปกติ',
    'คันบังคับ': 'ปกติ',
    'ตัวถัง': 'ปกติ',
    'มาตรวัด/น้ำหนัก': 'ปกติ',
  };
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _inspectorController = TextEditingController();
  List<String> staffList = []; // ตัวอย่างรายชื่อพนักงาน
  List<String> filteredStaffList = []; // รายชื่อพนักงานที่ตรงกัน
  String? selectedStaff; // ชื่อพนักงานที่ถูกเลือก
  String? userType; // ประเภทผู้ใช้ที่เลือก

  @override
  void initState() {
    super.initState();
    filteredStaffList = staffList; // แสดงรายชื่อพนักงานเริ่มต้น
    _dateController.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now()); // วันที่ปัจจุบัน
  }

  void _filterStaff(String query) {
    setState(() {
      filteredStaffList = staffList
          .where((staff) => staff.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> saveDataToFirestore() async {
    CollectionReference formChecks =
        FirebaseFirestore.instance.collection('form_checks');

    // สร้าง ID เอกสารโดยใช้วันที่และชื่อผู้ตรวจสอบ
    String docId =
        '${_dateController.text}_${widget.tankId}_${_inspectorController.text}';

    await formChecks.doc(docId).set({
      'date_checked': _dateController.text,
      'inspector': selectedStaff ?? _inspectorController.text,
      'user_type': userType, // บันทึกประเภทผู้ใช้
      'equipment_status': equipmentStatus,
      'remarks': _remarkController.text,
      'tank_id': widget.tankId, // บันทึก ID ถัง
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อยแล้ว')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Check'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // กล่องแรก - วันที่ตรวจสอบล่าสุด, สถานะ, ดูทั้งหมด
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('วันที่ตรวจสอบล่าสุด: 2024-10-04 เวลา 09:00'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Text('สถานะ: '),
                            Icon(Icons.circle, color: Colors.green, size: 12),
                            SizedBox(width: 8),
                            Text('ตรวจสอบแล้ว'),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FireTankDetailsPage(
                                    tankId: widget
                                        .tankId), // ส่ง tankId ไปหน้า FireTankDetailsPage
                              ),
                            );
                          },
                          child: const Text('ดูทั้งหมด'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // เพิ่มการแสดง Tank ID
            Text('Tank ID: ${widget.tankId}'), // แสดง Tank ID ที่รับมา

            // กล่องสอง - กรอกวันที่, รายการตรวจสอบ
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'วันที่ตรวจสอบ',
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    const Text('รายการตรวจสอบ'),
                    Column(
                      children: equipmentStatus.keys.map((String key) {
                        return ListTile(
                          title: Text(key),
                          subtitle: Row(
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: equipmentStatus[key] == 'ปกติ',
                                    onChanged: (bool? value) {
                                      setState(() {
                                        equipmentStatus[key] =
                                            value! ? 'ปกติ' : 'ชำรุด';
                                      });
                                    },
                                  ),
                                  const Text('ปกติ'),
                                ],
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    value: equipmentStatus[key] == 'ชำรุด',
                                    onChanged: (bool? value) {
                                      setState(() {
                                        equipmentStatus[key] =
                                            value! ? 'ชำรุด' : 'ปกติ';
                                      });
                                    },
                                  ),
                                  const Text('ชำรุด'),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text('ผู้ตรวจสอบ'),
                    TextField(
                      controller: _inspectorController,
                      onChanged: _filterStaff,
                      decoration: const InputDecoration(),
                    ),
                    if (filteredStaffList.isNotEmpty)
                      Container(
                        height: 100,
                        child: ListView.builder(
                          itemCount: filteredStaffList.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(filteredStaffList[index]),
                              onTap: () {
                                setState(() {
                                  selectedStaff = filteredStaffList[index];
                                  _inspectorController.text = selectedStaff!;
                                  filteredStaffList.clear();
                                });
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 20),

                    // ประเภทผู้ใช้ dropdown
                    const Text('ประเภทผู้ใช้'),
                    DropdownButton<String>(
                      value: userType,
                      items: [
                        DropdownMenuItem(
                          value: 'ผู้ใช้ทั่วไป',
                          child: Text('ผู้ใช้ทั่วไป'),
                        ),
                        DropdownMenuItem(
                          value: 'ช่างเทคนิค',
                          child: Text('ช่างเทคนิค'),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          userType = newValue;
                        });
                      },
                      hint: const Text('เลือกประเภทผู้ใช้'),
                    ),

                    const SizedBox(height: 20),

                    // ปุ่มถ่ายภาพ
                    ElevatedButton.icon(
                      onPressed: () {
                        // Placeholder for future photo capture functionality
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('ถ่ายภาพ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Updated parameter name
                      ),
                    ),

                    const SizedBox(height: 20),
                    TextField(
                      controller: _remarkController,
                      decoration: const InputDecoration(
                        labelText: 'หมายเหตุ',
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        saveDataToFirestore();
                      },
                      child: const Text('บันทึก'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
