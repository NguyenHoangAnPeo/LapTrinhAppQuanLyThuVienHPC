import 'package:flutter/material.dart';
import 'screens/dang_nhap_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Thư Viện',
      debugShowCheckedModeBanner: false,
      home: const DangNhapScreen(), // Gọi màn hình đăng nhập
    );
  }
}
