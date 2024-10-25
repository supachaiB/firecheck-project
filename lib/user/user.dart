import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'form_check.dart'; // นำเข้าไฟล์ FormCheckPage
import 'package:firecheck_setup/admin/dashboard.dart';

// User page to handle logout or other user actions
class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Page'),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Text(
                'เมนู',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('หน้าแรก'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/user');
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Admin'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: const MyHomePage(
          title: 'หน้าแรก'), // เรียก MyHomePage ใน body ของ UserPage
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    List<String> tankIds = ["fire001", "fire002", "fire003", "fire004"];
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                'เมนู',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('หน้าแรก'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/user');
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Admin'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: tankIds.length,
          itemBuilder: (context, index) {
            String currentTankId = tankIds[index];
            return Column(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FormCheckPage(tankId: currentTankId),
                      ),
                    );
                  },
                  child: Text('ถัง $currentTankId'),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}

class FireTankDetailsPage extends StatelessWidget {
  final String tankId;

  const FireTankDetailsPage({Key? key, required this.tankId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FireTankDetails $tankId'),
      ),
      body: Center(
        child: Text('FireTankDetailsID: $tankId'),
      ),
    );
  }
}

class QRCodePage extends StatelessWidget {
  const QRCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: 'https://fire-check-db.web.app',
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 20),
            const Text('QR Code for Tank 1'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
