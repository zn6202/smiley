class API
{
  static const hostConnect = "http://192.168.56.1/smiley_backend";
  // static const hostConnect = "http://127.0.0.1:8080/smiley_backend";
  // static const hostConnect = "http://163.22.32.24/smiley_backend";

  static const hostConnectUser = "$hostConnect/user";

  // 將 firebase_uid 和其他 user 資訊放進 MySQL
  static const user = "$hostConnect/user/user.php";
  static const diary = "$hostConnect/diary/diary.php";
  static const getUid = "$hostConnect/user/getUid.php";
  static const getProfile = "$hostConnect/user/getProfile.php";
  static const editProfile = "$hostConnect/user/editProfile.php";
  static const searchUser = "$hostConnect/user/searchUser.php";
  static const inviteFriend = "$hostConnect/user/inviteFriend.php";
  static const cancelInviteFriend = "$hostConnect/user/cancelInviteFriend.php";
  static const invitedList = "$hostConnect/user/invitedList.php";
  static const acceptInvite = "$hostConnect/user/acceptInvite.php";
  static const rejectInvite = "$hostConnect/user/rejectInvite.php";
  static const getFriends = "$hostConnect/user/getFriends.php";
  static const delFriend = "$hostConnect/user/delFriend.php";


}