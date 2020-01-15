// import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mdc_bhl/utils/file_utils.dart';

/*
 * 渗漏水记录
 */
class TabSeepageCollectModel {
  static const String TAB_NAME = "tab_seepage_collect";

  static const String ID = "id";
  static const String COLLECTOR_ID = "collectorId";
  static const String UPSTREAM_LINE_ID = "upstreamLineId";
  static const String UPSTREAM_LINE_VALUE = "upstreamLineValue";
  static const String DOWNSTREAM_LINE_ID = "downstreamLineId";
  static const String DOWNSTREAM_LINE_VALUE = "downstreamLineValue";
  static const String DOWNSTREAM_GAP_ID = "downstreamGapId";
  static const String DOWNSTREAM_GAP_VALUE = "downstreamGapValue";
  static const String IS_UPLOAD = "isUpload";
  static const String UPLOAD_TIME = "uploadTime";

  String id; // 渗漏水记录id（主）
  String collectorId; // 采集人id
  String upstreamLineId; // 上游廊道线路出处id
  double upstreamLineValue; // 上游廊道线路出处值
  String downstreamLineId; // 下游廊道线路出处id
  double downstreamLineValue; // 下游廊道线路出处值
  String downstreamGapId; // 下游廊道伸缩缝id
  double downstreamGapValue; // 下游廊道伸缩缝值
  int isUpload; // 是否提交 0-未提交，1-已提交
  String uploadTime; // 提交时间

  @override
  String toString() {
    return 'TabSeepageCollectModel{id: $id, collectorId: $collectorId, upstreamLineId: $upstreamLineId, upstreamLineValue: $upstreamLineValue, downstreamLineId: $downstreamLineId, downstreamLineValue: $downstreamLineValue, downstreamGapId: $downstreamGapId, downstreamGapValue: $downstreamGapValue, isUpload: $isUpload, uploadTime: $uploadTime}';
  }
}

class TabSeepageCollectServiceModel {
  String ID; // 记录id
  String SBBH; // 设备编号
  String JCZ; // 监测值
  String CJRID; // 采集人id
  String CJRMC; // 采集人名称（REALNAME）

  TabSeepageCollectServiceModel(this.ID, this.SBBH, this.JCZ, this.CJRID, this.CJRMC);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.ID;
    data['SBBH'] = this.SBBH;
    data['JCZ'] = this.JCZ;
    data['CJRID'] = this.CJRID;
    data['CJRMC'] = this.CJRMC;
    return data;
  }
}

class TabSeepageCollectManager {
  // 插入渗漏水记录
  insert(TabSeepageCollectModel tabSeepageCollectModel) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String _dbPath = prefs.getString("DB_PATH");
        String _dbPath = await FileUtils.getDatabasePath();


    String _id = tabSeepageCollectModel.id;
    String _collectorId = tabSeepageCollectModel.collectorId;
    String _upstreamLineId = tabSeepageCollectModel.upstreamLineId;
    double _upstreamLineValue = (tabSeepageCollectModel.upstreamLineValue == null ? 0 : tabSeepageCollectModel.upstreamLineValue);
    String _downstreamLineId = tabSeepageCollectModel.downstreamLineId;
    double _downstreamLineValue = (tabSeepageCollectModel.downstreamLineValue == null ? 0 : tabSeepageCollectModel.downstreamLineValue);
    String _downstreamGapId = tabSeepageCollectModel.downstreamGapId;
    double _downstreamGapValue = (tabSeepageCollectModel.downstreamGapValue == null ? 0 : tabSeepageCollectModel.downstreamGapValue);
    int _isUpload = (tabSeepageCollectModel.isUpload == null ? 0 : tabSeepageCollectModel.isUpload);
    String _uploadTime = tabSeepageCollectModel.uploadTime;

