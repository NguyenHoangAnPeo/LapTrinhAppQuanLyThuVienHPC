<?php
require 'db.php';
header("Content-Type: application/json");

$data = json_decode(file_get_contents("php://input"));
$maMuon = $data->MaMuon;

$sql = "SELECT DaGiaHan FROM MuonSach WHERE MaMuon = $maMuon";
$result = $conn->query($sql);
$row = $result->fetch_assoc();

if ($row && !$row['DaGiaHan']) {
    $conn->query("UPDATE MuonSach SET NgayTra = DATE_ADD(NgayTra, INTERVAL 7 DAY), DaGiaHan = TRUE WHERE MaMuon = $maMuon");
    echo json_encode(["thanhCong" => true, "thongBao" => "Gia hạn thành công"]);
} else {
    echo json_encode(["thanhCong" => false, "thongBao" => "Không thể gia hạn lần nữa"]);
}
?>
