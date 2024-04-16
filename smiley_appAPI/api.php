<?php
header('Content-Type: application/json');

$host = 'localhost'; //執行DB Server 的主機
$user = 'root'; //登入DB用的DB 帳號
$pass = ''; //登入DB用的DB 密碼
$dbName = 'smiley_app'; //使用的資料庫名稱

// 建立連接
$conn = new mysqli($host, $user, $pass, $dbName);

// 檢查連接
if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => "Connection failed: " . $conn->connect_error]));
}

// 處理POST請求
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $date = $_POST['date'];
    $content = $_POST['content'];

    $stmt = $conn->prepare("INSERT INTO diary (date, content) VALUES (?, ?)");
    $stmt->bind_param("ss", $date, $content);

    if ($stmt->execute()) {
        echo json_encode(['status' => 'success', 'message' => 'Diary entry saved successfully']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to save diary entry']);
    }

    $stmt->close();
    $conn->close();
} else {
    // 如果不是POST請求，可以返回一個錯誤消息或默認響應
    echo json_encode(['status' => 'error', 'message' => 'Invalid request']);
}
?>
