// import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mdc_bhl/utils/file_utils.dart';
/*
 * 办公室记录
 */
class TabOfficeRecordModel {
  static const String TAB_NAME = "tab_office_record";

  static const String ID = "id";
  static const String INSPECTOR_ID = "inspectorId";
  static const String INSPECTOR_Name = "inspectorName";
  static const String COLLECTION_ID = "collectionId";
  static const String COLLECTION_NAME = "collectionName";
  static const String SORT = "sort";
  static const String AREA_COUNT = "areaCount";
  static const String CROWD_LEVEL = "crowdLevel";
  static const String EXPLAIN = "explain";
  static const String IMAGES_PATH = "imagesPath";
  static const String IMAGES_URL = "imagesUrl";
  static const String IS_UPLOAD = "isUpload";
  static const String TIME = "time";
  static const String LATLON = "latlon";

  String id; // 办公室记录id（主）
  String inspectorId; // 巡查人id
  String inspectorName; // 巡查人name
  String collectionId; // 采集点id
  String collectionName; // 采集点名称
  int sort; // 顺序
  int areaCount; // 当前区域人数
  int crowdLevel; // 拥挤程度 1-舒适，2-一般，3-拥挤，4-非常拥挤
  String explain; // 情况说明
  String imagesPath; // 图片本地路径
  String imagesUrl; // 图片网络路径
  int isUpload; // 是否提交 0-未提交，1-已提交
  String time; // 保存或提交时间
  String latlon; // 巡查点经纬度（预留字段）

  @override
  String toString() {
    return 'TabOfficeRecordModel{id: $id, inspectorId: $inspectorId, collectionId: $collectionId, collectionName: $collectionName, sort: $sort, areaCount: $areaCount, crowdLevel: $crowdLevel, explain: $explain, imagesPath: $imagesPath, imagesUrl: $imagesUrl, isUpload: $isUpload, time: $time, latlon: $latlon}';
  }

  TabOfficeRecordModel(
      {this.id,
      this.inspectorId,
      this.collectionId,
      this.collectionName,
      this.sort,
      this.areaCount,
      this.crowdLevel,
      this.explain,
      this.imagesPath,
      this.imagesUrl,
      this.isUpload = 0,
      this.time,
      this.latlon});

  TabOfficeRecordModel.fromJson(Map<String, dynamic> json) {
    collectionId = json['Id'];
    collectionName = json['Cjdmc'];
    sort = json['Sx'];
  }

  Map<String, dynamic> toJson(String userName) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Cjdid'] = this.collectionId;
    data['Cjdmc'] = this.collectionName;
    data['Dqqyrs'] = this.areaCount;
    data['Yjcd'] = this.crowdLevel;
    data['Qksm'] = this.explain;
    data['Cjrid'] = this.inspectorId;
    data['Cjrmc'] = userName;
    return data;
  }
}

class TabOfficeRecordManager {
  // 插入办公室采集内容
  insert(TabOfficeRecordModel tabOfficeRecordModel) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String _dbPath = prefs.getString("DB_PATH");
    // String dbPath = await LocalStorage.get("DB_PATH");
            String dbPath = await FileUtils.getDatabasePath();


    int result = 1;

    String _id = tabOfficeRecordModel.id;
    String _inspectorId = tabOfficeRecordModel.inspectorId;
    String _collectionId = tabOfficeRecordModel.collectionId;
    String _collectionName = tabOfficeRecordModel.collectionName;
    int _sort =
        (tabOfficeRecordModel.sort == null ? 0 : tabOfficeRecordModel.sort);
    int _areaCount = (tabOfficeRecordModel.areaCount == null
        ? 0
        : tabOfficeRecordModel.areaCount);
    int _crowdLevel = (tabOfficeRecordModel.crowdLevel == null
        ? 0
        : tabOfficeRecordModel.crowdLevel);
    String _explain = tabOfficeRecordModel.explain;
    String _imagesPath = tabOfficeRecordModel.imagesPath;
    String _imagesUrl = tabOfficeRecordModel.imagesUrl;
    int _isUpload = (tabOfficeRecordModel.isUpload == null
        ? 0
        : tabOfficeRecordModel.isUpload);
    String _time = tabOfficeRecordModel.time;
    String _latlon = tabOfficeRecordModel.latlon;

