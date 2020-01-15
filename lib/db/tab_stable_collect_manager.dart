// import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mdc_bhl/utils/file_utils.dart';

/*
 * 稳定性记录
 */
class TabStableCollectModel {
  static const String TAB_NAME = "tab_stable_collect";

  static const String ID = "id";
  static const String COLLECTOR_ID = "collectorId";
  static const String R32D_MS_VALUE = "r32dMsValue";
  static const String R32D_WD_VALUE = "r32dWdValue";
  static const String R33D_MS_VALUE = "r33dMsValue";
  static const String R33D_WD_VALUE = "r33dWdValue";
  static const String R34D_MS_VALUE = "r34dMsValue";
  static const String R34D_WD_VALUE = "r34dWdValue";
  static const String R35D_MS_VALUE = "r35dMsValue";
  static const String R35D_WD_VALUE = "r35dWdValue";
  static const String R36D_MS_VALUE = "r36dMsValue";
  static const String R36D_WD_VALUE = "r36dWdValue";
  static const String R37D_MS_VALUE = "r37dMsValue";
  static const String R37D_WD_VALUE = "r37dWdValue";
  static const String R38D_MS_VALUE = "r38dMsValue";
  static const String R38D_WD_VALUE = "r38dWdValue";
  static const String R39D_MS_VALUE = "r39dMsValue";
  static const String R39D_WD_VALUE = "r39dWdValue";
  static const String R40D_MS_VALUE = "r40dMsValue";
  static const String R40D_WD_VALUE = "r40dWdValue";
  static const String J02D_MS_VALUE = "j02dMsValue";
  static const String J02D_WD_VALUE = "j02dWdValue";
  static const String IS_UPLOAD = "isUpload";
  static const String UPLOAD_TIME = "uploadTime";

  String id; // 水位记录id（主）
  String collectorId; // 采集人id
  double r32dMsValue; // 钢筋计R32D模数值
  double r32dWdValue; // 钢筋计R32D温度值
  double r33dMsValue; // 钢筋计R33D模数值
  double r33dWdValue; // 钢筋计R33D温度值
  double r34dMsValue; // 钢筋计R34D模数值
  double r34dWdValue; // 钢筋计R34D温度值
  double r35dMsValue; // 钢筋计R35D模数值
  double r35dWdValue; // 钢筋计R35D温度值
  double r36dMsValue; // 钢筋计R36D模数值
  double r36dWdValue; // 钢筋计R36D温度值
  double r37dMsValue; // 钢筋计R37D模数值
  double r37dWdValue; // 钢筋计R37D温度值
  double r38dMsValue; // 钢筋计R38D模数值
  double r38dWdValue; // 钢筋计R38D温度值
  double r39dMsValue; // 钢筋计R39D模数值
  double r39dWdValue; // 钢筋计R39D温度值
  double r40dMsValue; // 钢筋计R40D模数值
  double r40dWdValue; // 钢筋计R40D温度值
  double j02dMsValue; // 测缝计J02D模数值
  double j02dWdValue; // 测缝计J02D温度值
  int isUpload; // 是否提交 0-未提交，1-已提交
  String uploadTime; // 提交时间

  @override
  String toString() {
    return 'TabStableCollectModel{id: $id, collectorId: $collectorId, r32dMsValue: $r32dMsValue, r32dWdValue: $r32dWdValue, r33dMsValue: $r33dMsValue, r33dWdValue: $r33dWdValue, r34dMsValue: $r34dMsValue, r34dWdValue: $r34dWdValue, r35dMsValue: $r35dMsValue, r35dWdValue: $r35dWdValue, r36dMsValue: $r36dMsValue, r36dWdValue: $r36dWdValue, r37dMsValue: $r37dMsValue, r37dWdValue: $r37dWdValue, r38dMsValue: $r38dMsValue, r38dWdValue: $r38dWdValue, r39dMsValue: $r39dMsValue, r39dWdValue: $r39dWdValue, r40dMsValue: $r40dMsValue, r40dWdValue: $r40dWdValue, j02dMsValue: $j02dMsValue, j02dWdValue: $j02dWdValue, isUpload: $isUpload, uploadTime: $uploadTime}';
  }

