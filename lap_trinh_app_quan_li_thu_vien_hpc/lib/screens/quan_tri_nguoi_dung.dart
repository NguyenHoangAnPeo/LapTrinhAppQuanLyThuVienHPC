import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class QuanTriNguoiDung extends StatefulWidget {
  const QuanTriNguoiDung({super.key});

  @override
  State<QuanTriNguoiDung> createState() => _QuanTriNguoiDungState();
}

class _QuanTriNguoiDungState extends State<QuanTriNguoiDung> {
  List<Map<String, dynamic>> _danhSachNguoiDung = [];
  bool _dangTai = true;

  @override
  void initState() {
    super.initState();
    _taiDanhSachNguoiDung();
  }

  Future<void> _taiDanhSachNguoiDung() async {
    setState(() => _dangTai = true);
    try {
      final res = await http.get(Uri.parse('http://10.0.2.2/thu_vien_api/LayTatCaNguoiDung.php'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _danhSachNguoiDung = List<Map<String, dynamic>>.from(data);
          _dangTai = false;
        });
      }
    } catch (e) {
      print('❌ Lỗi tải người dùng: $e');
      setState(() => _dangTai = false);
    }
  }

  Future<void> _xoaNguoiDung(int maNguoiDung) async {
    final res = await http.post(
      Uri.parse('http://10.0.2.2/thu_vien_api/XoaNguoiDung.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'MaNguoiDung': maNguoiDung}),
    );

    final data = jsonDecode(res.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['thongBao'] ?? 'Lỗi')),
    );
    if (data['thanhCong'] == true) _taiDanhSachNguoiDung();
  }

  void _xacNhanXoaNguoiDung(int maNguoiDung) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá người dùng'),
        content: Text('Bạn có chắc muốn xoá người dùng #$maNguoiDung không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _xoaNguoiDung(maNguoiDung);
            },
            child: const Text('Xoá', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  void _hienThiHopThoaiSuaNguoiDung(Map<String, dynamic> nguoiDung) {
  final _tkController = TextEditingController(text: nguoiDung['TaiKhoan']);
  final _mkController = TextEditingController(text: nguoiDung['MatKhau']);
  final _vaiTroController = TextEditingController(text: nguoiDung['VaiTro']);

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Sửa người dùng'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _tkController,
            decoration: const InputDecoration(labelText: 'Tài khoản'),
          ),
          TextField(
            controller: _mkController,
            decoration: const InputDecoration(labelText: 'Mật khẩu'),
            obscureText: true,
          ),
          TextField(
            controller: _vaiTroController,
            decoration: const InputDecoration(labelText: 'Vai trò'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ'),
        ),
        TextButton(
          onPressed: () async {
            final maNguoiDung = int.parse(nguoiDung['MaNguoiDung'].toString());
            final taiKhoan = _tkController.text.trim();
            final matKhau = _mkController.text.trim();
            final vaiTro = _vaiTroController.text.trim();

            if (taiKhoan.isEmpty || matKhau.isEmpty || vaiTro.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('⚠️ Vui lòng nhập đầy đủ thông tin')),
              );
              return;
            }

            Navigator.pop(context);

            final res = await http.post(
              Uri.parse('http://10.0.2.2/thu_vien_api/SuaNguoiDung.php'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'MaNguoiDung': maNguoiDung,
                'TaiKhoan': taiKhoan,
                'MatKhau': matKhau,
                'VaiTro': vaiTro,
              }),
            );

            final data = jsonDecode(res.body);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['thongBao'] ?? '')),
            );

            if (data['thanhCong'] == true) _taiDanhSachNguoiDung();
          },
          child: const Text('Lưu'),
        ),
      ],
    ),
  );
}

  void _hienThiHopThoaiThemNguoiDung() {
    final _tkController = TextEditingController();
    final _mkController = TextEditingController();
    final _vaiTroController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thêm người dùng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tkController,
              decoration: const InputDecoration(labelText: 'Tài khoản'),
            ),
            TextField(
              controller: _mkController,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            TextField(
              controller: _vaiTroController,
              decoration: const InputDecoration(labelText: 'Vai trò (vd: admin, sinhvien)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () async {
              final taiKhoan = _tkController.text.trim();
              final matKhau = _mkController.text.trim();
              final vaiTro = _vaiTroController.text.trim();

              if (taiKhoan.isEmpty || matKhau.isEmpty || vaiTro.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('⚠️ Vui lòng nhập đầy đủ thông tin')),
                );
                return;
              }

              Navigator.pop(context);

              final res = await http.post(
                Uri.parse('http://10.0.2.2/thu_vien_api/ThemNguoiDung.php'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'TaiKhoan': taiKhoan,
                  'MatKhau': matKhau,
                  'VaiTro': vaiTro,
                }),
              );

              final data = jsonDecode(res.body);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(data['thongBao'] ?? '')),
              );

              if (data['thanhCong'] == true) _taiDanhSachNguoiDung();
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
      ),
      body: _dangTai
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _danhSachNguoiDung.length,
              itemBuilder: (context, index) {
                final nd = _danhSachNguoiDung[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text('Tài khoản: ${nd['TaiKhoan']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mật khẩu: ${nd['MatKhau'] ?? '********'}'),
                        Text('Vai trò: ${nd['VaiTro']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _hienThiHopThoaiSuaNguoiDung(nd),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _xacNhanXoaNguoiDung(int.parse(nd['MaNguoiDung'].toString())),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _hienThiHopThoaiThemNguoiDung,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
