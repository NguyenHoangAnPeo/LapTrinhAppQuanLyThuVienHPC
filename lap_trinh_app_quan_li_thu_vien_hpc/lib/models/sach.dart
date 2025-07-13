class Sach {
  final int maSach;
  final String tenSach;
  final String tacGia;
  final int soLuong;
  final int soLuongConLai;
  final double gia; // mới thêm
  final String? hinhAnh;

  Sach({
    required this.maSach,
    required this.tenSach,
    required this.tacGia,
    required this.soLuong,
    required this.soLuongConLai,
    required this.gia,
    this.hinhAnh,
  });

  factory Sach.fromJson(Map<String, dynamic> json) {
    return Sach(
      maSach: int.parse(json['MaSach']),
      tenSach: json['TenSach'],
      tacGia: json['TacGia'],
      soLuong: int.parse(json['SoLuong']),
      soLuongConLai: int.parse(json['SoLuongConLai']),
      gia: double.parse(json['Gia'] ?? '0'),
      hinhAnh: json['HinhAnh'],
    );
  }
}
