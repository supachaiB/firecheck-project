import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'admin/inspection_history.dart'; // Import ไฟล์ inspection_history.dart
import 'admin/dashboard.dart'; // Import ไฟล์ dashboard.dart
import 'admin/fire_tank_status.dart'; // Import ไฟล์ fire_tank_status.dart
import 'user/user.dart';
import 'admin/Fire_tank_management.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const DashboardPage(), // เปลี่ยนให้หน้าแรกเป็น DashboardPage
      routes: {
        // เพิ่ม route
        '/firetankstatus': (context) => FireTankStatusPage(),
        '/inspectionhistory': (context) => InspectionHistoryPage(),
        '/user': (context) => UserPage(),
        '/fire_tank_management': (context) => FireTankManagementPage(),
      },
    );
  }
}