  Map<String, dynamic> toJson(String userId, String userName) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.id;
    data['CJRID'] = userId;
    data['CJRMC'] = userName;
    data['R32d'] = this.r32dMsValue;
    data['R33d'] = this.r33dMsValue;
    data['R34d'] = this.r34dMsValue;
    data['R35d'] = this.r35dMsValue;
    data['R36d'] = this.r36dMsValue;
    data['R37d'] = this.r37dMsValue;
    data['R38d'] = this.r38dMsValue;
    data['R39d'] = this.r39dMsValue;
    data['R40d'] = this.r40dMsValue;
    data['J02d'] = this.j02dMsValue;
    data['R32dTEMP'] = this.r32dWdValue;
    data['R33dTEMP'] = this.r33dWdValue;
    data['R34dTEMP'] = this.r34dWdValue;
    data['R35dTEMP'] = this.r35dWdValue;
    data['R36dTEMP'] = this.r36dWdValue;
    data['R37dTEMP'] = this.r37dWdValue;
    data['R38dTEMP'] = this.r38dWdValue;
    data['R39dTEMP'] = this.r39dWdValue;
    data['R40dTEMP'] = this.r40dWdValue;
    data['J02dTEMP'] = this.j02dWdValue;
    return data;
  }
}

class TabStableCollectManager {
  // 插入稳定性记录
  insert(TabStableCollectModel tabStableCollectModel) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String _dbPath = prefs.getString("DB_PATH");
        String _dbPath = await FileUtils.getDatabasePath();


    String _id = tabStableCollectModel.id;
    String _collectorId = tabStableCollectModel.collectorId;
    double _r32dMsValue = (tabStableCollectModel.r32dMsValue == null ? 0 : tabStableCollectModel.r32dMsValue);
    double _r32dWdValue = (tabStableCollectModel.r32dWdValue == null ? 0 : tabStableCollectModel.r32dWdValue);
    double _r33dMsValue = (tabStableCollectModel.r33dMsValue == null ? 0 : tabStableCollectModel.r33dMsValue);
    double _r33dWdValue = (tabStableCollectModel.r33dWdValue == null ? 0 : tabStableCollectModel.r33dWdValue);
    double _r34dMsValue = (tabStableCollectModel.r34dMsValue == null ? 0 : tabStableCollectModel.r34dMsValue);
    double _r34dWdValue = (tabStableCollectModel.r34dWdValue == null ? 0 : tabStableCollectModel.r34dWdValue);
    double _r35dMsValue = (tabStableCollectModel.r35dMsValue == null ? 0 : tabStableCollectModel.r35dMsValue);
    double _r35dWdValue = (tabStableCollectModel.r35dWdValue == null ? 0 : tabStableCollectModel.r35dWdValue);
    double _r36dMsValue = (tabStableCollectModel.r36dMsValue == null ? 0 : tabStableCollectModel.r36dMsValue);
    double _r36dWdValue = (tabStableCollectModel.r36dWdValue == null ? 0 : tabStableCollectModel.r36dWdValue);
    double _r37dMsValue = (tabStableCollectModel.r37dMsValue == null ? 0 : tabStableCollectModel.r37dMsValue);
    double _r37dWdValue = (tabStableCollectModel.r37dWdValue == null ? 0 : tabStableCollectModel.r37dWdValue);
    double _r38dMsValue = (tabStableCollectModel.r38dMsValue == null ? 0 : tabStableCollectModel.r38dMsValue);
    double _r38dWdValue = (tabStableCollectModel.r38dWdValue == null ? 0 : tabStableCollectModel.r38dWdValue);
    double _r39dMsValue = (tabStableCollectModel.r39dMsValue == null ? 0 : tabStableCollectModel.r39dMsValue);
    double _r39dWdValue = (tabStableCollectModel.r39dWdValue == null ? 0 : tabStableCollectModel.r39dWdValue);
    double _r40dMsValue = (tabStableCollectModel.r40dMsValue == null ? 0 : tabStableCollectModel.r40dMsValue);
    double _r40dWdValue = (tabStableCollectModel.r40dWdValue == null ? 0 : tabStableCollectModel.r40dWdValue);
    double _j02dMsValue = (tabStableCollectModel.j02dMsValue == null ? 0 : tabStableCollectModel.j02dMsValue);
    double _j02dWdValue = (tabStableCollectModel.j02dWdValue == null ? 0 : tabStableCollectModel.j02dWdValue);
    int _isUpload = (tabStableCollectModel.isUpload == null ? 0 : tabStableCollectModel.isUpload);
    String _uploadTime = tabStableCollectModel.uploadTime;

