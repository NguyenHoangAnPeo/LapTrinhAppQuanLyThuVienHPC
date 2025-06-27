import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sach.dart';
import 'chi_tiet_sach_screen.dart';


class TrangSinhVien extends StatefulWidget {
  final String tenNguoiDung;
  const TrangSinhVien({super.key, required this.tenNguoiDung});

  @override
  State<TrangSinhVien> createState() => _TrangSinhVienState();
}

class _TrangSinhVienState extends State<TrangSinhVien> {
  int _indexHienTai = 0;
  List<Sach> _danhSachSach = [];
  List<Sach> _sachDaMuon = [];
  bool _dangTai = true;

  @override
  void initState() {
    super.initState();
    _taiDanhSachSach();
  }

  Future<void> _taiDanhSachSach() async {
    try {
      final res = await http.get(Uri.parse('http://10.0.2.2/thu_vien_api/LaySach.php'));
      if (res.statusCode == 200) {
        final List jsonList = jsonDecode(res.body);
        setState(() {
          _danhSachSach = jsonList.map((json) => Sach.fromJson(json)).toList();
          _dangTai = false;
        });
      } else {
        throw Exception('Lỗi khi tải sách');
      }
    } catch (e) {
      setState(() {
        _dangTai = false;
      });
      print('Lỗi tải sách: $e');
    }
  }

  Future<void> _taiSachDaMuon() async {
    try {
      final res = await http.post(
        Uri.parse('http://10.0.2.2/thu_vien_api/LaySachMuon.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'TaiKhoan': widget.tenNguoiDung}),
      );
      if (res.statusCode == 200) {
        final List jsonList = jsonDecode(res.body);
        setState(() {
          _sachDaMuon = jsonList.map((json) => Sach.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Lỗi tải sách đã mượn: $e');
    }
  }
  Widget _trangChu() {
    if (_dangTai) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_danhSachSach.isEmpty) {
      return const Center(child: Text('Không có sách nào.'));
    }

    return ListView.builder(
      itemCount: _danhSachSach.length,
      itemBuilder: (context, index) {
        final sach = _danhSachSach[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: Image.network(
                sach.hinhAnh!.startsWith('http')
                ? sach.hinhAnh!
                : 'http://10.0.2.2/thu_vien_api/${sach.hinhAnh!}', // nối đường dẫn đầy đủ
              width: 50,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 50),
            ),

            title: Text(sach.tenSach),
            subtitle: Text('Tác giả: ${sach.tacGia}\nCòn lại: ${sach.soLuongConLai}/${sach.soLuong}'),
            onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChiTietSachScreen(
                        sach: sach,
                        tenNguoiDung: widget.tenNguoiDung,
                      ),
                    ),
                  );
                },
          ),
        );
      },
    );
  }

  Widget _thuVien() {
    if (_sachDaMuon.isEmpty) {
      return const Center(child: Text('Chưa mượn sách nào.'));
    }
    return ListView.builder(
      itemCount: _sachDaMuon.length,
      itemBuilder: (context, index) {
        final sach = _sachDaMuon[index];
        return ListTile(
          leading: Icon(Icons.bookmark, color: Colors.green.shade300),
          title: Text(sach.tenSach),
          subtitle: Text('Tác giả: ${sach.tacGia}'),
        );
      },
    );
  }

  Widget _nguoiDung() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 80, color: Colors.blueGrey),
          Text(widget.tenNguoiDung, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context); // Quay lại màn đăng nhập
            },
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _noiDung = [
      _trangChu(),
      _thuVien(),
      _nguoiDung(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue.shade400,
        actions: [
          Row(
            children: [
              Text(widget.tenNguoiDung, style: const TextStyle(color: Colors.white)),
              const SizedBox(width: 8),
              const Icon(Icons.person, color: Colors.white),
              const SizedBox(width: 12),
            ],
          )
        ],
      ),
      body: _noiDung[_indexHienTai],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexHienTai,
        onTap: (index) {
          setState(() {
            _indexHienTai = index;
          });
          if (index == 1) {
            _taiSachDaMuon();
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Thư viện'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Người dùng'),
        ],
        selectedItemColor: Colors.blueAccent,
      ),
    );
  }
}
