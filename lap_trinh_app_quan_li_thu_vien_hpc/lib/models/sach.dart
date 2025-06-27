class Sach {
  final int maSach;
  final String tenSach;
  final String tacGia;
  final int soLuong;
  final int soLuongConLai;
  final String? hinhAnh; // Thêm dòng này

  Sach({
    required this.maSach,
    required this.tenSach,
    required this.tacGia,
    required this.soLuong,
    required this.soLuongConLai,
    this.hinhAnh, // Thêm dòng này
  });

  factory Sach.fromJson(Map<String, dynamic> json) {
    return Sach(
      maSach: int.parse(json['MaSach']),
      tenSach: json['TenSach'],
      tacGia: json['TacGia'],
      soLuong: int.parse(json['SoLuong']),
      soLuongConLai: int.parse(json['SoLuongConLai']),
      hinhAnh: json['HinhAnh'], // Thêm dòng này
    );
  }
}
