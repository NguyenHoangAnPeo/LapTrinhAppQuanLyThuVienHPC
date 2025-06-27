<?php
// Kết nối CSDL
$host = "localhost";
$username = "root"; // Đổi nếu khác
$password = "";     // Đổi nếu có mật khẩu
$database = "thuvien"; // Tên CSDL của bạn

$conn = mysqli_connect($host, $username, $password, $database);
mysqli_set_charset($conn, "utf8");

if (!$conn) {
    die("Kết nối thất bại: " . mysqli_connect_error());
}

// Nhận dữ liệu JSON từ Flutter
$data = json_decode(file_get_contents("php://input"), true);
$taiKhoan = $data['TaiKhoan'];

// Lấy danh sách sách đã mượn theo tài khoản
$sql = "SELECT s.MaSach, s.TenSach, s.TacGia, s.SoLuong, s.SoLuongConLai
        FROM Sach s
        JOIN SachMuon m ON s.MaSach = m.MaSach
        WHERE m.TaiKhoan = '$taiKhoan'";

$result = mysqli_query($conn, $sql);

$mang = array();
while ($row = mysqli_fetch_assoc($result)) {
    $mang[] = $row;
}

echo json_encode($mang);
?>
