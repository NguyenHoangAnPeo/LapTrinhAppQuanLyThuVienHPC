import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ThuVienScreen extends StatefulWidget {
  final int maNguoiDung;

  const ThuVienScreen({super.key, required this.maNguoiDung});

  @override
  State<ThuVienScreen> createState() => _ThuVienScreenState();
}

class _ThuVienScreenState extends State<ThuVienScreen> {
  List<Map<String, dynamic>> _lichSuMuon = [];
  bool _dangTai = true;
  final _formatCurrency = NumberFormat('#,##0', 'vi_VN');

  @override
  void initState() {
    super.initState();
    print('📚 ThuVienScreen initState: đang tải lại lịch sử mượn'); // dòng test
    _taiLichSuMuon();
  }

 Future<void> _taiLichSuMuon() async {
  try {
    final res = await http.post(
      Uri.parse('http://10.0.2.2/thu_vien_api/LaySachMuon.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'MaNguoiDung': widget.maNguoiDung}),
    );

    print('📥 API trả về: ${res.body}');

    if (res.statusCode == 200) {
      final body = res.body.trim();

      // ✅ Nếu là rỗng hoặc không phải mảng, thì bỏ qua
      if (body.isEmpty || (!body.startsWith('[') && !body.startsWith('{'))) {
        print('❌ Dữ liệu trả về không hợp lệ');
        setState(() {
          _lichSuMuon = [];
          _dangTai = false;
        });
        return;
      }

      final List<dynamic> jsonList = jsonDecode(body);

      setState(() {
        _lichSuMuon = List<Map<String, dynamic>>.from(jsonList);
        _dangTai = false;
      });
    } else {
      print('❌ API lỗi: status ${res.statusCode}');
      setState(() => _dangTai = false);
    }
  } catch (e) {
    setState(() => _dangTai = false);
    print('❌ Lỗi tải lịch sử mượn: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    if (_dangTai) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_lichSuMuon.isEmpty) {
      return const Center(child: Text('Chưa mượn sách nào.'));
    }

    return ListView.builder(
      itemCount: _lichSuMuon.length,
      itemBuilder: (context, index) {
        final item = _lichSuMuon[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: Icon(Icons.book, color: Colors.blue.shade300),
            title: Text(item['TenSach'] ?? ''),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tác giả: ${item['TacGia'] ?? ''}'),
                Text('Ngày mượn: ${item['NgayMuon'] ?? ''}'),
                Text('Ngày trả: ${item['NgayTra'] ?? ''}'),
                Text('Tiền: ${_formatCurrency.format(int.tryParse(item['TienThanhToan'] ?? '0') ?? 0)}đ'),
              ],
            ),
            trailing: ElevatedButton(
                onPressed: () async {
                  final int maMuon = item['MaMuon'];

                  final res = await http.post(
                    Uri.parse('http://10.0.2.2/thu_vien_api/TraSach.php'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'MaMuon': maMuon}),
                  );

                  try {
                    final data = jsonDecode(res.body);
                    final thongBao = data['thongBao'] ?? 'Không rõ phản hồi';

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(data['thanhCong'] == true ? '✅ $thongBao' : '❌ $thongBao')),
                    );

                    if (data['thanhCong'] == true) {
                      _taiLichSuMuon(); // cập nhật lại danh sách
                    }
                  } catch (e) {
                    print('❌ Lỗi JSON: $e');
                    print('🧾 Phản hồi: ${res.body}');
                  }
                },
                child: const Text("Trả sách"),
              )
          ),
        );
      },
    );
  }
}
