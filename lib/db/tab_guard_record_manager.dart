// import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mdc_bhl/utils/file_utils.dart';

/*
 * 保卫科记录（预留）
 */
class TabGuardRecordModel {
  static const String TAB_NAME = "tab_guard_record";

  static const String ID = "id";
  static const String INSPECTION_ID = "inspectionId";
  static const String INSPECTION_TYPE = "inspectionType"; // 巡查记录类型
  static const String INSPECTION_Content_ID = "inspectionContentId";
  static const String INSPECTOR_ID = "inspectorId";
  static const String INSPECTOR_NAME = "inspectorName";
  static const String RECORD_TYPE = "recordType";
  static const String RECORD_STATE = "recordState";
  static const String RECORD_TITLE = "recordTitle";
  static const String IS_ABNORMAL = "isAbnormal";
  static const String ABNORMAL_EXPLAIN = "abnormalExplain";
  static const String ABNORMAL_IMAGES_PATH = "abnormalImagesPath";
  static const String ABNORMAL_IMAGES_URL = "abnormalImagesUrl";
  static const String TEMPERATURE = "temperature";
  static const String HUMIDITY = "humidity";
  static const String IS_OPEN = "isOpen";
  static const String INPUT = "input";
  static const String IS_UPLOAD = "is_upload";
  static const String TIME = "time";
  static const String LATLON = "latlon";
  static const String SORT = "sort";

  String id; // 巡查内容记录id
  String inspectionId; // 巡查记录id
  int inspectionType; // 0-设备科日巡查记录表，1-设备夜间巡查记录表，2-保卫科日常巡查记录表
  String inspectionContentId; // 巡查内容id
  String inspectorId; // 巡查人id
  String inspectorName; // 巡查人名称（REALNAME）
  int recordType; // 记录类型 0-异常，1-正常，2-开，3-关，4-有，5-无，6-温湿度，7-录入（用于移动端）
  int recordState; // 记录状态 0-异常，1-正常，2-开，3-关，4-有，5-无，null-温湿度|录入（用于服务端）
  String recordTitle; // 记录标题
  int isAbnormal; // 是否异常 0-未操作，1-正常，2-异常
  String abnormalExplain; // 异常情况说明
  String abnormalImagesPath; // 异常照片本地路径
  String abnormalImagesUrl; // 异常照片网络路径
  String temperature; // 温度
  String humidity; // 湿度
  int isOpen; // 是否开启 0-开，1-关
  String input; // 录入内容
  int isUpload; // 是否提交 0-未提交，1-已提交
  String time; // 保存或提交时间
  String latlon; // 巡查点经纬度（预留字段）
  int sort; // 顺序

  @override
  String toString() {
    return 'TabGuardRecordModel{id: $id, inspectionId: $inspectionId, inspectionType: $inspectionType, inspectionContentId: $inspectionContentId, inspectorId: $inspectorId, inspectorName: $inspectorName, recordType: $recordType, recordState: $recordState, recordTitle: $recordTitle, isAbnormal: $isAbnormal, abnormalExplain: $abnormalExplain, abnormalImagesPath: $abnormalImagesPath, abnormalImagesUrl: $abnormalImagesUrl, temperature: $temperature, humidity: $humidity, isOpen: $isOpen, input: $input, isUpload: $isUpload, time: $time, latlon: $latlon, sort: $sort}';
  }
}

class TabGuardRecordManager {
  // 插入保卫科巡查内容
  insert(TabGuardRecordModel tabGuardRecordModel) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String _dbPath = prefs.getString("DB_PATH");
    String _dbPath = await FileUtils.getDatabasePath();


    String _id = tabGuardRecordModel.id;
    String _inspectionId = tabGuardRecordModel.inspectionId;
    int _inspectionType = (tabGuardRecordModel.inspectionType == null ? 0 : tabGuardRecordModel.inspectionType);
    String _inspectionContentId = tabGuardRecordModel.inspectionContentId;
    String _inspectorId = tabGuardRecordModel.inspectorId;
    String _inspectorName = tabGuardRecordModel.inspectorName;
    int _recordType = (tabGuardRecordModel.recordType == null ? 0 : tabGuardRecordModel.recordType);
    int _recordState = (tabGuardRecordModel.recordState == null ? 0 : tabGuardRecordModel.recordState);
    String _recordTitle = tabGuardRecordModel.recordTitle;
    int _isAbnormal = (tabGuardRecordModel.isAbnormal == null ? 0 : tabGuardRecordModel.isAbnormal);
    String _abnormalExplain = tabGuardRecordModel.abnormalExplain;
    String _abnormalImagesPath = tabGuardRecordModel.abnormalImagesPath;
    String _abnormalImagesUrl = tabGuardRecordModel.abnormalImagesUrl;
    String _temperature = tabGuardRecordModel.temperature;
    String _humidity = tabGuardRecordModel.humidity;
    int _isOpen = (tabGuardRecordModel.isOpen == null ? 0 : tabGuardRecordModel.isOpen);
    String _input = tabGuardRecordModel.input;
    int _isUpload = (tabGuardRecordModel.isUpload == null ? 0 : tabGuardRecordModel.isUpload);
    String _time = tabGuardRecordModel.time;
    String _latlon = tabGuardRecordModel.latlon;
    int _sort = (tabGuardRecordModel.sort == null ? 0 : tabGuardRecordModel.sort);

