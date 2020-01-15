// import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mdc_bhl/utils/file_utils.dart';

/*
 * 异常上报记录
 */
class TabReportRecordModel {
  static const String TAB_NAME = "tab_report_record";

  static const String ID = "id";
  static const String INSPECTION_ID = "inspectionId";
  static const String LOCATION = "location";
  static const String EXPLAIN = "explain";
  static const String IMAGES_PATH = "imagesPath";
  static const String IMAGES_URL = "imagesUrl";
  static const String IS_UPLOAD = "is_upload";
  static const String TIME = "time";
  static const String LATLON = "latlon";
  static const String IS_CHECKED = "isChecked";
  static const String CHECK_WAY = "checkWay";
  static const String CHECK_TIME = "checkTime";
  static const String CHECKER_NAME = "checkerName";

  String id; // 异常上报记录id（主）
  String inspectionId; // 巡查id
  String location; // 位置
  String explain; // 情况说明
  String imagesPath; // 图片本地路径
  String imagesUrl; // 图片网络路径
  int isUpload; // 是否提交 0-未提交，1-已提交
  String time; // 保存或提交时间
  String latlon; // 巡查点经纬度（预留字段）
  int isChecked; // 是否核查 0-未核查，1-已核查
  String checkWay; // 核查方式
  String checkTime; // 核查时间
  String checkerName; // 核查人名称

  @override
  String toString() {
    return 'TabReportRecordModel{id: $id, inspectionId: $inspectionId, location: $location, explain: $explain, imagesPath: $imagesPath, imagesUrl: $imagesUrl, isUpload: $isUpload, time: $time, latlon: $latlon, isChecked: $isChecked, checkWay: $checkWay, checkTime: $checkTime, checkerName: $checkerName}';
  }

  Map<String, dynamic> toJson(String userId, String userName) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Xcjlid'] = this.inspectionId;
    data['Wz'] = this.location;
    data['Qksm'] = this.explain;
    data['Jd'] = 0.0;
    data['Wd'] = 0.0;
    data['Cjrid'] = userId;
    data['Cjrmc'] = userName;
    return data;
  }
}

class TabReportRecordManager {
  // 插入异常上报记录
  insert(TabReportRecordModel tabReportRecordModel) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String _dbPath = prefs.getString("DB_PATH");
    String _dbPath = await FileUtils.getDatabasePath();

    String _id = tabReportRecordModel.id;
    String _inspectionId = tabReportRecordModel.inspectionId;
    String _location = tabReportRecordModel.location;
    String _explain = tabReportRecordModel.explain;
    String _imagesPath = tabReportRecordModel.imagesPath;
    String _imagesUrl = tabReportRecordModel.imagesUrl;
    int _isUpload = (tabReportRecordModel.isUpload == null
        ? 0
        : tabReportRecordModel.isUpload);
    String _time = tabReportRecordModel.time;
    String _latlon = tabReportRecordModel.latlon;
    int _isChecked = (tabReportRecordModel.isChecked == null
        ? 0
        : tabReportRecordModel.isChecked);
    String _checkWay = tabReportRecordModel.checkWay;
    String _checkTime = tabReportRecordModel.checkTime;
    String _checkerName = tabReportRecordModel.checkerName;