    Database db = await openDatabase(_dbPath);
    String sql = "INSERT OR REPLACE INTO " + TabSeepageCollectModel.TAB_NAME +
        "(" + TabSeepageCollectModel.ID +
        "," + TabSeepageCollectModel.COLLECTOR_ID +
        "," + TabSeepageCollectModel.UPSTREAM_LINE_ID +
        "," + TabSeepageCollectModel.UPSTREAM_LINE_VALUE +
        "," + TabSeepageCollectModel.DOWNSTREAM_LINE_ID +
        "," + TabSeepageCollectModel.DOWNSTREAM_LINE_VALUE +
        "," + TabSeepageCollectModel.DOWNSTREAM_GAP_ID +
        "," + TabSeepageCollectModel.DOWNSTREAM_GAP_VALUE +
        "," + TabSeepageCollectModel.IS_UPLOAD +
        "," + TabSeepageCollectModel.UPLOAD_TIME +
        ") VALUES('$_id','$_collectorId','$_upstreamLineId','$_upstreamLineValue','$_downstreamLineId','$_downstreamLineValue','$_downstreamGapId','$_downstreamGapValue','$_isUpload','$_uploadTime')";
    await db.transaction((txn) async {
       await txn.rawInsert(sql);
    });
    await db.close();
    print("插入" + TabSeepageCollectModel.TAB_NAME + "成功:" + sql);
  }

  // 查询所有渗漏水记录
  queryAll() {
    String sql = 'SELECT * FROM ' + TabSeepageCollectModel.TAB_NAME;
    return _query(sql, null);
  }

  // 根据渗漏水id查询渗漏水记录
  queryById(String id) {
    String sql = 'SELECT * FROM ' + TabSeepageCollectModel.TAB_NAME + " WHERE " + TabSeepageCollectModel.ID + " = ?";
    return _query(sql, [id]);
  }

  // 根据用户id查询渗漏水记录
  queryByUserId(String userId) {
    String sql = 'SELECT * FROM ' + TabSeepageCollectModel.TAB_NAME + " WHERE " + TabSeepageCollectModel.COLLECTOR_ID + " = ? AND isUpload==1 ORDER BY uploadTime DESC";
    return _query(sql, [userId]);
  }

  // 根据用户id查询渗漏水未上传记录
  queryByUserIdWithUnupload(String userId) {
    String sql = 'SELECT * FROM ' + TabSeepageCollectModel.TAB_NAME + " WHERE " + TabSeepageCollectModel.COLLECTOR_ID + " = ? AND isUpload!=1";
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

    List<TabSeepageCollectModel> tabSeepageCollectModelList = new List();
    for (var item in list) {
      TabSeepageCollectModel tabSeepageCollectModel = _convertToModel(item);
      tabSeepageCollectModelList.add(tabSeepageCollectModel);
    }
    return tabSeepageCollectModelList;
  }

  TabSeepageCollectModel _convertToModel(Map item) {
    TabSeepageCollectModel tabSeepageCollectModel = new TabSeepageCollectModel();
    tabSeepageCollectModel.id = item[TabSeepageCollectModel.ID];
    tabSeepageCollectModel.collectorId = item[TabSeepageCollectModel.COLLECTOR_ID];
    tabSeepageCollectModel.upstreamLineId = item[TabSeepageCollectModel.UPSTREAM_LINE_ID];
    tabSeepageCollectModel.upstreamLineValue = item[TabSeepageCollectModel.UPSTREAM_LINE_VALUE];
    tabSeepageCollectModel.downstreamLineId = item[TabSeepageCollectModel.DOWNSTREAM_LINE_ID];
    tabSeepageCollectModel.downstreamLineValue = item[TabSeepageCollectModel.DOWNSTREAM_LINE_VALUE];
    tabSeepageCollectModel.downstreamGapId = item[TabSeepageCollectModel.DOWNSTREAM_GAP_ID];
    tabSeepageCollectModel.downstreamGapValue = item[TabSeepageCollectModel.DOWNSTREAM_GAP_VALUE];
    tabSeepageCollectModel.isUpload = item[TabSeepageCollectModel.IS_UPLOAD];
    tabSeepageCollectModel.uploadTime = item[TabSeepageCollectModel.UPLOAD_TIME];
    return tabSeepageCollectModel;
  }

  deleteById(String id) async {
    String _dbPath = await FileUtils.getDatabasePath();
    Database db = await openDatabase(_dbPath);
    String sql = "DELETE FROM " + TabSeepageCollectModel.TAB_NAME + " WHERE " + TabSeepageCollectModel.ID + " = ?";
    int count = await db.rawDelete(sql, [id]);
    if (count == 1) {
      return true;
    } else {
      return false;
    }
//    await db.close();
  }
}