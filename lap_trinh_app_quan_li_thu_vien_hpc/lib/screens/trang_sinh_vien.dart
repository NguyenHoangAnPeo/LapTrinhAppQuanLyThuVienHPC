import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sach.dart';
import 'chi_tiet_sach_screen.dart';
import 'package:intl/intl.dart';
import 'thu_vien_screen.dart';
import 'dang_nhap_screen.dart';

class TrangSinhVien extends StatefulWidget {
  final String tenNguoiDung;
  final int maNguoiDung;
  

  const TrangSinhVien({
    super.key,
    required this.tenNguoiDung,
    required this.maNguoiDung,
  });

  @override
  State<TrangSinhVien> createState() => _TrangSinhVienState();
}

class _TrangSinhVienState extends State<TrangSinhVien> {
  String _tuKhoa = '';
  List<Sach> _danhSachLoc = [];
  int _indexHienTai = 0;
  List<Sach> _danhSachSach = [];
  bool _dangTai = true;

  final _formatDate = DateFormat('dd/MM/yyyy');

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
          _danhSachLoc = _danhSachSach;
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

 Widget _trangChu() {
  if (_dangTai) {
    return const Center(child: CircularProgressIndicator());
  }

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Tìm sách theo tên...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (value) {
            setState(() {
              _tuKhoa = value.toLowerCase();
              _danhSachLoc = _danhSachSach.where((sach) {
                return sach.tenSach.toLowerCase().contains(_tuKhoa);
              }).toList();
            });
          },
        ),
      ),
      Expanded(
        child: _danhSachLoc.isEmpty
            ? const Center(child: Text('Không tìm thấy sách phù hợp.'))
            : ListView.builder(
                itemCount: _danhSachLoc.length,
                itemBuilder: (context, index) {
                  final sach = _danhSachLoc[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: sach.hinhAnh == null
                            ? const Icon(Icons.broken_image, size: 48)
                            : Image.network(
                                sach.hinhAnh!.startsWith('http')
                                    ? sach.hinhAnh!
                                    : 'http://10.0.2.2/thu_vien_api/${sach.hinhAnh!}',
                                width: 50,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                              ),
                      ),
                      title: Text(sach.tenSach,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tác giả: ${sach.tacGia}'),
                          Text('Còn lại: ${sach.soLuongConLai}/${sach.soLuong}'),
                        ],
                      ),
                      onTap: () async {
                        final ketQua = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChiTietSachScreen(
                              sach: sach,
                              tenNguoiDung: widget.tenNguoiDung,
                              maNguoiDung: widget.maNguoiDung,
                            ),
                          ),
                        );

                        if (ketQua == true) {
                          await _taiDanhSachSach();
                          setState(() {
                            _indexHienTai = 1;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
      )
    ],
  );
}
  Widget _nguoiDung() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.account_circle, size: 80, color: Colors.blueGrey),
        Text(widget.tenNguoiDung, style: const TextStyle(fontSize: 18)),
        Text('Mã người dùng: ${widget.maNguoiDung}',
            style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const DangNhapScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 185, 182, 182),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
        )

      ],
    ),
  );
}

  List<Widget> get _noiDung => [
        _trangChu(),
        ThuVienScreen(maNguoiDung: widget.maNguoiDung),
        _nguoiDung(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Trang chủ', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.indigo,
          elevation: 4,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text(widget.tenNguoiDung,
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(width: 8),
                  const Icon(Icons.person, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      body: _noiDung[_indexHienTai],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexHienTai,
        onTap: (index) {
          setState(() {
            _indexHienTai = index;
          });
        },
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 14,
        unselectedFontSize: 13,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Thư viện'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Người dùng'),
        ],
      ),
    );
  }
}
