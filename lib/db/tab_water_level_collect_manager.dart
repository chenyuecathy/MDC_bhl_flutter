// import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mdc_bhl/utils/file_utils.dart';

/*
 * 水位记录
 */
class TabWaterLevelCollectModel {
  static const String TAB_NAME = "tab_water_level_collect";

  static const String ID = "id";
  static const String COLLECTOR_ID = "collectorId";
  static const String WATER_LEVEL_VALUE = "waterLevelValue";
  static const String IS_UPLOAD = "isUpload";
  static const String UPLOAD_TIME = "uploadTime";

  String id; // 水位记录id（主）
  String collectorId; // 采集人id
  double waterLevelValue; // 水位值
  int isUpload; // 是否提交 0-未提交，1-已提交
  String uploadTime; // 提交时间

  @override
  String toString() {
    return 'TabWaterLevelCollectModel{id: $id, collectorId: $collectorId, waterLevelValue: $waterLevelValue, isUpload: $isUpload, uploadTime: $uploadTime}';
  }

  Map<String, dynamic> toJson(String userName) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.id;
    data['SW'] = this.waterLevelValue;
    data['CJRID'] = this.collectorId;
    data['CJRMC'] = userName;
    return data;
  }
}

class TabWaterLevelCollectManager {
  // 插入水位记录
  insert(TabWaterLevelCollectModel tabWaterLevelCollectModel) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String _dbPath = prefs.getString("DB_PATH");
    String _dbPath = await FileUtils.getDatabasePath();


    String _id = tabWaterLevelCollectModel.id;
    String _collectorId = tabWaterLevelCollectModel.collectorId;
    double _waterLevelValue = (tabWaterLevelCollectModel.waterLevelValue == null ? 0 : tabWaterLevelCollectModel.waterLevelValue);
    int _isUpload = (tabWaterLevelCollectModel.isUpload == null ? 0 : tabWaterLevelCollectModel.isUpload);
    String _uploadTime = tabWaterLevelCollectModel.uploadTime;

    Database db = await openDatabase(_dbPath);
    String sql = "INSERT OR REPLACE INTO " + TabWaterLevelCollectModel.TAB_NAME +
        "(" + TabWaterLevelCollectModel.ID +
        "," + TabWaterLevelCollectModel.COLLECTOR_ID +
        "," + TabWaterLevelCollectModel.WATER_LEVEL_VALUE +
        "," + TabWaterLevelCollectModel.IS_UPLOAD +
        "," + TabWaterLevelCollectModel.UPLOAD_TIME +
        ") VALUES('$_id','$_collectorId','$_waterLevelValue','$_isUpload','$_uploadTime')";
    await db.transaction((txn) async {
      await txn.rawInsert(sql);
    });
    await db.close();
    print("插入" + TabWaterLevelCollectModel.TAB_NAME + "成功:" + sql);
  }

  // 查询所有水位记录
  queryAll() {
    String sql = 'SELECT * FROM ' + TabWaterLevelCollectModel.TAB_NAME;
    return _query(sql, null);
  }

  // 根据水位id查询水位记录
  queryById(String id) {
    String sql = 'SELECT * FROM ' + TabWaterLevelCollectModel.TAB_NAME + " WHERE " + TabWaterLevelCollectModel.ID + " = ?";
    return _query(sql, [id]);
  }

  // 根据用户id查询水位记录
  queryByUserId(String userId) {
    String sql = 'SELECT * FROM ' + TabWaterLevelCollectModel.TAB_NAME + " WHERE " + TabWaterLevelCollectModel.COLLECTOR_ID + " = ? AND isUpload==1 ORDER BY uploadTime DESC";
    return _query(sql, [userId]);
  }

  // 根据用户id查询水位未上传记录
  queryByUserIdWithUnupload(String userId) {
    String sql = 'SELECT * FROM ' + TabWaterLevelCollectModel.TAB_NAME + " WHERE " + TabWaterLevelCollectModel.COLLECTOR_ID + " = ? AND isUpload!=1";
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

    List<TabWaterLevelCollectModel> tabWaterLevelCollectModelList = new List();
    for (var item in list) {
      TabWaterLevelCollectModel tabWaterLevelCollectModel = _convertToModel(item);
      tabWaterLevelCollectModelList.add(tabWaterLevelCollectModel);
    }
    return tabWaterLevelCollectModelList;
  }

  TabWaterLevelCollectModel _convertToModel(Map item) {
    TabWaterLevelCollectModel tabWaterLevelCollectModel = new TabWaterLevelCollectModel();
    tabWaterLevelCollectModel.id = item[TabWaterLevelCollectModel.ID];
    tabWaterLevelCollectModel.collectorId = item[TabWaterLevelCollectModel.COLLECTOR_ID];
    tabWaterLevelCollectModel.waterLevelValue = item[TabWaterLevelCollectModel.WATER_LEVEL_VALUE];
    tabWaterLevelCollectModel.isUpload = item[TabWaterLevelCollectModel.IS_UPLOAD];
    tabWaterLevelCollectModel.uploadTime = item[TabWaterLevelCollectModel.UPLOAD_TIME];
    return tabWaterLevelCollectModel;
  }

  deleteById(String id) async {
    String _dbPath = await FileUtils.getDatabasePath();
    Database db = await openDatabase(_dbPath);
    String sql = "DELETE FROM " + TabWaterLevelCollectModel.TAB_NAME + " WHERE " + TabWaterLevelCollectModel.ID + " = ?";
    int count = await db.rawDelete(sql, [id]);
    if (count == 1) {
      return true;
    } else {
      return false;
    }
//    await db.close();
  }
}