    Database db = await openDatabase(_dbPath);
    String sql = "INSERT OR REPLACE INTO " +
        TabReportRecordModel.TAB_NAME +
        "(" +
        TabReportRecordModel.ID +
        "," +
        TabReportRecordModel.INSPECTION_ID +
        "," +
        TabReportRecordModel.LOCATION +
        "," +
        TabReportRecordModel.EXPLAIN +
        "," +
        TabReportRecordModel.IMAGES_PATH +
        "," +
        TabReportRecordModel.IMAGES_URL +
        "," +
        TabReportRecordModel.IS_UPLOAD +
        "," +
        TabReportRecordModel.TIME +
        "," +
        TabReportRecordModel.LATLON +
        "," +
        TabReportRecordModel.IS_CHECKED +
        "," +
        TabReportRecordModel.CHECK_WAY +
        "," +
        TabReportRecordModel.CHECK_TIME +
        "," +
        TabReportRecordModel.CHECKER_NAME +
        ") VALUES('$_id','$_inspectionId','$_location','$_explain','$_imagesPath','$_imagesUrl','$_isUpload','$_time','$_latlon','$_isChecked','$_checkWay','$_checkTime','$_checkerName')";
    await db.transaction((txn) async {
      await txn.rawInsert(sql);
    });
    await db.close();
    print("插入" + TabReportRecordModel.TAB_NAME + "成功" + sql);
  }

  // 查询所有用户异常上报记录
  queryAll() {
    String sql = 'SELECT * FROM ' + TabReportRecordModel.TAB_NAME;
    return _query(sql, null);
  }

  // 根据巡查记录id查询异常上报记录
  queryByInspectionId(String inspectionId) {
    String sql = 'SELECT * FROM ' +
        TabReportRecordModel.TAB_NAME +
        " WHERE " +
        TabReportRecordModel.INSPECTION_ID +
        " = ?";
    return _query(sql, [inspectionId]);
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

    List<TabReportRecordModel> tabReportRecordModelList = new List();
    for (var item in list) {
      TabReportRecordModel tabReportRecordModel = _convertToModel(item);
      tabReportRecordModelList.add(tabReportRecordModel);
    }
    return tabReportRecordModelList;
  }

  TabReportRecordModel _convertToModel(Map item) {
    TabReportRecordModel tabReportRecordModel = new TabReportRecordModel();
    tabReportRecordModel.id = item[TabReportRecordModel.ID];
    tabReportRecordModel.inspectionId =
        item[TabReportRecordModel.INSPECTION_ID];
    tabReportRecordModel.location = item[TabReportRecordModel.LOCATION];
    tabReportRecordModel.explain = item[TabReportRecordModel.EXPLAIN];
    tabReportRecordModel.imagesPath = item[TabReportRecordModel.IMAGES_PATH];
    tabReportRecordModel.imagesUrl = item[TabReportRecordModel.IMAGES_URL];
    tabReportRecordModel.isUpload = item[TabReportRecordModel.IS_UPLOAD];
    tabReportRecordModel.time = item[TabReportRecordModel.TIME];
    tabReportRecordModel.latlon = item[TabReportRecordModel.LATLON];
    tabReportRecordModel.isChecked = item[TabReportRecordModel.IS_CHECKED];
    tabReportRecordModel.checkWay = item[TabReportRecordModel.CHECK_WAY];
    tabReportRecordModel.checkTime = item[TabReportRecordModel.CHECK_TIME];
    tabReportRecordModel.checkerName = item[TabReportRecordModel.CHECKER_NAME];
    return tabReportRecordModel;
  }

  deleteById(String id) async {
    String _dbPath = await FileUtils.getDatabasePath();
    Database db = await openDatabase(_dbPath);
    String sql = "DELETE FROM " +
        TabReportRecordModel.TAB_NAME +
        " WHERE " +
        TabReportRecordModel.ID +
        " = ?";
    int count = await db.rawDelete(sql, [id]);
    if (count == 1) {
      return true;
    } else {
      return false;
    }
//    await db.close();
  }

/// 上传处置后，更新本地信息
  static updateDisposalStateWithRecordId(TabReportRecordModel model) async {
    String _dbPath = await FileUtils.getDatabasePath();
    Database db = await openDatabase(_dbPath);
    String update = "UPDATE " +
        TabReportRecordModel.TAB_NAME +
        " SET isChecked = 1 , checkTime = ? , checkWay = ? , checkerName = ? WHERE id = ?";
    print(update);
    print(
        '${model.checkTime},${model.checkWay},${model.checkerName},${model.id}');
    await db.rawUpdate(
        update, [model.checkTime, model.checkWay, model.checkerName, model.id]);
  }
}