    Database db = await openDatabase(_dbPath);
    String sql = "INSERT OR REPLACE INTO " + TabGuardRecordModel.TAB_NAME +
        "(" + TabGuardRecordModel.ID +
        "," + TabGuardRecordModel.INSPECTION_ID +
        "," + TabGuardRecordModel.INSPECTION_TYPE +
        "," + TabGuardRecordModel.INSPECTION_Content_ID +
        "," + TabGuardRecordModel.INSPECTOR_ID +
        "," + TabGuardRecordModel.INSPECTOR_NAME +
        "," + TabGuardRecordModel.RECORD_TYPE +
        "," + TabGuardRecordModel.RECORD_STATE +
        "," + TabGuardRecordModel.RECORD_TITLE +
        "," + TabGuardRecordModel.IS_ABNORMAL +
        "," + TabGuardRecordModel.ABNORMAL_EXPLAIN +
        "," + TabGuardRecordModel.ABNORMAL_IMAGES_PATH +
        "," + TabGuardRecordModel.ABNORMAL_IMAGES_URL +
        "," + TabGuardRecordModel.TEMPERATURE +
        "," + TabGuardRecordModel.HUMIDITY +
        "," + TabGuardRecordModel.IS_OPEN +
        "," + TabGuardRecordModel.INPUT +
        "," + TabGuardRecordModel.IS_UPLOAD +
        "," + TabGuardRecordModel.TIME +
        "," + TabGuardRecordModel.LATLON +
        "," + TabGuardRecordModel.SORT +
        ") VALUES('$_id','$_inspectionId','$_inspectionType','$_inspectionContentId','$_inspectorId','$_inspectorName','$_recordType','$_recordState','$_recordTitle','$_isAbnormal','$_abnormalExplain','$_abnormalImagesPath','$_abnormalImagesUrl','$_temperature','$_humidity','$_isOpen','$_input','$_isUpload','$_time','$_latlon','$_sort')";
    await db.transaction((txn) async {
       await txn.rawInsert(sql);
    });
    await db.close();
    print("插入" + TabGuardRecordModel.TAB_NAME + "成功");
  }

  // 查询所有保卫科巡查内容
  queryAll() {
    String sql = 'SELECT * FROM ' + TabGuardRecordModel.TAB_NAME;
    return _query(sql, null);
  }

  // 根据巡查记录id查询设备科巡查内容
  queryByInspectionId(String inspectionId) {
    String sql = 'SELECT * FROM ' + TabGuardRecordModel.TAB_NAME + " WHERE " + TabGuardRecordModel.INSPECTION_ID + " = ?";
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

    List<TabGuardRecordModel> tabGuardRecordModelList = new List();
    for (var item in list) {
      TabGuardRecordModel tabGuardRecordModel = _convertToModel(item);
      tabGuardRecordModelList.add(tabGuardRecordModel);
    }
    return tabGuardRecordModelList;
  }

  TabGuardRecordModel _convertToModel(Map item) {
    TabGuardRecordModel tabGuardRecordModel = new TabGuardRecordModel();
    tabGuardRecordModel.id = item[TabGuardRecordModel.ID];
    tabGuardRecordModel.inspectionId = item[TabGuardRecordModel.INSPECTION_ID];
    tabGuardRecordModel.inspectionType = item[TabGuardRecordModel.INSPECTION_TYPE];
    tabGuardRecordModel.inspectionContentId = item[TabGuardRecordModel.INSPECTION_Content_ID];
    tabGuardRecordModel.inspectorId = item[TabGuardRecordModel.INSPECTOR_ID];
    tabGuardRecordModel.inspectorName = item[TabGuardRecordModel.INSPECTOR_NAME];
    tabGuardRecordModel.recordType = item[TabGuardRecordModel.RECORD_TYPE];
    tabGuardRecordModel.recordState = item[TabGuardRecordModel.RECORD_STATE];
    tabGuardRecordModel.recordTitle = item[TabGuardRecordModel.RECORD_TITLE];
    tabGuardRecordModel.isAbnormal = item[TabGuardRecordModel.IS_ABNORMAL];
    tabGuardRecordModel.abnormalExplain = item[TabGuardRecordModel.ABNORMAL_EXPLAIN];
    tabGuardRecordModel.abnormalImagesPath = item[TabGuardRecordModel.ABNORMAL_IMAGES_PATH];
    tabGuardRecordModel.abnormalImagesUrl = item[TabGuardRecordModel.ABNORMAL_IMAGES_URL];
    tabGuardRecordModel.temperature = item[TabGuardRecordModel.TEMPERATURE];
    tabGuardRecordModel.humidity = item[TabGuardRecordModel.HUMIDITY];
    tabGuardRecordModel.isOpen = item[TabGuardRecordModel.IS_OPEN];
    tabGuardRecordModel.input = item[TabGuardRecordModel.INPUT];
    tabGuardRecordModel.isUpload = item[TabGuardRecordModel.IS_UPLOAD];
    tabGuardRecordModel.time = item[TabGuardRecordModel.TIME];
    tabGuardRecordModel.latlon = item[TabGuardRecordModel.LATLON];
    tabGuardRecordModel.sort = item[TabGuardRecordModel.SORT];
    return tabGuardRecordModel;
  }
}