// import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mdc_bhl/utils/file_utils.dart';

/*
 * 用户记录
 */
class TabUserModel {
  static const String TAB_NAME = "tab_user";

  static const String ID = "id";
  static const String NAME = "name";
  static const String PWD = "pwd";
  static const String MOBILE = "mobile";
  static const String DEPARTMENT_ID = "departmentId";
  static const String DEPARTMENT_NAME = "departmentName";
  static const String REAL_NAME = "realName";
  static const String SEX = "sex";
  static const String DEVICE_ID = "deviceId";
  static const String PHOTO_PATH = "photoPath";
  static const String PHOTO_URL = "photoUrl";

  String id; // 用户id（主）
  String name; // 用户名
  String pwd; // 用户密码
  String mobile; // 电话
  String departmentId; // 部门id
  String departmentName; // 部门名称
  String realName; // 真实姓名
  int sex; // 性别
  String deviceId; // 设备id
  String photoPath; // 头像本地存储路径
  String photoUrl; // 头像网络存储路径

  @override
  String toString() {
    return 'TabUserModel{id: $id, name: $name, pwd: $pwd, mobile: $mobile, departmentId: $departmentId, departmentName: $departmentName, realName: $realName, sex: $sex, deviceId: $deviceId, photoPath: $photoPath, photoUrl: $photoUrl}';
  }
}

class TabUserManager {
  // 插入用户
  insert(TabUserModel tabUserModel) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String _dbPath = prefs.getString("DB_PATH");
        String _dbPath = await FileUtils.getDatabasePath();


    String _id = tabUserModel.id;
    String _name = tabUserModel.name;
    String _pwd = tabUserModel.pwd;
    String _mobile = tabUserModel.mobile;
    String _departmentId = tabUserModel.departmentId;
    String _departmentName = tabUserModel.departmentName;
    String _realName = tabUserModel.realName;
    int _sex = (tabUserModel.sex == null ? 0 : tabUserModel.sex);
    String _deviceId = tabUserModel.deviceId;
    String _photoPath = tabUserModel.photoPath;
    String _photoUrl = tabUserModel.photoUrl;

    Database db = await openDatabase(_dbPath);
    String sql = "INSERT OR REPLACE INTO " + TabUserModel.TAB_NAME +
        "(" + TabUserModel.ID +
        "," + TabUserModel.NAME +
        "," + TabUserModel.PWD +
        "," + TabUserModel.MOBILE +
        "," + TabUserModel.DEPARTMENT_ID +
        "," + TabUserModel.DEPARTMENT_NAME +
        "," + TabUserModel.REAL_NAME +
        "," + TabUserModel.SEX +
        "," + TabUserModel.DEVICE_ID +
        "," + TabUserModel.PHOTO_PATH +
        "," + TabUserModel.PHOTO_URL +
        ") VALUES('$_id','$_name','$_pwd','$_mobile','$_departmentId','$_departmentName','$_realName','$_sex','$_deviceId','$_photoPath','$_photoUrl')";
    await db.transaction((txn) async {
      await txn.rawInsert(sql);
    });
    await db.close();
    print("插入" + TabUserModel.TAB_NAME + "成功");
  }

  // 查询所有用户
  queryAll() {
    String sql = 'SELECT * FROM ' + TabUserModel.TAB_NAME;
    return _query(sql);
  }

  // 根据用户名查询用户
  queryByName(String userName) {
    String sql = 'SELECT * FROM ' + TabUserModel.TAB_NAME + ' WHERE ' +
        TabUserModel.NAME + '=' + userName;
    _query(sql);
  }

  _query(String sql) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String _dbPath = prefs.getString("DB_PATH");
        String _dbPath = await FileUtils.getDatabasePath();


    Database db = await openDatabase(_dbPath);
    List<Map> list = await db.rawQuery(sql);
    await db.close();

    List<TabUserModel> tabUserModelList = new List();
    for (var item in list) {
      TabUserModel tabUserModel = _convertToModel(item);
      tabUserModelList.add(tabUserModel);
    }
    return tabUserModelList;
  }

  TabUserModel _convertToModel(Map item) {
    TabUserModel tabUserModel = new TabUserModel();
    tabUserModel.id = item[TabUserModel.ID];
    tabUserModel.name = item[TabUserModel.NAME];
    tabUserModel.pwd = item[TabUserModel.PWD];
    tabUserModel.mobile = item[TabUserModel.MOBILE];
    tabUserModel.departmentId = item[TabUserModel.DEPARTMENT_ID];
    tabUserModel.departmentName = item[TabUserModel.DEPARTMENT_NAME];
    tabUserModel.realName = item[TabUserModel.REAL_NAME];
    tabUserModel.sex = item[TabUserModel.SEX];
    tabUserModel.deviceId = item[TabUserModel.DEVICE_ID];
    tabUserModel.photoPath = item[TabUserModel.PHOTO_PATH];
    tabUserModel.photoUrl = item[TabUserModel.PHOTO_URL];
    return tabUserModel;
  }
}