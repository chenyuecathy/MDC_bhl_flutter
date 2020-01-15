import 'dart:convert';
import 'dart:core';

import 'package:mdc_bhl/model/task.dart';
import 'package:mdc_bhl/utils/date_utils.dart';
import 'package:mdc_bhl/utils/file_utils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/*
 * 设备科记录
 */
class TabDeviceRecordModel {
  static const String TAB_NAME = "tab_device_record";

  static const String ID = "id"; // 巡查内容记录id
  static const String INSPECTION_ID = "inspectionId"; // 巡查记录id
  static const String INSPECTION_TYPE = "inspectionType"; // 巡查记录类型
  static const String INSPECTION_CONTENT_ID = "inspectionContentId"; // 巡查内容id
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
  static const String IS_CHECKED = "isChecked";
  static const String CHECK_WAY = "checkWay";
  static const String CHECK_TIME = "checkTime";
  static const String CHECKER_NAME = "checkerName";

  String id; // 巡查内容记录id
  String inspectionId; // 巡查记录id
  int inspectionType; // 0-设备科日巡查记录表，1-设备夜间巡查记录表，2-保卫科日常巡查记录表
  String inspectionContentId; // 巡查内容id
  String inspectorId; // 巡查人id
  String inspectorName; // 巡查人名称（REALNAME）
  int recordType; // 记录类型 0-异常，1-正常，2-开，3-关，4-有，5-无，6-温湿度，7-录入（用于移动端）【注意初始值为-1:代表未初始化】
  int recordState; // 记录状态 0-异常，1-正常，2-开，3-关，4-有，5-无，null-温湿度|录入（用于服务端）【此处用于移动端记录巡查内容类型  0-正常异常 1-温湿度 2-开关 3-有无 4-录入】
  String recordTitle; // 巡查内容，即巡查地点
  String abnormalExplain; // 异常情况说明
  String abnormalImagesPath; // 异常照片本地路径
  String abnormalImagesUrl; // 异常照片网络路径
  String temperature; // 温度
  String humidity; // 湿度
  int isAbnormal; // 是否异常 -1：未操作，0：异常，1：正常   未用到
  int isOpen; // 是否开启 0-关，1-开  未用到
  String input; // 录入内容   未用到
  int isUpload; // 是否提交 0-未提交，1-已提交
  String time; // 保存或提交时间
  String latlon; // 巡查点经纬度（预留字段）
  int sort; // 顺序
  int isChecked; // 是否核查 0-未核查，1-已核查
  String checkWay; // 核查方式
  String checkTime; // 核查时间
  String checkerName; // 核查人名称

  clone(TabDeviceRecordModel model) {
    this.id = model.id;
    this.inspectionId = model.inspectionId;
    this.inspectionType = model.inspectionType;
    this.inspectionContentId = model.inspectionContentId;
    this.inspectorId = model.inspectorId;
    this.inspectorName = model.inspectorName;
    this.recordType = model.recordType;
    this.recordState = model.recordState;
    this.recordTitle = model.recordTitle;
    this.abnormalExplain = model.abnormalExplain;
    this.abnormalImagesPath = model.abnormalImagesPath;
    this.abnormalImagesUrl = model.abnormalImagesUrl;
    this.temperature = model.temperature;
    this.humidity = model.humidity;
    this.isAbnormal = model.isAbnormal;
    this.isOpen = model.isOpen;
    this.input = model.input;
    this.isUpload = model.isUpload;
    this.time = model.time;
    this.latlon = model.latlon;
    this.sort = model.sort;
    this.isChecked = model.isChecked;
    this.checkWay = model.checkWay;
    this.checkTime = model.checkTime;
    this.checkerName = model.checkerName;
  }

