<?php
require 'db.php';
header("Content-Type: application/json");

$data = json_decode(file_get_contents("php://input"));
$maSach = $data->MaSach;
$tenSach = $data->TenSach;
$tacGia = $data->TacGia;
$soLuong = $data->SoLuong;
$soLuongConLai = $data->SoLuongConLai;

$sql = "UPDATE Sach 
        SET TenSach='$tenSach', TacGia='$tacGia', SoLuong=$soLuong, SoLuongConLai=$soLuongConLai 
        WHERE MaSach = $maSach";

if ($conn->query($sql)) {
    echo json_encode(["thanhCong" => true, "thongBao" => "Sửa sách thành công"]);
} else {
    echo json_encode(["thanhCong" => false, "thongBao" => "Lỗi: " . $conn->error]);
}
?>
