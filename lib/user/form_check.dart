import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // สำหรับฟอร์แมตวันที่
import 'package:cloud_firestore/cloud_firestore.dart'; // สำหรับ Firestore
import 'firetank_details.dart'; // นำเข้าไฟล์ที่แสดงประวัติการตรวจสอบ

class FormCheckPage extends StatefulWidget {
  final String tankId;

  const FormCheckPage({Key? key, required this.tankId}) : super(key: key);

  @override
  _FormCheckPageState createState() => _FormCheckPageState();
}

class _FormCheckPageState extends State<FormCheckPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final Map<String, String> equipmentStatus = {
    'สายวัด': 'ปกติ',
    'คันบังคับ': 'ปกติ',
    'ตัวถัง': 'ปกติ',
    'มาตรวัด/น้ำหนัก': 'ปกติ',
  };
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _inspectorController = TextEditingController();
  List<String> staffList = [];
  List<String> filteredStaffList = [];
  String? selectedStaff;
  String? userType;
  String? latestCheckDate; // สำหรับวันที่ตรวจสอบล่าสุด
  String? latestCheckTime; // สำหรับเวลา

  @override
  void initState() {
    super.initState();
    filteredStaffList = staffList;
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _timeController.text =
        DateFormat('HH:mm').format(DateTime.now()); // เวลาปัจจุบัน
    fetchLatestCheckDate(); // ดึงข้อมูลวันที่ล่าสุด
  }

  Future<void> fetchLatestCheckDate() async {
    CollectionReference formChecks =
        FirebaseFirestore.instance.collection('form_checks');

    try {
      QuerySnapshot querySnapshot = await formChecks
          .where('tank_id', isEqualTo: widget.tankId)
          .orderBy('date_checked', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // ดึงข้อมูลวันที่ตรวจสอบล่าสุดที่เป็น String
        String dateString = querySnapshot.docs.first['date_checked'];
        String timeString = querySnapshot.docs.first['time_checked'];

        setState(() {
          latestCheckDate = dateString; // วันที่
          latestCheckTime = timeString; // เวลา
        });
      } else {
        setState(() {
          latestCheckDate = 'ไม่มีข้อมูล';
          latestCheckTime = '';
        });
      }
    } catch (e) {
      print("Error fetching latest check date: $e");
      setState(() {
        latestCheckDate = 'เกิดข้อผิดพลาด';
        latestCheckTime = '';
      });
    }
  }

  void _filterStaff(String query) {
    setState(() {
      filteredStaffList = staffList
          .where((staff) => staff.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> saveDataToFirestore() async {
    // ตรวจสอบว่า date_checked, time_checked, equipment_status และ user_type ได้รับการกรอกหรือเลือก
    if (_dateController.text.isEmpty ||
        _timeController.text.isEmpty ||
        equipmentStatus.values.any((status) => status.isEmpty) ||
        userType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
      return; // หยุดการบันทึกข้อมูลถ้าข้อมูลไม่ครบ
    }

    CollectionReference formChecks =
        FirebaseFirestore.instance.collection('form_checks');

    String docId =
        '${_dateController.text}_${widget.tankId}_${_inspectorController.text}';

    try {
      await formChecks.doc(docId).set({
        'date_checked': _dateController.text,
        'time_checked': _timeController.text, // บันทึกเวลา
        'inspector': selectedStaff ?? _inspectorController.text,
        'user_type': userType,
        'equipment_status': equipmentStatus,
        'remarks': _remarkController.text,
        'tank_id': widget.tankId,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อยแล้ว')),
        );
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double fontSize = 16; // กำหนดฟอนต์แบบคงที่
    final EdgeInsets padding = const EdgeInsets.symmetric(vertical: 8.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Form Check',
          style: TextStyle(fontSize: fontSize * 1.2),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'วันที่ตรวจสอบล่าสุด: ${latestCheckDate ?? 'กำลังโหลด...'} ${latestCheckTime ?? ''}',
                      style: TextStyle(fontSize: fontSize),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'สถานะ: ',
                              style: TextStyle(fontSize: fontSize),
                            ),
                            Icon(Icons.circle, color: Colors.green, size: 12),
                            SizedBox(width: 8),
                            Text(
                              'ตรวจสอบแล้ว',
                              style: TextStyle(fontSize: fontSize),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FireTankDetailsPage(
                                  tankId: widget.tankId,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'ดูทั้งหมด',
                            style: TextStyle(fontSize: fontSize),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Tank ID: ${widget.tankId}',
              style: TextStyle(fontSize: fontSize),
            ),
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
                        labelStyle: TextStyle(fontSize: fontSize),
                      ),
                      readOnly: true,
                      style: TextStyle(fontSize: fontSize),
                    ),
                    TextField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        labelText: 'เวลา',
                        labelStyle: TextStyle(fontSize: fontSize),
                      ),
                      readOnly: true,
                      style: TextStyle(fontSize: fontSize),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'รายการตรวจสอบ',
                      style: TextStyle(fontSize: fontSize),
                    ),
                    Column(
                      children: equipmentStatus.keys.map((String key) {
                        return Padding(
                          padding: padding,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                key,
                                style: TextStyle(fontSize: fontSize),
                              ),
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
                                  Text(
                                    'ปกติ',
                                    style: TextStyle(fontSize: fontSize),
                                  ),
                                  Checkbox(
                                    value: equipmentStatus[key] == 'ชำรุด',
                                    onChanged: (bool? value) {
                                      setState(() {
                                        equipmentStatus[key] =
                                            value! ? 'ชำรุด' : 'ปกติ';
                                      });
                                    },
                                  ),
                                  Text(
                                    'ชำรุด',
                                    style: TextStyle(fontSize: fontSize),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _inspectorController,
                      onChanged: _filterStaff,
                      decoration: InputDecoration(
                        hintText: 'ผู้ตรวจสอบ',
                        hintStyle: TextStyle(fontSize: fontSize),
                      ),
                      style: TextStyle(fontSize: fontSize),
                    ),
                    if (filteredStaffList.isNotEmpty)
                      Container(
                        height: 100,
                        child: ListView.builder(
                          itemCount: filteredStaffList.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                filteredStaffList[index],
                                style: TextStyle(fontSize: fontSize),
                              ),
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
                    Text(
                      'ประเภทผู้ใช้',
                      style: TextStyle(fontSize: fontSize),
                    ),
                    DropdownButton<String>(
                      value: userType,
                      items: [
                        DropdownMenuItem(
                          value: 'ผู้ใช้ทั่วไป',
                          child: Text(
                            'ผู้ใช้ทั่วไป',
                            style: TextStyle(fontSize: fontSize),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'ช่างเทคนิค',
                          child: Text(
                            'ช่างเทคนิค',
                            style: TextStyle(fontSize: fontSize),
                          ),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          userType = newValue;
                        });
                      },
                      hint: Text(
                        'เลือกประเภทผู้ใช้',
                        style: TextStyle(fontSize: fontSize),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.camera_alt),
                      label: Text(
                        'ถ่ายภาพ',
                        style: TextStyle(fontSize: fontSize),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _remarkController,
                      decoration: InputDecoration(
                        labelText: 'หมายเหตุ',
                        labelStyle: TextStyle(fontSize: fontSize),
                      ),
                      style: TextStyle(fontSize: fontSize),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: saveDataToFirestore,
                      child: Text(
                        'บันทึก',
                        style: TextStyle(fontSize: fontSize),
                      ),
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