  @override
  String toString() {
    return 'TabDeviceRecordModel{id: $id, inspectionId: $inspectionId, inspectionType: $inspectionType, inspectionContentId: $inspectionContentId, inspectorId: $inspectorId, inspectorName: $inspectorName, recordType: $recordType, recordState: $recordState, recordTitle: $recordTitle, abnormalExplain: $abnormalExplain, abnormalImagesPath: $abnormalImagesPath, abnormalImagesUrl: $abnormalImagesUrl, temperature: $temperature, humidity: $humidity, isAbnormal: $isAbnormal, isOpen: $isOpen, input: $input, isUpload: $isUpload, time: $time, latlon: $latlon, sort: $sort, isChecked: $isChecked, checkWay: $checkWay, checkTime: $checkTime, checkerName: $checkerName}';
  }

  List encodeToJson(List<TabDeviceRecordModel> list) {
    List jsonList = List();
    list.map((item) => jsonList.add(item.toJson())).toList();
    return jsonList;
  }

// type：请传入recordstate
  Map<String, dynamic> toJson() {
    // 0 正常异常 1温湿度  2 开关 3 有无 4 录入
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Xcjlid'] = this.inspectionId;
    data['Xcnrid'] = this.inspectionContentId;
    data['Jd'] = 0.0;
    data['Wd'] = 0.0;

    if (this.recordState == 1 /*type == 1*/) {
      // 温湿度
      print('调用温湿度上传接口了！');
      data['Temp'] = this.temperature ?? 0.0;
      data['Hum'] = this.humidity ?? 0.0;
    } else {
      print('调用不是温湿度的其它上传接口了！${this.recordState}}');
      data['Qksm'] = this.abnormalExplain;
      data['Zt'] = this.recordType ?? 0;
    }

    return data;
  }
}

