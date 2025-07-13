import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'quan_tri_nguoi_dung.dart';


class TrangQuanTri extends StatefulWidget {
  const TrangQuanTri({super.key});

  @override
  State<TrangQuanTri> createState() => _TrangQuanTriState();
}

class _TrangQuanTriState extends State<TrangQuanTri> {
  List<Map<String, dynamic>> _danhSach = [];
  bool _dangTai = true;

  @override
  void initState() {
    super.initState();
    _taiDanhSachSach();
  }

  Future<void> _taiDanhSachSach() async {
    setState(() => _dangTai = true);
    try {
      final res = await http.get(Uri.parse('http://10.0.2.2/thu_vien_api/LayTatCaSach.php'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _danhSach = List<Map<String, dynamic>>.from(data);
          _dangTai = false;
        });
      }
    } catch (e) {
      print('❌ Lỗi tải sách: $e');
      setState(() => _dangTai = false);
    }
  }

  void _hienFormSach({Map<String, dynamic>? sach}) {
    final tenController = TextEditingController(text: sach?['TenSach'] ?? '');
    final tacGiaController = TextEditingController(text: sach?['TacGia'] ?? '');
    final soLuongController = TextEditingController(text: sach?['SoLuong']?.toString() ?? '');
    final soConLaiController = TextEditingController(text: sach?['SoLuongConLai']?.toString() ?? '');
    final giaController = TextEditingController(text: sach?['Gia']?.toString() ?? '');
    final hinhAnhController = TextEditingController(text: sach?['HinhAnh'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(sach == null ? 'Thêm sách mới' : 'Cập nhật sách'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: tenController, decoration: const InputDecoration(labelText: 'Tên sách')),
              TextField(controller: tacGiaController, decoration: const InputDecoration(labelText: 'Tác giả')),
              TextField(controller: soLuongController, decoration: const InputDecoration(labelText: 'Số lượng'), keyboardType: TextInputType.number),
              TextField(controller: soConLaiController, decoration: const InputDecoration(labelText: 'Số lượng còn lại'), keyboardType: TextInputType.number),
              TextField(controller: giaController, decoration: const InputDecoration(labelText: 'Giá'), keyboardType: TextInputType.number),
              TextField(controller: hinhAnhController, decoration: const InputDecoration(labelText: 'Đường dẫn hình ảnh')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final body = jsonEncode({
                'MaSach': sach?['MaSach'],
                'TenSach': tenController.text,
                'TacGia': tacGiaController.text,
                'SoLuong': int.tryParse(soLuongController.text) ?? 0,
                'SoLuongConLai': int.tryParse(soConLaiController.text) ?? 0,
                'Gia': double.tryParse(giaController.text) ?? 0,
                'HinhAnh': hinhAnhController.text,
              });

              final url = sach == null
                  ? 'http://10.0.2.2/thu_vien_api/ThemSach.php'
                  : 'http://10.0.2.2/thu_vien_api/CapNhatSach.php';

              final res = await http.post(
                Uri.parse(url),
                headers: {'Content-Type': 'application/json'},
                body: body,
              );

              final kq = jsonDecode(res.body);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(kq['thongBao'] ?? 'Lỗi không xác định')),
              );

              Navigator.pop(context);
              _taiDanhSachSach();
            },
            child: Text(sach == null ? 'Thêm' : 'Cập nhật'),
          ),
        ],
      ),
    );
  }

  Future<void> _xoaSach(int maSach) async {
    final res = await http.post(
      Uri.parse('http://10.0.2.2/thu_vien_api/XoaSach.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'MaSach': maSach}),
    );

    final kq = jsonDecode(res.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(kq['thongBao'] ?? 'Lỗi xoá')),
    );

    _taiDanhSachSach();
  }

  void _hienThongTinNguoiDung() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông tin người dùng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.admin_panel_settings, size: 60, color: Colors.blueGrey),
            SizedBox(height: 10),
            Text('👤 Bạn đang đăng nhập với tư cách: Quản trị viên'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text('Quản trị viên', style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Quản lý sách'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Quản lý người dùng'),
              onTap: () {
                Navigator.pop(context); // đóng drawer trước
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuanTriNguoiDung())
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Thống kê mượn trả'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("📊 Chưa triển khai")));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Đăng xuất'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Quản trị sách'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: _hienThongTinNguoiDung,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _hienFormSach(),
          ),
        ],
      ),
      body: _dangTai
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _danhSach.length,
              itemBuilder: (context, index) {
                final sach = _danhSach[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.book),
                    title: Text('${sach['TenSach']}'),
                    subtitle: Text('Tác giả: ${sach['TacGia']}\nCòn lại: ${sach['SoLuongConLai']}/${sach['SoLuong']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _hienFormSach(sach: sach),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Color.fromARGB(255, 201, 181, 180)),
                          onPressed: () => _xoaSach(sach['MaSach']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
