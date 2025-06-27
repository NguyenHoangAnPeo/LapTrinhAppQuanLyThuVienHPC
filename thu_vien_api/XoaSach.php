<?php
require 'db.php';
header("Content-Type: application/json");

$data = json_decode(file_get_contents("php://input"));
$maSach = $data->MaSach;

$sql = "DELETE FROM Sach WHERE MaSach = $maSach";

if ($conn->query($sql)) {
    echo json_encode(["thanhCong" => true, "thongBao" => "Xóa sách thành công"]);
} else {
    echo json_encode(["thanhCong" => false, "thongBao" => "Lỗi: " . $conn->error]);
}
?>