class TabDeviceRecordManager {
  // 插入巡查内容
  insert(TabDeviceRecordModel tabDeviceRecordModel) async {
    String _dbPath = await FileUtils.getDatabasePath();

    String _id = tabDeviceRecordModel.id;
    String _inspectionId = tabDeviceRecordModel.inspectionId;
    int _inspectionType = (tabDeviceRecordModel.inspectionType == null
        ? 0
        : tabDeviceRecordModel.inspectionType);
    String _inspectionContentId = tabDeviceRecordModel.inspectionContentId;
    String _inspectorId = tabDeviceRecordModel.inspectorId;
    String _inspectorName = tabDeviceRecordModel.inspectorName;
    int _recordType = (tabDeviceRecordModel.recordType == null
        ? 0
        : tabDeviceRecordModel.recordType);
    int _recordState = (tabDeviceRecordModel.recordState == null
        ? 0
        : tabDeviceRecordModel.recordState);
    String _recordTitle = tabDeviceRecordModel.recordTitle;
    int _isAbnormal = (tabDeviceRecordModel.isAbnormal == null
        ? 0
        : tabDeviceRecordModel.isAbnormal);
    String _abnormalExplain = tabDeviceRecordModel.abnormalExplain;
    String _abnormalImagesPath = tabDeviceRecordModel.abnormalImagesPath;
    String _abnormalImagesUrl = tabDeviceRecordModel.abnormalImagesUrl;
    String _temperature = tabDeviceRecordModel.temperature;
    String _humidity = tabDeviceRecordModel.humidity;
    int _isOpen =
        (tabDeviceRecordModel.isOpen == null ? 0 : tabDeviceRecordModel.isOpen);
    String _input = tabDeviceRecordModel.input;
    int _isUpload = (tabDeviceRecordModel.isUpload == null
        ? 0
        : tabDeviceRecordModel.isUpload);
    String _time = tabDeviceRecordModel.time;
    String _latlon = tabDeviceRecordModel.latlon;
    int _sort =
        (tabDeviceRecordModel.sort == null ? 0 : tabDeviceRecordModel.sort);
    int _isChecked = (tabDeviceRecordModel.isChecked == null ? 0 : tabDeviceRecordModel.isChecked);
    String _checkWay = tabDeviceRecordModel.checkWay;
    String _checkTime = tabDeviceRecordModel.checkTime;
    String _checkerName = tabDeviceRecordModel.checkerName;

    Database db = await openDatabase(_dbPath);
    String sql = "INSERT OR REPLACE INTO " +
        TabDeviceRecordModel.TAB_NAME +
        "(" +
        TabDeviceRecordModel.ID +
        "," +
        TabDeviceRecordModel.INSPECTION_ID +
        "," +
        TabDeviceRecordModel.INSPECTION_TYPE +
        "," +
        TabDeviceRecordModel.INSPECTION_CONTENT_ID +
        "," +
        TabDeviceRecordModel.INSPECTOR_ID +
        "," +
        TabDeviceRecordModel.INSPECTOR_NAME +
        "," +
        TabDeviceRecordModel.RECORD_TYPE +
        "," +
        TabDeviceRecordModel.RECORD_STATE +
        "," +
        TabDeviceRecordModel.RECORD_TITLE +
        "," +
        TabDeviceRecordModel.IS_ABNORMAL +
        "," +
        TabDeviceRecordModel.ABNORMAL_EXPLAIN +
        "," +
        TabDeviceRecordModel.ABNORMAL_IMAGES_PATH +
        "," +
        TabDeviceRecordModel.ABNORMAL_IMAGES_URL +
        "," +
        TabDeviceRecordModel.TEMPERATURE +
        "," +
        TabDeviceRecordModel.HUMIDITY +
        "," +
        TabDeviceRecordModel.IS_OPEN +
        "," +
        TabDeviceRecordModel.INPUT +
        "," +
        TabDeviceRecordModel.IS_UPLOAD +
        "," +
        TabDeviceRecordModel.TIME +
        "," +
        TabDeviceRecordModel.LATLON +
        "," +
        TabDeviceRecordModel.SORT +
        "," +
        TabDeviceRecordModel.IS_CHECKED +
        "," +
        TabDeviceRecordModel.CHECK_WAY +
        "," +
        TabDeviceRecordModel.CHECK_TIME +
        "," +
        TabDeviceRecordModel.CHECKER_NAME +
        ") VALUES('$_id','$_inspectionId','$_inspectionType','$_inspectionContentId','$_inspectorId','$_inspectorName','$_recordType','$_recordState','$_recordTitle','$_isAbnormal','$_abnormalExplain','$_abnormalImagesPath','$_abnormalImagesUrl','$_temperature','$_humidity','$_isOpen','$_input','$_isUpload','$_time','$_latlon','$_sort','$_isChecked','$_checkWay','$_checkTime','$_checkerName')";
    await db.transaction((txn) async {
      await txn.rawInsert(sql);
    });
    // await db.close();
    print("插入" + TabDeviceRecordModel.TAB_NAME + "成功 =====" + sql);
  }

  // 查询所有���查内容
  queryAll() {
    String sql = 'SELECT * FROM ' + TabDeviceRecordModel.TAB_NAME;
    return _query(sql, null);
  }

  // 查询未操作巡查内容ORDER BY time
  queryUnoperatedOrderTime() {
    String sql = 'SELECT * FROM ' +
        TabDeviceRecordModel.TAB_NAME +
        " WHERE recordType!=-1 ORDER BY time DESC";
    return _query(sql, null);
  }

  // 查询未操作巡查内容ORDER BY sort
  queryUnoperatedOrderSort() {
    String sql = 'SELECT * FROM ' +
        TabDeviceRecordModel.TAB_NAME +
        " WHERE recordType!=-1 ORDER BY sort DESC";
    return _query(sql, null);
  }

  // 根据巡查记录id查询巡查内容
  queryUploadRecordsByUserid(String userid, int inspectionType) {
    String sql = 'SELECT * FROM ' +
        TabDeviceRecordModel.TAB_NAME +
        " WHERE inspectionType = ? AND inspectorId = ? AND  is_upload = 1  ORDER BY time DESC";
        //     String sql = 'SELECT * FROM ' +
        // TabDeviceRecordModel.TAB_NAME +
        // " WHERE inspectionType = ? AND  is_upload = 1  ORDER BY time DESC";
    return _query(sql, [inspectionType, userid]);
  }

