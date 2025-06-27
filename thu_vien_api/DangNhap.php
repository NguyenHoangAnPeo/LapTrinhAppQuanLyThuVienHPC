<?php
include 'db.php'; // Kết nối tới cơ sở dữ liệu

// Đọc dữ liệu JSON từ phía client (Flutter)
$data = json_decode(file_get_contents("php://input"), true);

// Kiểm tra nếu dữ liệu không hợp lệ
if (!$data || !isset($data['taiKhoan']) || !isset($data['matKhau'])) {
    echo json_encode([
        'thanhCong' => false,
        'thongBao' => 'Thiếu tài khoản hoặc mật khẩu'
    ]);
    exit;
}

$taiKhoan = $conn->real_escape_string($data['taiKhoan']);
$matKhau = $conn->real_escape_string($data['matKhau']);

// Truy vấn bảng NguoiDung
$sql = "SELECT * FROM NguoiDung WHERE TaiKhoan = '$taiKhoan' AND MatKhau = '$matKhau'";
$result = mysqli_query($conn, $sql);

// Kiểm tra kết quả
if ($result && mysqli_num_rows($result) > 0) {
    $row = mysqli_fetch_assoc($result);

    echo json_encode([
        'thanhCong' => true,
        'quyen' => $row['VaiTro'],
        'tenNguoiDung' => $row['TaiKhoan']
    ]);
} else {
    echo json_encode([
        'thanhCong' => false,
        'thongBao' => 'Sai tài khoản hoặc mật khẩu'
    ]);
}
?>
