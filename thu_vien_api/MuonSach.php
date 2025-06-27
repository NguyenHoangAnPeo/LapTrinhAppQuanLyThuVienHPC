<?php
require 'db.php';
header("Content-Type: application/json");

$data = json_decode(file_get_contents("php://input"));
$taiKhoan = $data->TaiKhoan;
$maSach = $data->MaSach;
$ngayMuon = date("Y-m-d");
$ngayTra = date("Y-m-d", strtotime("+7 days"));

// Lấy MaNguoiDung từ tài khoản
$sqlUser = "SELECT MaNguoiDung FROM NguoiDung WHERE TaiKhoan = '$taiKhoan'";
$resultUser = $conn->query($sqlUser);

if ($resultUser && $userRow = $resultUser->fetch_assoc()) {
    $maNguoiDung = $userRow['MaNguoiDung'];
} else {
    echo json_encode(["thanhCong" => false, "thongBao" => "Không tìm thấy người dùng"]);
    exit;
}

// Kiểm tra số lượng sách
$sqlSach = "SELECT SoLuongConLai FROM Sach WHERE MaSach = $maSach";
$result = $conn->query($sqlSach);

if ($result && $row = $result->fetch_assoc()) {
    if ($row["SoLuongConLai"] > 0) {
        // Ghi nhận mượn
        $sqlMuon = "INSERT INTO MuonSach (MaNguoiDung, MaSach, NgayMuon, NgayTra) 
                    VALUES ($maNguoiDung, $maSach, '$ngayMuon', '$ngayTra')";

        if ($conn->query($sqlMuon) === TRUE) {
            // Trừ số lượng sau khi mượn thành công
            $conn->query("UPDATE Sach SET SoLuongConLai = SoLuongConLai - 1 WHERE MaSach = $maSach");

            echo json_encode(["thanhCong" => true, "thongBao" => "Mượn sách thành công"]);
        } else {
            echo json_encode(["thanhCong" => false, "thongBao" => "Ghi nhận mượn sách thất bại"]);
        }
    } else {
        echo json_encode(["thanhCong" => false, "thongBao" => "Sách đã hết"]);
    }
} else {
    echo json_encode(["thanhCong" => false, "thongBao" => "Không tìm thấy sách"]);
}
?>