  // 根据巡查记录id查询巡查内容
  queryByInspectionId(String inspectionId) {
    String sql = 'SELECT * FROM ' +
        TabDeviceRecordModel.TAB_NAME +
        " WHERE " +
        TabDeviceRecordModel.INSPECTION_ID +
        " = ? AND recordType!=-1 ORDER BY sort ASC";
    return _query(sql, [inspectionId]);
  }

  // 根据inspectionId和inspectionContentId查询巡查内容
  queryByInspectionIdAndInspectionContentId(
      String inspectionId, String inspectionContentId) {
    String sql = 'SELECT * FROM ' +
        TabDeviceRecordModel.TAB_NAME +
        " WHERE " +
        TabDeviceRecordModel.INSPECTION_ID +
        " = ? AND " +
        TabDeviceRecordModel.INSPECTION_CONTENT_ID +
        " = ?";
    return _query(sql, [inspectionId, inspectionContentId]);
  }

  // // 根据inspectionId和userId查询巡查内容
  // queryByInspectionIdAndUserId(String inspectionId, String userId) {
  //   String sql = 'SELECT * FROM ' +
  //       TabDeviceRecordModel.TAB_NAME +
  //       " WHERE " +
  //       TabDeviceRecordModel.INSPECTION_ID +
  //       " = ?  ORDER BY sort ASC";

  //   return _query(sql, [inspectionId]);
  // }

  /* 根据巡查id和记录上传状态获取设备科的巡查记录
 @paramater:upload -1时代表不关心isupload字段的情况
 */
  static getCurrentCircleDeviceRecords(String inspectionId, int upload) async {
    // List<TabDeviceRecordModel> newTaskModels = [];
    // List<String> _inspectionContentList = []; // 巡查内容去重List
    print('getCurrentCircleDeviceRecords $inspectionId $upload');
    List deviceRecords =
        await TabDeviceRecordManager().queryDeviceRecords(inspectionId, upload);
    return deviceRecords;

    // for (var item in tabDeviceRecordModelList) {
    //   if (!_inspectionContentList.contains(item.inspectionContentId)) {
    //     newTaskModels.add(item);
    //     _inspectionContentList.add(item.inspectionContentId);
    //   }
    // }
    // return newTaskModels;
  }

  // 根据inspectionId和userId查询巡查内容
  // upload -1时代表不关心isupload字段的情况
  queryDeviceRecords(String inspectionId, int upload) {
    if (upload != -1) {
      String sql = 'SELECT * FROM ' +
          TabDeviceRecordModel.TAB_NAME +
          " WHERE " +
          TabDeviceRecordModel.INSPECTION_ID +
          " = ? AND is_upload = ? ORDER BY sort ASC";

      return _query(sql, [inspectionId, upload]);
    } else {
      String sql = 'SELECT * FROM ' +
          TabDeviceRecordModel.TAB_NAME +
          " WHERE " +
          TabDeviceRecordModel.INSPECTION_ID +
          " = ? ORDER BY sort ASC";

      return _query(sql, [inspectionId]);
    }
  }

