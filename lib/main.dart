import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EgxTrackerApp());
}

class EgxTrackerApp extends StatelessWidget {
  const EgxTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'متابع تداول الأسهم',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const DashboardScreen(),
    );
  }
}
