import 'package:http/http.dart' as http;
import 'dart:convert';

class MuonSachService {
  static Future<bool> muonSach(String taiKhoan, int maSach) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2/thu_vien_api/MuonSach.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'TaiKhoan': taiKhoan,
        'MaSach': maSach,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['thanhCong'] == true;
    } else {
      return false;
    }
  }
}