  // 根据inspectionId和userId查询巡查内容
  // upload -1时代表不关心isupload字段的情况
  queryGuardRecords(String inspectionId, int upload) {
    if (upload != -1) {
      String sql = 'SELECT * FROM ' +
          TabDeviceRecordModel.TAB_NAME +
          " WHERE " +
          TabDeviceRecordModel.INSPECTION_ID +
          " = ? AND is_upload = ? AND isOpen = 1 ORDER BY sort ASC";

      return _query(sql, [inspectionId, upload]);
    } else {
      String sql = 'SELECT * FROM ' +
          TabDeviceRecordModel.TAB_NAME +
          " WHERE " +
          TabDeviceRecordModel.INSPECTION_ID +
          " = ? AND isOpen = 1 ORDER BY sort ASC";

      return _query(sql, [inspectionId]);
    }
  }

/* 根据巡查id和记录上传状态获取设备科的巡查记录
 @paramater:upload -1时代表不关心isupload字段的情况
 */
  static getCurrentCircleGuardRecords(String inspectionId, int upload) async {
    TabDeviceRecordManager _tabDeviceRecordManager = TabDeviceRecordManager();
    List tabDeviceRecordModelList =
        await _tabDeviceRecordManager.queryGuardRecords(inspectionId, upload);

    return tabDeviceRecordModelList;
  }

/// 上传处置后，更新本地信息
  static updateDisposalStateWithRecordId(TabDeviceRecordModel model) async {
    String _dbPath = await FileUtils.getDatabasePath();
    Database db = await openDatabase(_dbPath);
    String update = "UPDATE " +
        TabDeviceRecordModel.TAB_NAME +
        " SET isChecked = 1 , checkTime = ? , checkWay = ? , checkerName = ? WHERE id = ?";
        print(update  );
        print('${model.checkTime},${model.checkWay},${model.checkerName},${model.id}');
    await db.rawUpdate(update, [model.checkTime,model.checkWay,model.checkerName,model.id]);
  }

  static updateUploadStateWithInspectionid(String insepectionid) async {
    String _dbPath = await FileUtils.getDatabasePath();

    Database db = await openDatabase(_dbPath);
    String update = "UPDATE " +
        TabDeviceRecordModel.TAB_NAME +
        " SET is_upload = 1 WHERE is_upload = 0 AND inspectionId = ?";
    await db.rawUpdate(update, [insepectionid]);
  }

  ///  根据巡查内容ID更新上传状态
  static updateUploadStateWithInspectionContentIds( List<String> inspectionContentIds) async {
    List updateSqls = [];
    String updateTime = DateUtils.getCurrentTime();
    for (String insepectionContentId in inspectionContentIds) {
      String updateSql =
          "UPDATE ${TabDeviceRecordModel.TAB_NAME} SET is_upload = 1 , checkTime = '$updateTime'  WHERE ${TabDeviceRecordModel.INSPECTION_CONTENT_ID} = '$insepectionContentId'";
      print(updateSql);
      updateSqls.add(updateSql);
    }

    String dbPath = await FileUtils.getDatabasePath();
    Database db = await openDatabase(dbPath);
    await db.transaction((txn) async {
      for (var sql in updateSqls) {
        int update = await txn.rawUpdate(sql);
        print('update $update');
      }
    });
  }

  ///  根据巡查ID更新是否显示状态状态
  static updatOpenStateWithInspectionId(String inspectionId) async {
    String updateSql =
        "UPDATE ${TabDeviceRecordModel.TAB_NAME} SET isOpen = 0  WHERE ${TabDeviceRecordModel.INSPECTION_ID} = '$inspectionId'";

    String dbPath = await FileUtils.getDatabasePath();
    Database db = await openDatabase(dbPath);
    await db.transaction((txn) async {
      int update = await txn.rawUpdate(updateSql);
      print('update $update');
    });
  }

