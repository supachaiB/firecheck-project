import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireTankManagementPage extends StatefulWidget {
  const FireTankManagementPage({Key? key}) : super(key: key);

  @override
  _FireTankManagementPageState createState() => _FireTankManagementPageState();
}

class _FireTankManagementPageState extends State<FireTankManagementPage> {
  String? _selectedBuilding;
  String? _selectedFloor;
  String? _selectedType;
  String _searchTankId = '';

  final List<String> _buildings = [
    '10 ชั้น',
    'หลวงปู่ขาว',
    'OPD',
    '114 เตียง',
    'NSU',
    '60 เตียง',
    'เมตตา',
    'โภชนาศาสตร์',
    'จิตเวช',
    'กายภาพ&ธนาคารเลือด',
    'พัฒนากระตุ้นเด็ก',
    'จ่ายกลาง',
    'ซักฟอก',
    'ผลิตงาน & โรงงานช่าง',
  ]; // ตัวอย่างข้อมูลอาคาร
  final List<String> _floors = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11'
  ]; // ตัวอย่างข้อมูลชั้น
  final List<String> _types = [
    'ผงเคมีแห้ง',
    'co2',
    'bf2000'
  ]; // ตัวอย่างข้อมูลประเภท

  // ฟังก์ชันแสดงการยืนยันการลบ
  void _confirmDelete(BuildContext context, String tankId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณแน่ใจหรือไม่ว่าต้องการลบถังดับเพลิงนี้?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('firetank_Collection')
                  .doc(tankId)
                  .delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ลบข้อมูลสำเร็จ')),
              );
            },
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fire Tank Management'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // ตัวกรอง
            Row(
              children: [
                // ตัวกรองอาคาร
                Expanded(
                  child: DropdownButton<String>(
                    hint: const Text('เลือกอาคาร'),
                    value: _selectedBuilding,
                    onChanged: (value) {
                      setState(() {
                        _selectedBuilding = value;
                      });
                    },
                    items: _buildings
                        .map((building) => DropdownMenuItem<String>(
                              value: building,
                              child: Text(building),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 10),
                // ตัวกรองชั้น
                Expanded(
                  child: DropdownButton<String>(
                    hint: const Text('เลือกชั้น'),
                    value: _selectedFloor,
                    onChanged: (value) {
                      setState(() {
                        _selectedFloor = value;
                      });
                    },
                    items: _floors
                        .map((floor) => DropdownMenuItem<String>(
                              value: floor,
                              child: Text(floor),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 10),
                // ตัวกรองประเภท
                Expanded(
                  child: DropdownButton<String>(
                    hint: const Text('เลือกประเภท'),
                    value: _selectedType,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                    items: _types
                        .map((type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // **ปุ่มรีเซ็ตตัวกรอง**
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedBuilding = null;
                      _selectedFloor = null;
                      _selectedType = null;
                      _searchTankId = '';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 118, 36, 212), // สีของปุ่ม
                  ),
                  child: const Text('รีเซ็ตตัวกรองทั้งหมด'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ช่องค้นหา Tank ID
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchTankId = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'ค้นหาจาก Tank ID',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              ),
            ),
            const SizedBox(height: 10),
            // แสดงข้อมูลถังดับเพลิง
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('firetank_Collection')
                    .where(
                      'building',
                      isEqualTo: _selectedBuilding == null ||
                              _selectedBuilding!.isEmpty
                          ? null
                          : _selectedBuilding,
                    )
                    .where(
                      'floor',
                      isEqualTo:
                          _selectedFloor == null || _selectedFloor!.isEmpty
                              ? null
                              : _selectedFloor,
                    )
                    .where(
                      'type',
                      isEqualTo: _selectedType == null || _selectedType!.isEmpty
                          ? null
                          : _selectedType,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('กรุณากรองข้อมูลหรือค้นหาใหม่'),
                    );
                  }

                  // ฟิลเตอร์ Tank ID หลังจากดึงข้อมูลจาก Firebase
                  final tanks = snapshot.data!.docs.where((doc) {
                    final tankId = doc['tank_id'] as String;
                    return tankId.contains(_searchTankId);
                  }).toList();

                  if (tanks.isEmpty) {
                    return const Center(
                      child: Text('ไม่พบข้อมูลที่ตรงกับการค้นหา'),
                    );
                  }

                  return ListView.builder(
                    itemCount: tanks.length,
                    itemBuilder: (context, index) {
                      final tank = tanks[index];
                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text('Tank ID: ${tank['tank_id']}'),
                          subtitle: Text(
                            'Type: ${tank['type']}, Building: ${tank['building']}, Floor: ${tank['floor']}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FireTankFormPage(editTank: tank),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _confirmDelete(context, tank.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // นำทางไปยังฟอร์มเพิ่มข้อมูล
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FireTankFormPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}

class FireTankFormPage extends StatefulWidget {
  final QueryDocumentSnapshot<Object?>? editTank;

  const FireTankFormPage({Key? key, this.editTank}) : super(key: key);

  @override
  _FireTankFormPageState createState() => _FireTankFormPageState();
}

class _FireTankFormPageState extends State<FireTankFormPage> {
  final TextEditingController _tankIdController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.editTank != null) {
      _tankIdController.text = widget.editTank!['tank_id'];
      _typeController.text = widget.editTank!['type'];
      _buildingController.text = widget.editTank!['building'];
      _floorController.text = widget.editTank!['floor'];
    }
  }

  Future<void> _saveFireTankData() async {
    try {
      if (widget.editTank == null) {
        // เพิ่มข้อมูลใหม่
        await FirebaseFirestore.instance.collection('firetank_Collection').add({
          'tank_id': _tankIdController.text,
          'type': _typeController.text,
          'building': _buildingController.text,
          'floor': _floorController.text,
          'status': "",
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกข้อมูลสำเร็จ')),
        );
      } else {
        // แก้ไขข้อมูลเดิม
        await FirebaseFirestore.instance
            .collection('firetank_Collection')
            .doc(widget.editTank!.id)
            .update({
          'tank_id': _tankIdController.text,
          'type': _typeController.text,
          'building': _buildingController.text,
          'floor': _floorController.text,
          'status': "",
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('แก้ไขข้อมูลสำเร็จ')),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editTank == null
            ? 'เพิ่มข้อมูลถังดับเพลิง'
            : 'แก้ไขข้อมูลถังดับเพลิง'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _tankIdController,
              decoration: const InputDecoration(
                labelText: 'Tank ID',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _buildingController,
              decoration: const InputDecoration(
                labelText: 'Building',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _floorController,
              decoration: const InputDecoration(
                labelText: 'Floor',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveFireTankData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  widget.editTank == null ? 'บันทึก' : 'อัปเดต',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
