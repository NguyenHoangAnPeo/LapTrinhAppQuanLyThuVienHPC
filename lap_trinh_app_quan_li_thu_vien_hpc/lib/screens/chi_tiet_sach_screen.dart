import 'package:flutter/material.dart';
import '../models/sach.dart';
import '../services/muon_sach_service.dart';
import 'package:intl/intl.dart';

class ChiTietSachScreen extends StatefulWidget {
  final Sach sach;
  final String tenNguoiDung;
  final int maNguoiDung;

  const ChiTietSachScreen({
    super.key,
    required this.sach,
    required this.tenNguoiDung,
    required this.maNguoiDung,
  });

  @override
  State<ChiTietSachScreen> createState() => _ChiTietSachScreenState();
}

class _ChiTietSachScreenState extends State<ChiTietSachScreen> {
  DateTime _ngayMuon = DateTime.now();
  DateTime _ngayTra = DateTime.now().add(const Duration(days: 7));
  int _soTien = 0;

  final _formatDate = DateFormat('dd/MM/yyyy');
  final _formatCurrency = NumberFormat("#,##0", "vi_VN");

  void _tinhTien() {
    final soNgay = _ngayTra.difference(_ngayMuon).inDays;
    setState(() {
      _soTien = (soNgay * widget.sach.gia).toInt();
    });
  }

  Future<void> _chonNgay(BuildContext context, bool laNgayMuon) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: laNgayMuon ? _ngayMuon : _ngayTra,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (laNgayMuon) {
          _ngayMuon = picked;
          if (_ngayTra.isBefore(_ngayMuon)) {
            _ngayTra = _ngayMuon.add(const Duration(days: 1));
          }
        } else {
          _ngayTra = picked;
        }
        _tinhTien();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tinhTien();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết sách')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Image.network(
                      widget.sach.hinhAnh != null && widget.sach.hinhAnh!.startsWith('http')
                          ? widget.sach.hinhAnh!
                          : 'http://10.0.2.2/thu_vien_api/${widget.sach.hinhAnh ?? ''}',
                      height: 150,
                      errorBuilder: (context, error, stack) =>
                          const Icon(Icons.image, size: 80),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.sach.tenSach,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 4),
                    Text('Tác giả: ${widget.sach.tacGia}'),
                    Text('Số lượng: ${widget.sach.soLuongConLai}/${widget.sach.soLuong}'),
                    Text('Giá thuê: ${_formatCurrency.format(widget.sach.gia)}đ/ngày'),
                    const SizedBox(height: 16),

                    // GIAO DIỆN NỔI BẬT PHẦN CHỌN NGÀY
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thời gian mượn',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.date_range, size: 20),
                              const SizedBox(width: 8),
                              const Text('Ngày mượn: '),
                              TextButton(
                                onPressed: () => _chonNgay(context, true),
                                child: Text(_formatDate.format(_ngayMuon)),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 8),
                              const Text('Ngày trả: '),
                              TextButton(
                                onPressed: () => _chonNgay(context, false),
                                child: Text(_formatDate.format(_ngayTra)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Số tiền cần thanh toán: ${_formatCurrency.format(_soTien)} đ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                final ketQua = await MuonSachService.muonSach(
                  maNguoiDung: widget.maNguoiDung,
                  maSach: widget.sach.maSach,
                  ngayMuon: _ngayMuon,
                  ngayTra: _ngayTra,
                );

                final thongBao = ketQua['thongBao'] ?? 'Không xác định';
                final thanhCong = ketQua['thanhCong'] == true;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(thongBao)),
                );

                if (thanhCong) {
                  Navigator.pop(context, true);
                }
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
