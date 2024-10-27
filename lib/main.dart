import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // นำเข้าหลังจากเพิ่ม url_strategy

import 'admin/inspection_history.dart';
import 'admin/dashboard.dart';
import 'admin/fire_tank_status.dart';
import 'user/user.dart';
import 'admin/Fire_tank_management.dart';
import 'admin/qr_code.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ตั้งค่า Path-based Routing เพื่อเอา # ออก
  setUrlStrategy(PathUrlStrategy());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firecheck System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
      routes: {
        // เพิ่ม route
        '/firetankstatus': (context) => FireTankStatusPage(),
        '/inspectionhistory': (context) => InspectionHistoryPage(),
        '/user': (context) => UserPage(),
        '/qr_code': (context) => QRCodePage(),
        '/fire_tank_management': (context) => FireTankManagementPage(),
      },
    );
  }
}