  /* 批量生产数据  
  @parameter
  *jsonString: 巡查内容json （String类型）
  *inspectionType: 巡查类型 0	设备科日巡查记录表  1	设备夜间巡查记录表  2	保卫科日常巡查记录表
  */
  static insertBatchData(dynamic jsonString, int inspectionType) async {
    Map<String, dynamic> _dictionary = json.decode(jsonString);
    String _inspectionId = _dictionary['Xcjlid'];
    dynamic _inspectionContentList = _dictionary['Xcnr'];
    // print('insertBatchData' + jsonString);

    List<String> sqlList = [];
    for (int i = 0; i < _inspectionContentList.length; i++) {
      TaskModel _taskModel = TaskModel.fromJson(_inspectionContentList[i]);
      TabDeviceRecordModel tabDeviceRecordModel = new TabDeviceRecordModel();
      tabDeviceRecordModel.id = Uuid().v1();
      tabDeviceRecordModel.inspectionId = _inspectionId;
      tabDeviceRecordModel.inspectionType = inspectionType;
      tabDeviceRecordModel.inspectionContentId = _taskModel.id;
      tabDeviceRecordModel.inspectorId = '';
      tabDeviceRecordModel.inspectorName = '';
      tabDeviceRecordModel.recordType = -1;
      tabDeviceRecordModel.recordState = _taskModel.nrlx;
      tabDeviceRecordModel.recordTitle = _taskModel.xcnr;
      tabDeviceRecordModel.isAbnormal = -1; // -1：未操作，0：异常，1：正常
      tabDeviceRecordModel.abnormalExplain = "";
      tabDeviceRecordModel.abnormalImagesPath = "";
      tabDeviceRecordModel.abnormalImagesUrl = "";
      tabDeviceRecordModel.temperature = "";
      tabDeviceRecordModel.humidity = "";
      tabDeviceRecordModel.isOpen =
          1; // 0-关，1-开  本系统用于判断保卫科的数据是否最新轮的，默认是1，提交后置为0，，重新插入一组数据
      tabDeviceRecordModel.input = "";
      tabDeviceRecordModel.isUpload = 0;
      tabDeviceRecordModel.time = DateUtils.getCurrentTime();
      tabDeviceRecordModel.latlon = "";
      tabDeviceRecordModel.sort = i;
      tabDeviceRecordModel.isChecked = 0;
      tabDeviceRecordModel.checkWay = "";
      tabDeviceRecordModel.checkTime = "";
      tabDeviceRecordModel.checkerName = "";
      TabDeviceRecordManager tabDeviceRecordManager = TabDeviceRecordManager();
      String sql =
          await tabDeviceRecordManager._modelToSql(tabDeviceRecordModel);
      sqlList.add(sql);
    }
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String _dbPath = prefs.getString("DB_PATH");
    String _dbPath = await FileUtils.getDatabasePath();
    print('open path:::::: ' + _dbPath);
    // print(sqlList);

    try {
      Database db = await openDatabase(_dbPath);
      print(db.isOpen);
      await db.transaction((txn) async {
        for (var item in sqlList) {
          int index = await txn.rawInsert(item);
          print("inserted: $index");
        }
      });
      // await db.close();
      // print("批量插入" + TabDeviceRecordModel.TAB_NAME + "成功");
    } catch (e) {
      print(e.toString());
    }
  }

