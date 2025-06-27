<?php
require 'db.php';
header("Content-Type: application/json");

$sql = "SELECT * FROM Sach";
$result = $conn->query($sql);

$dsSach = [];
while ($row = $result->fetch_assoc()) {
    // Nếu có hình ảnh, tạo đường dẫn đầy đủ cho client
    if (!empty($row['HinhAnh'])) {
        $row['HinhAnh'] = "http://10.0.2.2/thu_vien_api/" . $row['HinhAnh'];
    }
    $dsSach[] = $row;
}

echo json_encode($dsSach);
?>
