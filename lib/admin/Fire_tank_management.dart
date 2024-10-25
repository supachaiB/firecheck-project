import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireTankManagementPage extends StatelessWidget {
  const FireTankManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fire Tank Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'เลือกถังดับเพลิง',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('firetank_Collection')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('ยังไม่มีข้อมูลถังดับเพลิง'),
                  );
                }

                final tanks = snapshot.data!.docs;
                String? selectedTankId;

                return DropdownButton<String>(
                  hint: const Text('เลือกถัง'),
                  value: selectedTankId,
                  onChanged: (String? newValue) {
                    selectedTankId = newValue;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        var selectedTank = tanks.firstWhere(
                          (tank) => tank.id == selectedTankId,
                        );
                        return AlertDialog(
                          title: const Text('รายละเอียดถังดับเพลิง'),
                          content: Text(
                            'Tank ID: ${selectedTank['tank_id']}\n'
                            'Type: ${selectedTank['type']}\n'
                            'Building: ${selectedTank['building']}\n'
                            'Floor: ${selectedTank['floor']}',
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('ปิด'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  items: tanks
                      .map<DropdownMenuItem<String>>((DocumentSnapshot tank) {
                    return DropdownMenuItem<String>(
                      value: tank.id,
                      child: Text('ถัง: ${tank['tank_id']}'),
                    );
                  }).toList(),
                );
              },
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
  const FireTankFormPage({Key? key}) : super(key: key);

  @override
  _FireTankFormPageState createState() => _FireTankFormPageState();
}

class _FireTankFormPageState extends State<FireTankFormPage> {
  final TextEditingController _tankIdController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();

  // ฟังก์ชันบันทึกข้อมูลไปยัง Firestore
  Future<void> _saveFireTankData() async {
    try {
      await FirebaseFirestore.instance.collection('firetank_Collection').add({
        'tank_id': _tankIdController.text,
        'type': _typeController.text,
        'building': _buildingController.text,
        'floor': _floorController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกข้อมูลสำเร็จ')),
      );
      Navigator.pop(
          context); // กลับไปที่หน้าการจัดการถังดับเพลิงหลังจากบันทึกเสร็จ
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
        title: const Text('เพิ่มข้อมูลถังดับเพลิง'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tankIdController,
              decoration: const InputDecoration(labelText: 'Tank ID'),
            ),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            TextField(
              controller: _buildingController,
              decoration: const InputDecoration(labelText: 'Building'),
            ),
            TextField(
              controller: _floorController,
              decoration: const InputDecoration(labelText: 'Floor'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveFireTankData,
              child: const Text('บันทึกข้อมูล'),
            ),
          ],
        ),
      ),
    );
  }
}
