
# smiley
### 適應性size
- C:\project\smiley\lib\core\utils\size_utils.dart 寫撰寫此APP的適應性設計
-  因為手機的尺寸有很多種，在不同裝置跑出來的效果就不一樣。
- 此文件會它會自動換算尺寸，去匹配每一支手機的螢幕大小。
- 原則：
- left,right,Width等水平垂直使用 .h
- top,bottom,Height等垂直方向 .v
- EdgeInsets.all這種用(.adaptSize),
- 字體用.fsize
- 例如:如Width:10.0。要改成Width:10.0.h
### 增加字體與照片
- 將文件丟到 assets
- 至pubspec.yaml新增
- 終端機輸入指令：flutter pub get
### 新增依賴包
- 至pubspec.yaml新增
- 終端機輸入指令：flutter pub get
### 路由表
- app_routes.dart 新增頁面
1. import檔案
2. 新增static const String、routes
3. routes的取名與新增的頁面class需相同