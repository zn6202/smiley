class User
{
  int id;
  String firebase_user_id;
  String name;
  String photo;

  User(  // 初始化屬性及其值
      this.id,
      this.firebase_user_id,
      this.name,
      this.photo
  );

  // 將 json 格式的數據轉換成對象()
  factory User.fromJson(Map<String, dynamic > json) => User(
    int.parse(json["id"]),
    json["firebase_user_id"],
    json["name"],
    json["photo"],
  );

  Map<String, String> toJson() => 
  {
    'id':id.toString(),  // JSON 格式只能存儲字符串類型的數據
    'firebase_user_id':firebase_user_id,
    'name':name,
    'photo':photo,
  };
}

// Map<String, String>:

// Map<String, String> example1 = {
//   'name': 'Alice',
//   'age': '30'
// };

// Map<String, dynamic>:

// Map<String, dynamic> example2 = {
//   'name': 'Alice',
//   'age': 30,
//   'isStudent': true,
//   'scores': [95, 88, 92]