  // 批量生产数据中model转sql
  _modelToSql(TabDeviceRecordModel tabDeviceRecordModel) async {
    String _id = tabDeviceRecordModel.id;
    String _inspectionId = tabDeviceRecordModel.inspectionId;
    int _inspectionType = (tabDeviceRecordModel.inspectionType == null
        ? 0
        : tabDeviceRecordModel.inspectionType);
    String _inspectionContentId = tabDeviceRecordModel.inspectionContentId;
    String _inspectorId = tabDeviceRecordModel.inspectorId;
    String _inspectorName = tabDeviceRecordModel.inspectorName;
    int _recordType = (tabDeviceRecordModel.recordType == null
        ? 0
        : tabDeviceRecordModel.recordType);
    int _recordState = (tabDeviceRecordModel.recordState == null
        ? 0
        : tabDeviceRecordModel.recordState);
    String _recordTitle = tabDeviceRecordModel.recordTitle;
    int _isAbnormal = (tabDeviceRecordModel.isAbnormal == null
        ? 0
        : tabDeviceRecordModel.isAbnormal);
    String _abnormalExplain = tabDeviceRecordModel.abnormalExplain;
    String _abnormalImagesPath = tabDeviceRecordModel.abnormalImagesPath;
    String _abnormalImagesUrl = tabDeviceRecordModel.abnormalImagesUrl;
    String _temperature = tabDeviceRecordModel.temperature;
    String _humidity = tabDeviceRecordModel.humidity;
    int _isOpen =
        (tabDeviceRecordModel.isOpen == null ? 0 : tabDeviceRecordModel.isOpen);
    String _input = tabDeviceRecordModel.input;
    int _isUpload = (tabDeviceRecordModel.isUpload == null
        ? 0
        : tabDeviceRecordModel.isUpload);
    String _time = tabDeviceRecordModel.time;
    String _latlon = tabDeviceRecordModel.latlon;
    int _sort =
        (tabDeviceRecordModel.sort == null ? 0 : tabDeviceRecordModel.sort);
    int _isChecked = (tabDeviceRecordModel.isChecked == null ? 0 : tabDeviceRecordModel.isChecked);
    String _checkWay = tabDeviceRecordModel.checkWay;
    String _checkTime = tabDeviceRecordModel.checkTime;
    String _checkerName = tabDeviceRecordModel.checkerName;
    String sql = "INSERT OR REPLACE INTO " +
        TabDeviceRecordModel.TAB_NAME +
        "(" +
        TabDeviceRecordModel.ID +
        "," +
        TabDeviceRecordModel.INSPECTION_ID +
        "," +
        TabDeviceRecordModel.INSPECTION_TYPE +
        "," +
        TabDeviceRecordModel.INSPECTION_CONTENT_ID +
        "," +
        TabDeviceRecordModel.INSPECTOR_ID +
        "," +
        TabDeviceRecordModel.INSPECTOR_NAME +
        "," +
        TabDeviceRecordModel.RECORD_TYPE +
        "," +
        TabDeviceRecordModel.RECORD_STATE +
        "," +
        TabDeviceRecordModel.RECORD_TITLE +
        "," +
        TabDeviceRecordModel.IS_ABNORMAL +
        "," +
        TabDeviceRecordModel.ABNORMAL_EXPLAIN +
        "," +
        TabDeviceRecordModel.ABNORMAL_IMAGES_PATH +
        "," +
        TabDeviceRecordModel.ABNORMAL_IMAGES_URL +
        "," +
        TabDeviceRecordModel.TEMPERATURE +
        "," +
        TabDeviceRecordModel.HUMIDITY +
        "," +
        TabDeviceRecordModel.IS_OPEN +
        "," +
        TabDeviceRecordModel.INPUT +
        "," +
        TabDeviceRecordModel.IS_UPLOAD +
        "," +
        TabDeviceRecordModel.TIME +
        "," +
        TabDeviceRecordModel.LATLON +
        "," +
        TabDeviceRecordModel.SORT +
        "," +
        TabDeviceRecordModel.IS_CHECKED +
        "," +
        TabDeviceRecordModel.CHECK_WAY +
        "," +
        TabDeviceRecordModel.CHECK_TIME +
        "," +
        TabDeviceRecordModel.CHECKER_NAME +
        ") VALUES('$_id','$_inspectionId','$_inspectionType','$_inspectionContentId','$_inspectorId','$_inspectorName','$_recordType','$_recordState','$_recordTitle','$_isAbnormal','$_abnormalExplain','$_abnormalImagesPath','$_abnormalImagesUrl','$_temperature','$_humidity','$_isOpen','$_input','$_isUpload','$_time','$_latlon','$_sort','$_isChecked','$_checkWay','$_checkTime','$_checkerName')";
    return sql;
  }

  _query(String sql, args) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String _dbPath = prefs.getString("DB_PATH");
    String _dbPath = await FileUtils.getDatabasePath();

    print('get task record sql is $sql $args');

