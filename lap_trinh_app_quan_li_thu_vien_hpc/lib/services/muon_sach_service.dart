import 'dart:convert';
import 'package:http/http.dart' as http;

class MuonSachService {
  static Future<Map<String, dynamic>> muonSach({
    required int maNguoiDung,
    required int maSach,
    required DateTime ngayMuon,
    required DateTime ngayTra,
  }) async {
    final uri = Uri.parse('http://10.0.2.2/thu_vien_api/MuonSach.php');

    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'MaNguoiDung': maNguoiDung,
          'MaSach': maSach,
          'NgayMuon': ngayMuon.toIso8601String().split('T').first,
          'NgayTra': ngayTra.toIso8601String().split('T').first,
        }),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return {
          'thanhCong': false,
          'thongBao': 'Lỗi kết nối máy chủ (status: ${res.statusCode})'
        };
      }
    } catch (e) {
      return {
        'thanhCong': false,
        'thongBao': 'Lỗi: $e',
      };
    }
  }
}
