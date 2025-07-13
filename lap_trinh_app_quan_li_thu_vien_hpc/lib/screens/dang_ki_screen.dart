import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DangKyScreen extends StatefulWidget {
  const DangKyScreen({super.key});

  @override
  State<DangKyScreen> createState() => _DangKyScreenState();
}

class _DangKyScreenState extends State<DangKyScreen> {
  final TextEditingController _taiKhoanController = TextEditingController();
  final TextEditingController _matKhauController = TextEditingController();
  String? _thongBao;

  Future<void> _dangKy() async {
    final taiKhoan = _taiKhoanController.text.trim();
    final matKhau = _matKhauController.text.trim();

    if (taiKhoan.isEmpty || matKhau.isEmpty) {
      setState(() {
        _thongBao = "Vui lòng nhập đầy đủ tài khoản và mật khẩu.";
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/thu_vien_api/DangKi.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'taiKhoan': taiKhoan,
          'matKhau': matKhau,
        }),
      );

      final data = jsonDecode(response.body);
      setState(() {
        _thongBao = data['thongBao'];
      });

      if (data['thanhCong']) {
        Navigator.pop(context); // Quay lại màn hình đăng nhập
      }
    } catch (e) {
      setState(() {
        _thongBao = "Lỗi kết nối đến máy chủ.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đăng Ký Tài Khoản"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.person_add, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            TextField(
              controller: _taiKhoanController,
              decoration: const InputDecoration(
                labelText: "Tài khoản",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _matKhauController,
              decoration: const InputDecoration(
                labelText: "Mật khẩu",
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _dangKy,
              icon: const Icon(Icons.app_registration),
              label: const Text("Đăng ký"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
            Text(_thongBao ?? '',
                style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