    Database db = await openDatabase(_dbPath);
    List<Map> list;
    if (args == null) {
      list = await db.rawQuery(sql);
    } else {
      list = await db.rawQuery(sql, args);
    }

    List<TabDeviceRecordModel> tabDeviceRecordModelList = new List();
    for (var item in list) {
      TabDeviceRecordModel tabDeviceRecordModel = _convertToModel(item);
      tabDeviceRecordModelList.add(tabDeviceRecordModel);
    }
    return tabDeviceRecordModelList;
  }

  TabDeviceRecordModel _convertToModel(Map<String, dynamic> item) {
    TabDeviceRecordModel tabDeviceRecordModel = new TabDeviceRecordModel();
    tabDeviceRecordModel.id = item[TabDeviceRecordModel.ID];
    tabDeviceRecordModel.inspectionId =
        item[TabDeviceRecordModel.INSPECTION_ID];
    tabDeviceRecordModel.inspectionType =
        item[TabDeviceRecordModel.INSPECTION_TYPE];
    tabDeviceRecordModel.inspectionContentId =
        item[TabDeviceRecordModel.INSPECTION_CONTENT_ID];
    tabDeviceRecordModel.inspectorId = item[TabDeviceRecordModel.INSPECTOR_ID];
    tabDeviceRecordModel.inspectorName =
        item[TabDeviceRecordModel.INSPECTOR_NAME];
    tabDeviceRecordModel.recordType = item[TabDeviceRecordModel.RECORD_TYPE];
    tabDeviceRecordModel.recordState = item[TabDeviceRecordModel.RECORD_STATE];
    tabDeviceRecordModel.recordTitle = item[TabDeviceRecordModel.RECORD_TITLE];
    tabDeviceRecordModel.isAbnormal = item[TabDeviceRecordModel.IS_ABNORMAL];
    tabDeviceRecordModel.abnormalExplain =
        item[TabDeviceRecordModel.ABNORMAL_EXPLAIN];
    tabDeviceRecordModel.abnormalImagesPath =
        item[TabDeviceRecordModel.ABNORMAL_IMAGES_PATH];
    tabDeviceRecordModel.abnormalImagesUrl =
        item[TabDeviceRecordModel.ABNORMAL_IMAGES_URL];
    tabDeviceRecordModel.temperature = item[TabDeviceRecordModel.TEMPERATURE];
    tabDeviceRecordModel.humidity = item[TabDeviceRecordModel.HUMIDITY];
    tabDeviceRecordModel.isOpen = item[TabDeviceRecordModel.IS_OPEN];
    tabDeviceRecordModel.input = item[TabDeviceRecordModel.INPUT];
    tabDeviceRecordModel.isUpload = item[TabDeviceRecordModel.IS_UPLOAD];
    tabDeviceRecordModel.time = item[TabDeviceRecordModel.TIME];
    tabDeviceRecordModel.latlon = item[TabDeviceRecordModel.LATLON];
    tabDeviceRecordModel.sort = item[TabDeviceRecordModel.SORT];
    tabDeviceRecordModel.isChecked = item[TabDeviceRecordModel.IS_CHECKED];
    tabDeviceRecordModel.checkWay = item[TabDeviceRecordModel.CHECK_WAY];
    tabDeviceRecordModel.checkTime = item[TabDeviceRecordModel.CHECK_TIME];
    tabDeviceRecordModel.checkerName = item[TabDeviceRecordModel.CHECKER_NAME];
    return tabDeviceRecordModel;
  }

  deleteById(String id) async {
    String _dbPath = await FileUtils.getDatabasePath();
    Database db = await openDatabase(_dbPath);
    String sql = "DELETE FROM " +
        TabDeviceRecordModel.TAB_NAME +
        " WHERE " +
        TabDeviceRecordModel.ID +
        " = ?";
    int count = await db.rawDelete(sql, [id]);
    if (count == 1) {
      return true;
    } else {
      return false;
    }
//    await db.close();
  }
}