    Database db = await openDatabase(dbPath);
    String sql = "INSERT OR REPLACE INTO " +
        TabOfficeRecordModel.TAB_NAME +
        "(" +
        TabOfficeRecordModel.ID +
        "," +
        TabOfficeRecordModel.INSPECTOR_ID +
        "," +
        TabOfficeRecordModel.COLLECTION_ID +
        "," +
        TabOfficeRecordModel.COLLECTION_NAME +
        "," +
        TabOfficeRecordModel.SORT +
        "," +
        TabOfficeRecordModel.AREA_COUNT +
        "," +
        TabOfficeRecordModel.CROWD_LEVEL +
        "," +
        TabOfficeRecordModel.EXPLAIN +
        "," +
        TabOfficeRecordModel.IMAGES_PATH +
        "," +
        TabOfficeRecordModel.IMAGES_URL +
        "," +
        TabOfficeRecordModel.IS_UPLOAD +
        "," +
        TabOfficeRecordModel.TIME +
        "," +
        TabOfficeRecordModel.LATLON +
        ") VALUES('$_id','$_inspectorId','$_collectionId','$_collectionName','$_sort','$_areaCount','$_crowdLevel','$_explain','$_imagesPath','$_imagesUrl','$_isUpload','$_time','$_latlon')";
    await db.transaction((txn) async {
      // 事务性插入
      result = await txn.rawInsert(sql);
    });

    // await db.close();

