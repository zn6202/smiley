class API
{
  static const hostConnect = "http://192.168.56.1/smiley_backend";
  //  static const hostConnect = "http://163.22.32.24/smiley_backend";

  static const hostConnectUser = "$hostConnect/user";

  // 將 firebase_uid 和其他 user 資訊放進 MySQL
  static const user = "$hostConnect/user/user.php";
  static const diary = "$hostConnect/diary/diary.php";
  static const getUid = "$hostConnect/user/getUid.php";

}