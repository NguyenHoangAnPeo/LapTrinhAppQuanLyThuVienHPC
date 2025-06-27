import 'package:flutter/material.dart';
import '../models/sach.dart';
import '../services/muon_sach_service.dart';

class ChiTietSachScreen extends StatelessWidget {
  final Sach sach;
  final String tenNguoiDung;

  const ChiTietSachScreen({
    super.key,
    required this.sach,
    required this.tenNguoiDung,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết sách')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.network(
              sach.hinhAnh!.startsWith('http')
                ? sach.hinhAnh!
                : 'http://10.0.2.2/thu_vien_api/${sach.hinhAnh!}',
              height: 200,
              errorBuilder: (context, error, stack) => const Icon(Icons.image),
            ),
            const SizedBox(height: 16),
            Text(sach.tenSach, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Tác giả: ${sach.tacGia}'),
            const SizedBox(height: 8),
            Text('Còn lại: ${sach.soLuongConLai}/${sach.soLuong}'),
            const Spacer(),
            ElevatedButton.icon(
                onPressed: () async {
                  bool ketQua = await MuonSachService.muonSach(tenNguoiDung, sach.maSach);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ketQua ? 'Mượn sách thành công' : 'Không thể mượn sách')),
                  );

                  if (ketQua) Navigator.pop(context); // Quay lại nếu mượn thành công
                },
                icon: const Icon(Icons.library_add),
                label: const Text('Mượn sách'),
              )

          ],
        ),
      ),
    );
  }
}