    print("插入" + TabOfficeRecordModel.TAB_NAME + "成功:" + sql);
    return result;

  }

  // 查询所有办公室采集内容
  queryAll() {
    String sql = 'SELECT * FROM ' + TabOfficeRecordModel.TAB_NAME;
    return _query(sql, null);
  }

  // 根据办公室采集内容id、采集点id查询办公室采集内容
  queryById(String id, String collectionId) {
    String sql = 'SELECT * FROM ' +
        TabOfficeRecordModel.TAB_NAME +
        " WHERE " +
        TabOfficeRecordModel.ID +
        " = ? AND " +
        TabOfficeRecordModel.COLLECTION_ID +
        " = ?";
    return _query(sql, [id, collectionId]);
  }

  // 根据用户id查询办公室采集内容
  queryByUserId(String userId) {
    String sql = 'SELECT * FROM ' +
        TabOfficeRecordModel.TAB_NAME +
        " WHERE " +
        TabOfficeRecordModel.INSPECTOR_ID +
        " = ? ORDER BY time DESC";
    return _query(sql, [userId]);
  }

  _query(String sql, args) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String _dbPath = prefs.getString("DB_PATH");
            String dbPath = await FileUtils.getDatabasePath();

    Database db = await openDatabase(dbPath);
    List<Map> list;
    if (args == null) {
      list = await db.rawQuery(sql);
    } else {
      list = await db.rawQuery(sql, args);
    }
    await db.close();

    List<TabOfficeRecordModel> tabOfficeRecordModelList = new List();
    for (var item in list) {
      TabOfficeRecordModel tabOfficeRecordModel = _convertToModel(item);
      tabOfficeRecordModelList.add(tabOfficeRecordModel);
    }
    return tabOfficeRecordModelList;
  }

  TabOfficeRecordModel _convertToModel(Map item) {
    TabOfficeRecordModel tabOfficeRecordModel = new TabOfficeRecordModel();
    tabOfficeRecordModel.id = item[TabOfficeRecordModel.ID];
    tabOfficeRecordModel.inspectorId = item[TabOfficeRecordModel.INSPECTOR_ID];
    tabOfficeRecordModel.collectionId =
        item[TabOfficeRecordModel.COLLECTION_ID];
    tabOfficeRecordModel.collectionName =
        item[TabOfficeRecordModel.COLLECTION_NAME];
    tabOfficeRecordModel.sort = item[TabOfficeRecordModel.SORT];
    tabOfficeRecordModel.areaCount = item[TabOfficeRecordModel.AREA_COUNT];
    tabOfficeRecordModel.crowdLevel = item[TabOfficeRecordModel.CROWD_LEVEL];
    tabOfficeRecordModel.explain = item[TabOfficeRecordModel.EXPLAIN];
    tabOfficeRecordModel.imagesPath = item[TabOfficeRecordModel.IMAGES_PATH];
    tabOfficeRecordModel.imagesUrl = item[TabOfficeRecordModel.IMAGES_URL];
    tabOfficeRecordModel.isUpload = item[TabOfficeRecordModel.IS_UPLOAD];
    tabOfficeRecordModel.time = item[TabOfficeRecordModel.TIME];
    tabOfficeRecordModel.latlon = item[TabOfficeRecordModel.LATLON];
    return tabOfficeRecordModel;
  }

  // 根据id修改办公室采集内容
  updateById(
      String officeRecordId, TabOfficeRecordModel tabOfficeRecordModel) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String _dbPath = prefs.getString("DB_PATH");
    // String dbPath = await LocalStorage.get("DB_PATH");
        String dbPath = await FileUtils.getDatabasePath();



    Database db = await openDatabase(dbPath);
    String sql = "UPDATE " +
        TabOfficeRecordModel.TAB_NAME +
        " SET " +
        TabOfficeRecordModel.INSPECTOR_ID +
        "=?" +
        "," +
        TabOfficeRecordModel.COLLECTION_ID +
        "=?" +
        "," +
        TabOfficeRecordModel.COLLECTION_NAME +
        "=?" +
        "," +
        TabOfficeRecordModel.SORT +
        "=?" +
        "," +
        TabOfficeRecordModel.AREA_COUNT +
        "=?" +
        "," +
        TabOfficeRecordModel.CROWD_LEVEL +
        "=?" +
        "," +
        TabOfficeRecordModel.EXPLAIN +
        "=?" +
        "," +
        TabOfficeRecordModel.IMAGES_PATH +
        "=?" +
        "," +
        TabOfficeRecordModel.IMAGES_URL +
        "=?" +
        "," +
        TabOfficeRecordModel.IS_UPLOAD +
        "=?" +
        "," +
        TabOfficeRecordModel.TIME +
        "=?" +
        "," +
        TabOfficeRecordModel.LATLON +
        "=?" +
        " WHERE " +
        TabOfficeRecordModel.ID +
        " = ?";
    await db.rawUpdate(sql, [
      tabOfficeRecordModel.inspectorId,
      tabOfficeRecordModel.collectionId,
      tabOfficeRecordModel.collectionName,
      tabOfficeRecordModel.sort,
      tabOfficeRecordModel.areaCount,
      tabOfficeRecordModel.crowdLevel,
      tabOfficeRecordModel.explain,
      tabOfficeRecordModel.imagesPath,
      tabOfficeRecordModel.imagesUrl,
      tabOfficeRecordModel.isUpload,
      tabOfficeRecordModel.time,
      tabOfficeRecordModel.latlon,
      officeRecordId
    ]);
    await db.close();
    print("更改" +
        TabOfficeRecordModel.TAB_NAME +
        "成功:" +
        tabOfficeRecordModel.toString());
  }

  deleteById(String id) async {
    String _dbPath = await FileUtils.getDatabasePath();
    Database db = await openDatabase(_dbPath);
    String sql = "DELETE FROM " + TabOfficeRecordModel.TAB_NAME + " WHERE " + TabOfficeRecordModel.ID + " = ?";
    int count = await db.rawDelete(sql, [id]);
    if (count == 1) {
      return true;
    } else {
      return false;
    }
//    await db.close();
  }
}
