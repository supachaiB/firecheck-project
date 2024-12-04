import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // สำหรับเปิด URL

class QRCodePage extends StatelessWidget {
  QRCodePage({super.key}); // ลบ const ออกจากคอนสตรักเตอร์

  // รายการ Tank IDs ที่ต้องการสร้าง QR Code
  final List<String> tankIds = ['fire001', 'fire002', 'fire003'];

  // ฟังก์ชันในการเปิด URL
  Future<void> _launchURL(String tankId) async {
    final url = 'https://fire-check-db.web.app/user?tankId=$tankId';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'ไม่สามารถเปิด URL ได้';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Codes for Fire Tanks'),
        backgroundColor: Colors.deepPurple, // สีของแถบบน
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: tankIds.length,
          itemBuilder: (context, index) {
            final tankId = tankIds[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              elevation: 4, // เพิ่มเงาให้กับการ์ด
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // ทำมุมการ์ดให้กลม
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Tank: $tankId',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // QR Code
                    QrImageView(
                      data: 'https://fire-check-db.web.app/user?tankId=$tankId',
                      version: QrVersions.auto,
                      size: 200.0, // ขนาดของ QR Code
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    // URL ที่คลิกได้
                    InkWell(
                      onTap: () => _launchURL(tankId),
                      child: Text(
                        'https://fire-check-db.web.app/user?tankId=$tankId',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
