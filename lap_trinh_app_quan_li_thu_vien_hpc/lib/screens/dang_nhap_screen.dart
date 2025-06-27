import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'trang_sinh_vien.dart';
import 'dart:convert';

class DangNhapScreen extends StatefulWidget {
  const DangNhapScreen({super.key});

  @override
  State<DangNhapScreen> createState() => _DangNhapScreenState();
}

class _DangNhapScreenState extends State<DangNhapScreen> {
  final TextEditingController _taiKhoanController = TextEditingController();
  final TextEditingController _matKhauController = TextEditingController();

  String? _thongBao;

  Future<void> _dangNhap() async {
  final taiKhoan = _taiKhoanController.text.trim();
  final matKhau = _matKhauController.text.trim();

  if (taiKhoan.isEmpty || matKhau.isEmpty) {
    setState(() {
      _thongBao = 'Vui lòng nhập tài khoản và mật khẩu.';
    });
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2/thu_vien_api/DangNhap.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'taiKhoan': taiKhoan,
        'matKhau': matKhau,
      }),
    );

    print('Phản hồi server: ${response.body}'); // ✅ In phản hồi ra terminal

    final data = jsonDecode(response.body);

    if (data['thanhCong']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TrangSinhVien(
            tenNguoiDung: data['tenNguoiDung'],
          ),
        ),
      );
    } else {
      setState(() {
        _thongBao = data['thongBao'];
      });
    }
  } catch (e) {
    setState(() {
      _thongBao = 'Lỗi kết nối đến máy chủ.';
    });
    print('Lỗi: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng Nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taiKhoanController,
              decoration: const InputDecoration(labelText: 'Tài khoản'),
            ),
            TextField(
              controller: _matKhauController,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _dangNhap,
              child: const Text('Đăng nhập'),
            ),
            const SizedBox(height: 20),
            Text(_thongBao ?? ''),
          ],
        ),
      ),
    );
  }
}
