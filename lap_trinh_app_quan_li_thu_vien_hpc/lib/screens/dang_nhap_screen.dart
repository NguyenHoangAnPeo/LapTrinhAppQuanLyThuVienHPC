import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'trang_sinh_vien.dart';
import 'trang_quan_tri.dart';        // 👈 import trang quản trị
import 'dang_ki_screen.dart';
import 'dart:convert';

class DangNhapScreen extends StatefulWidget {
  const DangNhapScreen({super.key});

  @override
  State<DangNhapScreen> createState() => _DangNhapScreenState();
}

class _DangNhapScreenState extends State<DangNhapScreen> {
  final _taiKhoanController = TextEditingController();
  final _matKhauController = TextEditingController();
  String? _thongBao;

  Future<void> _dangNhap() async {
    final taiKhoan = _taiKhoanController.text.trim();
    final matKhau = _matKhauController.text.trim();

    if (taiKhoan.isEmpty || matKhau.isEmpty) {
      setState(() => _thongBao = 'Vui lòng nhập tài khoản và mật khẩu.');
      return;
    }

    try {
      final res = await http.post(
        Uri.parse('http://10.0.2.2/thu_vien_api/DangNhap.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'taiKhoan': taiKhoan, 'matKhau': matKhau}),
      );

      final data = jsonDecode(res.body);
      debugPrint('📥 Phản hồi: $data');

      if (data['thanhCong'] == true) {
        final int maNguoiDung = data['maNguoiDung'];
        final String vaiTro = data['vaiTro'] ?? 'SinhVien';
        final String tenNguoiDung = data['tenNguoiDung'] ?? taiKhoan;

        // Điều hướng theo vai trò
        if (vaiTro == 'QuanTriVien') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TrangQuanTri()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => TrangSinhVien(
                tenNguoiDung: tenNguoiDung,
                maNguoiDung: maNguoiDung,
              ),
            ),
          );
        }
      } else {
        setState(() => _thongBao = data['thongBao']);
      }
    } catch (e) {
      debugPrint('❌ Lỗi: $e');
      setState(() => _thongBao = 'Không kết nối được máy chủ.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('📚 Đăng Nhập Hệ Thống'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.lock_open, size: 80, color: Colors.lightBlue),
            const SizedBox(height: 20),
            TextField(
              controller: _taiKhoanController,
              decoration: const InputDecoration(
                labelText: 'Tài khoản',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _matKhauController,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _dangNhap,
              icon: const Icon(Icons.login),
              label: const Text('Đăng nhập'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 15),
            Text(_thongBao ?? '',
                style: const TextStyle(color: Colors.redAccent)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Chưa có tài khoản? '),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DangKyScreen()),
                    );
                  },
                  child: const Text('Đăng ký ngay'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