    Database db = await openDatabase(_dbPath);
    String sql = "INSERT OR REPLACE INTO " + TabStableCollectModel.TAB_NAME +
        "(" + TabStableCollectModel.ID +
        "," + TabStableCollectModel.COLLECTOR_ID +
        "," + TabStableCollectModel.R32D_MS_VALUE +
        "," + TabStableCollectModel.R32D_WD_VALUE +
        "," + TabStableCollectModel.R33D_MS_VALUE +
        "," + TabStableCollectModel.R33D_WD_VALUE +
        "," + TabStableCollectModel.R34D_MS_VALUE +
        "," + TabStableCollectModel.R34D_WD_VALUE +
        "," + TabStableCollectModel.R35D_MS_VALUE +
        "," + TabStableCollectModel.R35D_WD_VALUE +
        "," + TabStableCollectModel.R36D_MS_VALUE +
        "," + TabStableCollectModel.R36D_WD_VALUE +
        "," + TabStableCollectModel.R37D_MS_VALUE +
        "," + TabStableCollectModel.R37D_WD_VALUE +
        "," + TabStableCollectModel.R38D_MS_VALUE +
        "," + TabStableCollectModel.R38D_WD_VALUE +
        "," + TabStableCollectModel.R39D_MS_VALUE +
        "," + TabStableCollectModel.R39D_WD_VALUE +
        "," + TabStableCollectModel.R40D_MS_VALUE +
        "," + TabStableCollectModel.R40D_WD_VALUE +
        "," + TabStableCollectModel.J02D_MS_VALUE +
        "," + TabStableCollectModel.J02D_WD_VALUE +
        "," + TabStableCollectModel.IS_UPLOAD +
        "," + TabStableCollectModel.UPLOAD_TIME +
        ") VALUES('$_id','$_collectorId','$_r32dMsValue','$_r32dWdValue','$_r33dMsValue','$_r33dWdValue','$_r34dMsValue','$_r34dWdValue','$_r35dMsValue','$_r35dWdValue','$_r36dMsValue','$_r36dWdValue','$_r37dMsValue','$_r37dWdValue','$_r38dMsValue','$_r38dWdValue','$_r39dMsValue','$_r39dWdValue','$_r40dMsValue','$_r40dWdValue','$_j02dMsValue','$_j02dWdValue','$_isUpload','$_uploadTime')";
    await db.transaction((txn) async {
      await txn.rawInsert(sql);
    });
    await db.close();
    print("插入" + TabStableCollectModel.TAB_NAME + "成功:" + sql);
  }

  // 查询所有稳定性记录
  queryAll() {
    String sql = 'SELECT * FROM ' + TabStableCollectModel.TAB_NAME;
    return _query(sql, null);
  }

  // 根据稳定性id查询稳定性记录
  queryById(String id) {
    String sql = 'SELECT * FROM ' + TabStableCollectModel.TAB_NAME + " WHERE " + TabStableCollectModel.ID + " = ?";
    return _query(sql, [id]);
  }

  // 根据用户id查询稳定性记录
  queryByUserId(String userId) {
    String sql = 'SELECT * FROM ' + TabStableCollectModel.TAB_NAME + " WHERE " + TabStableCollectModel.COLLECTOR_ID + " = ? AND isUpload==1 ORDER BY uploadTime DESC";
    return _query(sql, [userId]);
  }

  // 根据用户id查询稳定性未上传记录
  queryByUserIdWithUnupload(String userId) {
    String sql = 'SELECT * FROM ' + TabStableCollectModel.TAB_NAME + " WHERE " + TabStableCollectModel.COLLECTOR_ID + " = ? AND isUpload!=1";
    return _query(sql, [userId]);
  }

  _query(String sql, args) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String _dbPath = prefs.getString("DB_PATH");
        String _dbPath = await FileUtils.getDatabasePath();


    Database db = await openDatabase(_dbPath);
    List<Map> list;
    if (args == null) {
      list = await db.rawQuery(sql);
    } else {
      list = await db.rawQuery(sql, args);
    }
    await db.close();

    List<TabStableCollectModel> tabStableCollectModelList = new List();
    for (var item in list) {
      TabStableCollectModel tabStableCollectModel = _convertToModel(item);
      tabStableCollectModelList.add(tabStableCollectModel);
    }
    return tabStableCollectModelList;
  }

  TabStableCollectModel _convertToModel(Map item) {
    TabStableCollectModel tabStableCollectModel = new TabStableCollectModel();
    tabStableCollectModel.id = item[TabStableCollectModel.ID];
    tabStableCollectModel.collectorId = item[TabStableCollectModel.COLLECTOR_ID];
    tabStableCollectModel.r32dMsValue = item[TabStableCollectModel.R32D_MS_VALUE];
    tabStableCollectModel.r32dWdValue = item[TabStableCollectModel.R32D_WD_VALUE];
    tabStableCollectModel.r33dMsValue = item[TabStableCollectModel.R33D_MS_VALUE];
    tabStableCollectModel.r33dWdValue = item[TabStableCollectModel.R33D_WD_VALUE];
    tabStableCollectModel.r34dMsValue = item[TabStableCollectModel.R34D_MS_VALUE];
    tabStableCollectModel.r34dWdValue = item[TabStableCollectModel.R34D_WD_VALUE];
    tabStableCollectModel.r35dMsValue = item[TabStableCollectModel.R35D_MS_VALUE];
    tabStableCollectModel.r35dWdValue = item[TabStableCollectModel.R35D_WD_VALUE];
    tabStableCollectModel.r36dMsValue = item[TabStableCollectModel.R36D_MS_VALUE];
    tabStableCollectModel.r36dWdValue = item[TabStableCollectModel.R36D_WD_VALUE];
    tabStableCollectModel.r37dMsValue = item[TabStableCollectModel.R37D_MS_VALUE];
    tabStableCollectModel.r37dWdValue = item[TabStableCollectModel.R37D_WD_VALUE];
    tabStableCollectModel.r38dMsValue = item[TabStableCollectModel.R38D_MS_VALUE];
    tabStableCollectModel.r38dWdValue = item[TabStableCollectModel.R38D_WD_VALUE];
    tabStableCollectModel.r39dMsValue = item[TabStableCollectModel.R39D_MS_VALUE];
    tabStableCollectModel.r39dWdValue = item[TabStableCollectModel.R39D_WD_VALUE];
    tabStableCollectModel.r40dMsValue = item[TabStableCollectModel.R40D_MS_VALUE];
    tabStableCollectModel.r40dWdValue = item[TabStableCollectModel.R40D_WD_VALUE];
    tabStableCollectModel.j02dMsValue = item[TabStableCollectModel.J02D_MS_VALUE];
    tabStableCollectModel.j02dWdValue = item[TabStableCollectModel.J02D_WD_VALUE];
    tabStableCollectModel.isUpload = item[TabStableCollectModel.IS_UPLOAD];
    tabStableCollectModel.uploadTime = item[TabStableCollectModel.UPLOAD_TIME];
    return tabStableCollectModel;
  }

  deleteById(String id) async {
    String _dbPath = await FileUtils.getDatabasePath();
    Database db = await openDatabase(_dbPath);
    String sql = "DELETE FROM " + TabStableCollectModel.TAB_NAME + " WHERE " + TabStableCollectModel.ID + " = ?";
    int count = await db.rawDelete(sql, [id]);
    if (count == 1) {
      return true;
    } else {
      return false;
    }
//    await db.close();
  }
}