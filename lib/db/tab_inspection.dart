// import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mdc_bhl/utils/file_utils.dart';

/*
 * 巡查记录
 */
class TabInspectionModel {
  static const String TAB_NAME = "tab_inspection";

  static const String ID = "id";
  static const String INSPECTOR_ID = "inspectorId";
  static const String INSPECTION_TYPE = "inspectionType";
  static const String INSPECTION_STATE = "inspectionState";
  static const String INSPECTION_TIME = "inspectionTime";

  String id; // 巡查记录id（主）
  String inspectorId; // 巡查人id
  int inspectionType; // 巡查类型 0-设备科日巡查记录表，1-设备夜间巡查记录表，2-保卫科日常巡查记录表，3-异常上报
  int inspectionState; // 巡查状态 0-异常，1-正常，2-未巡查
  String inspectionTime; // 巡查时间

  @override
  String toString() {
    return 'TabInspectionModel{id: $id, inspectorId: $inspectorId, inspectionType: $inspectionType, inspectionState: $inspectionState, inspectionTime: $inspectionTime}';
  }

  Map<String, dynamic> toJson(String userName) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Cjrid'] = this.inspectorId;
    data['Cjrmc'] = userName;
    data['Xclx'] = this.inspectionType;
    data['Jlzt'] = this.inspectionState;
    return data;
  }
}

class TabInspectionManager {
  // 插入巡查记录
  insert(TabInspectionModel tabInspectionModel) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String _dbPath = prefs.getString("DB_PATH");
    String _dbPath = await FileUtils.getDatabasePath();


    String _id = tabInspectionModel.id;
    String _inspectorId = tabInspectionModel.inspectorId;
    int _inspectionType = (tabInspectionModel.inspectionType == null ? 0 : tabInspectionModel.inspectionType);
    int _inspectionState = (tabInspectionModel.inspectionState == null ? 0 : tabInspectionModel.inspectionState);
    String _inspectionTime = tabInspectionModel.inspectionTime;

    Database db = await openDatabase(_dbPath);
    String sql = "INSERT OR REPLACE INTO " + TabInspectionModel.TAB_NAME +
        "(" + TabInspectionModel.ID +
        "," + TabInspectionModel.INSPECTOR_ID +
        "," + TabInspectionModel.INSPECTION_TYPE +
        "," + TabInspectionModel.INSPECTION_STATE +
        "," + TabInspectionModel.INSPECTION_TIME +
        ") VALUES('$_id','$_inspectorId','$_inspectionType','$_inspectionState','$_inspectionTime')";
    await db.transaction((txn) async {
      await txn.rawInsert(sql);
    });
    await db.close();
    print("插入" + TabInspectionModel.TAB_NAME + "成功:" + sql);
  }

  // 查询所有巡查记录
  queryAll() {
    String sql = 'SELECT * FROM ' + TabInspectionModel.TAB_NAME;
    return _query(sql, null);
  }

  // 根据用户id查询巡查记录
  queryByUserId(String userId) {
    String sql = 'SELECT * FROM ' + TabInspectionModel.TAB_NAME + " WHERE " + TabInspectionModel.INSPECTOR_ID + " = ?";
    return _query(sql, [userId]);
  }

  // 根据用户id查询设备科记录
  queryByUserIdWithGuard(String userId) {
    String sql = 'SELECT * FROM ' + TabInspectionModel.TAB_NAME + " WHERE " + TabInspectionModel.INSPECTOR_ID + " = ? And inspectionType = 2";
    return _query(sql, [userId]);
  }

  // 根据id、巡查类型查询巡查记录，是否是当前用户的
  queryBelongToUserAndInspectionstate(String inspectionId, String userId, int inspectionState) {
    String sql = 'SELECT * FROM ' + TabInspectionModel.TAB_NAME + " WHERE " + TabInspectionModel.ID + " = ?";
    List<TabInspectionModel> tabInspectionModelList = _query(sql, [inspectionId]);
    if (tabInspectionModelList[0].inspectorId == userId && tabInspectionModelList[0].inspectionState == inspectionState) {
      return true;
    } else {
      return false;
    }
  }

  // 根据用户id和时间查询巡查记录
  queryByUserIdAndTime(String userId, String time) {
    String sql = 'SELECT * FROM ' + TabInspectionModel.TAB_NAME + " WHERE " + TabInspectionModel.INSPECTOR_ID + " = ? And " + TabInspectionModel.INSPECTION_TIME + " = ?";
    return _query(sql, [userId, time]);
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

    List<TabInspectionModel> tabInspectionModelList = new List();
    for (var item in list) {
      TabInspectionModel tabInspectionModel = _convertToModel(item);
      tabInspectionModelList.add(tabInspectionModel);
    }
    return tabInspectionModelList;
  }

  TabInspectionModel _convertToModel(Map item) {
    TabInspectionModel tabInspectionModel = new TabInspectionModel();
    tabInspectionModel.id = item[TabInspectionModel.ID];
    tabInspectionModel.inspectorId = item[TabInspectionModel.INSPECTOR_ID];
    tabInspectionModel.inspectionType = item[TabInspectionModel.INSPECTION_TYPE];
    tabInspectionModel.inspectionState = item[TabInspectionModel.INSPECTION_STATE];
    tabInspectionModel.inspectionTime = item[TabInspectionModel.INSPECTION_TIME];
    return tabInspectionModel;
  }
}