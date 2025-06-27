<?php
require 'db.php';
header("Content-Type: application/json");

$data = json_decode(file_get_contents("php://input"));
$tenSach = $data->TenSach;
$tacGia = $data->TacGia;
$soLuong = $data->SoLuong;

$sql = "INSERT INTO Sach (TenSach, TacGia, SoLuong, SoLuongConLai) 
        VALUES ('$tenSach', '$tacGia', $soLuong, $soLuong)";

if ($conn->query($sql)) {
    echo json_encode(["thanhCong" => true, "thongBao" => "Thêm sách thành công"]);
} else {
    echo json_encode(["thanhCong" => false, "thongBao" => "Lỗi: " . $conn->error]);
}
?>
