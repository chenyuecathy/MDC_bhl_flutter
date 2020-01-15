import 'dart:io';

import 'package:mdc_bhl/db/tab_device_record_manager.dart';
import 'package:mdc_bhl/db/tab_guard_record_manager.dart';
import 'package:mdc_bhl/db/tab_inspection.dart';
import 'package:mdc_bhl/db/tab_office_record_manager.dart';
import 'package:mdc_bhl/db/tab_report_record_manager.dart';
import 'package:mdc_bhl/db/tab_seepage_collect_manager.dart';
import 'package:mdc_bhl/db/tab_stable_collect_manager.dart';
import 'package:mdc_bhl/db/tab_user_manager.dart';
import 'package:mdc_bhl/db/tab_water_level_collect_manager.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class DbManager {
  static const String DB_NAME = "mdc_bhl.db";

  DbManager() {
    create(DB_NAME);
  }

  create(dbName) async {
    String _dbPath = await _createNewDb(dbName);
    print("数据库位置：" + _dbPath);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("DB_PATH", _dbPath);

    // 创建表
    if (prefs.getBool("IS_CREATE_TAB") == true) {
      return;
    }
    Database db = await openDatabase(_dbPath);
    Map createTabSqlMap = _getCreateTabSqlMap();
    for (var key in createTabSqlMap.keys) {
      await db.execute(createTabSqlMap[key]);
      print("创建表" + key + "成功");
    }
    // await db.close();
    prefs.setBool("IS_CREATE_TAB", true);
  }

  Future<String> _createNewDb(String dbName) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    print("数据库存储路径：" + documentsDirectory.path);

    String path = join(documentsDirectory.path, dbName);
    if (await new Directory(dirname(path)).exists()) {
//      await deleteDatabase(path);
    } else {
      try {
        await new Directory(dirname(path)).create(recursive: true);
      } catch (e) {
        print(e);
      }
    }
    return path;
  }

  /*
   * 创建表的sql语句
   */
  Map _getCreateTabSqlMap() {
    Map createTabSqlMap = new Map();

    // 用户表
    String _sqlCreateUserTab = 'CREATE TABLE ' + TabUserModel.TAB_NAME + '(' +
        TabUserModel.ID + ' TEXT PRIMARY KEY'
        ', ' + TabUserModel.NAME + ' TEXT'
        ', ' + TabUserModel.PWD + ' TEXT'
        ', ' + TabUserModel.MOBILE + ' TEXT'
        ', ' + TabUserModel.DEPARTMENT_ID + ' TEXT'
        ', ' + TabUserModel.DEPARTMENT_NAME + ' TEXT'
        ', ' + TabUserModel.REAL_NAME + ' TEXT'
        ', ' + TabUserModel.SEX + ' INTEGER'
        ', ' + TabUserModel.DEVICE_ID + ' TEXT'
        ', ' + TabUserModel.PHOTO_PATH + ' TEXT'
        ', ' + TabUserModel.PHOTO_URL + ' TEXT'
        ')';
    createTabSqlMap[TabUserModel.TAB_NAME] = _sqlCreateUserTab;

    // 办公室采集内容表
    String _sqlCreateOfficeRecordTab = 'CREATE TABLE ' +
        TabOfficeRecordModel.TAB_NAME + '(' +
        TabOfficeRecordModel.ID + ' TEXT PRIMARY KEY'
        ', ' + TabInspectionModel.INSPECTOR_ID + ' TEXT'
        ', ' + TabOfficeRecordModel.COLLECTION_ID + ' TEXT'
        ', ' + TabOfficeRecordModel.COLLECTION_NAME + ' TEXT'
        ', ' + TabOfficeRecordModel.SORT + ' INTEGER'
        ', ' + TabOfficeRecordModel.AREA_COUNT + ' INTEGER'
        ', ' + TabOfficeRecordModel.CROWD_LEVEL + ' INTEGER'
        ', ' + TabOfficeRecordModel.EXPLAIN + ' TEXT'
        ', ' + TabOfficeRecordModel.IMAGES_PATH + ' TEXT'
        ', ' + TabOfficeRecordModel.IMAGES_URL + ' TEXT'
        ', ' + TabOfficeRecordModel.IS_UPLOAD + ' INTEGER'
        ', ' + TabOfficeRecordModel.TIME + ' TEXT'
        ', ' + TabOfficeRecordModel.LATLON + ' TEXT'
        ')';
    createTabSqlMap[TabOfficeRecordModel.TAB_NAME] = _sqlCreateOfficeRecordTab;

    // 巡查表
    String _sqlInspectionTab = 'CREATE TABLE ' + TabInspectionModel.TAB_NAME +
        '(' +
        TabInspectionModel.ID + ' TEXT PRIMARY KEY'
        ', ' + TabInspectionModel.INSPECTOR_ID + ' TEXT'
        ', ' + TabInspectionModel.INSPECTION_TYPE + ' INTEGER'
        ', ' + TabInspectionModel.INSPECTION_STATE + ' INTEGER'
        ', ' + TabInspectionModel.INSPECTION_TIME + ' TEXT'
        ')';
    createTabSqlMap[TabInspectionModel.TAB_NAME] = _sqlInspectionTab;

    // 设备科巡查内容表
    String _sqlCreateDeviceRecordTab = 'CREATE TABLE ' +
        TabDeviceRecordModel.TAB_NAME + '(' +
        TabDeviceRecordModel.ID + ' TEXT PRIMARY KEY'
        ', ' + TabDeviceRecordModel.INSPECTION_ID + ' TEXT'
        ', ' + TabDeviceRecordModel.INSPECTION_TYPE + ' INTEGER'
        ', ' + TabDeviceRecordModel.INSPECTION_CONTENT_ID + ' TEXT'
        ', ' + TabDeviceRecordModel.INSPECTOR_ID + ' TEXT'
        ', ' + TabDeviceRecordModel.INSPECTOR_NAME + ' TEXT'
        ', ' + TabDeviceRecordModel.RECORD_TYPE + ' INTEGER'
        ', ' + TabDeviceRecordModel.RECORD_STATE + ' INTEGER'
        ', ' + TabDeviceRecordModel.RECORD_TITLE + ' TEXT'
        ', ' + TabDeviceRecordModel.IS_ABNORMAL + ' INTEGER'
        ', ' + TabDeviceRecordModel.ABNORMAL_EXPLAIN + ' TEXT'
        ', ' + TabDeviceRecordModel.ABNORMAL_IMAGES_PATH + ' TEXT'
        ', ' + TabDeviceRecordModel.ABNORMAL_IMAGES_URL + ' TEXT'
        ', ' + TabDeviceRecordModel.TEMPERATURE + ' TEXT'
        ', ' + TabDeviceRecordModel.HUMIDITY + ' TEXT'
        ', ' + TabDeviceRecordModel.IS_OPEN + ' INTEGER'
        ', ' + TabDeviceRecordModel.INPUT + ' TEXT'
        ', ' + TabDeviceRecordModel.IS_UPLOAD + ' INTEGER'
        ', ' + TabDeviceRecordModel.TIME + ' TEXT'
        ', ' + TabDeviceRecordModel.LATLON + ' TEXT'
        ', ' + TabDeviceRecordModel.SORT + ' INTEGER'
        ', ' + TabDeviceRecordModel.IS_CHECKED + ' INTEGER'
        ', ' + TabDeviceRecordModel.CHECK_WAY + ' TEXT'
        ', ' + TabDeviceRecordModel.CHECK_TIME + ' TEXT'
        ', ' + TabDeviceRecordModel.CHECKER_NAME + ' TEXT'
        ')';
    createTabSqlMap[TabDeviceRecordModel.TAB_NAME] = _sqlCreateDeviceRecordTab;

    // 保卫科巡查内容表
    String _sqlCreateGuardRecordTab = 'CREATE TABLE ' +
        TabGuardRecordModel.TAB_NAME + '(' +
        TabGuardRecordModel.ID + ' TEXT PRIMARY KEY'
        ', ' + TabGuardRecordModel.INSPECTION_ID + ' TEXT'
        ', ' + TabDeviceRecordModel.INSPECTION_TYPE + ' INTEGER'
        ', ' + TabGuardRecordModel.INSPECTION_Content_ID + ' TEXT'
        ', ' + TabGuardRecordModel.INSPECTOR_ID + ' TEXT'
        ', ' + TabGuardRecordModel.INSPECTOR_NAME + ' TEXT'
        ', ' + TabGuardRecordModel.RECORD_TYPE + ' INTEGER'
        ', ' + TabGuardRecordModel.RECORD_STATE + ' INTEGER'
        ', ' + TabGuardRecordModel.RECORD_TITLE + ' TEXT'
        ', ' + TabGuardRecordModel.IS_ABNORMAL + ' INTEGER'
        ', ' + TabGuardRecordModel.ABNORMAL_EXPLAIN + ' TEXT'
        ', ' + TabGuardRecordModel.ABNORMAL_IMAGES_PATH + ' TEXT'
        ', ' + TabGuardRecordModel.ABNORMAL_IMAGES_URL + ' TEXT'
        ', ' + TabGuardRecordModel.TEMPERATURE + ' TEXT'
        ', ' + TabGuardRecordModel.HUMIDITY + ' TEXT'
        ', ' + TabGuardRecordModel.IS_OPEN + ' INTEGER'
        ', ' + TabGuardRecordModel.INPUT + ' TEXT'
        ', ' + TabGuardRecordModel.IS_UPLOAD + ' INTEGER'
        ', ' + TabGuardRecordModel.TIME + ' TEXT'
        ', ' + TabGuardRecordModel.LATLON + ' TEXT'
        ', ' + TabGuardRecordModel.SORT + ' INTEGER'
        ')';
    createTabSqlMap[TabGuardRecordModel.TAB_NAME] = _sqlCreateGuardRecordTab;

    // 异常上报记录表
    String _sqlCreateReportRecordTab = 'CREATE TABLE ' +
        TabReportRecordModel.TAB_NAME + '(' +
        TabReportRecordModel.ID + ' TEXT PRIMARY KEY'
        ', ' + TabReportRecordModel.INSPECTION_ID + ' TEXT'
        ', ' + TabReportRecordModel.LOCATION + ' TEXT'
        ', ' + TabReportRecordModel.EXPLAIN + ' TEXT'
        ', ' + TabReportRecordModel.IMAGES_PATH + ' TEXT'
        ', ' + TabReportRecordModel.IMAGES_URL + ' TEXT'
        ', ' + TabReportRecordModel.IS_UPLOAD + ' INTEGER'
        ', ' + TabReportRecordModel.TIME + ' TEXT'
        ', ' + TabReportRecordModel.LATLON + ' TEXT'
        ', ' + TabReportRecordModel.IS_CHECKED + ' INTEGER'
        ', ' + TabReportRecordModel.CHECK_WAY + ' TEXT'
        ', ' + TabReportRecordModel.CHECK_TIME + ' TEXT'
        ', ' + TabReportRecordModel.CHECKER_NAME + ' TEXT'
        ')';
    createTabSqlMap[TabReportRecordModel.TAB_NAME] = _sqlCreateReportRecordTab;

    // 渗漏水表
    String _sqlCreateSeepageCollectTab = 'CREATE TABLE ' +
        TabSeepageCollectModel.TAB_NAME + '(' +
        TabSeepageCollectModel.ID + ' TEXT PRIMARY KEY'
        ', ' + TabSeepageCollectModel.COLLECTOR_ID + ' TEXT'
        ', ' + TabSeepageCollectModel.UPSTREAM_LINE_ID + ' TEXT'
        ', ' + TabSeepageCollectModel.UPSTREAM_LINE_VALUE + ' real'
        ', ' + TabSeepageCollectModel.DOWNSTREAM_LINE_ID + ' TEXT'
        ', ' + TabSeepageCollectModel.DOWNSTREAM_LINE_VALUE + ' real'
        ', ' + TabSeepageCollectModel.DOWNSTREAM_GAP_ID + ' TEXT'
        ', ' + TabSeepageCollectModel.DOWNSTREAM_GAP_VALUE + ' real'
        ', ' + TabSeepageCollectModel.IS_UPLOAD + ' INTEGER'
        ', ' + TabSeepageCollectModel.UPLOAD_TIME + ' TEXT'
        ')';
    createTabSqlMap[TabSeepageCollectModel.TAB_NAME] = _sqlCreateSeepageCollectTab;

    // 稳定性表
    String _sqlCreateStableCollectTab = 'CREATE TABLE ' +
        TabStableCollectModel.TAB_NAME + '(' +
        TabStableCollectModel.ID + ' TEXT PRIMARY KEY'
        ', ' + TabStableCollectModel.COLLECTOR_ID + ' TEXT'
        ', ' + TabStableCollectModel.R32D_MS_VALUE + ' real'
        ', ' + TabStableCollectModel.R32D_WD_VALUE + ' real'
        ', ' + TabStableCollectModel.R33D_MS_VALUE + ' real'
        ', ' + TabStableCollectModel.R33D_WD_VALUE + ' real'
        ', ' + TabStableCollectModel.R34D_MS_VALUE + ' real'
        ', ' + TabStableCollectModel.R34D_WD_VALUE + ' real'
        ', ' + TabStableCollectModel.R35D_MS_VALUE + ' real'
        ', ' + TabStableCollectModel.R35D_WD_VALUE + ' real'
        ', ' + TabStableCollectModel.R36D_MS_VALUE + ' real'
        ', ' + TabStableCollectModel.R36D_WD_VALUE + ' real'
        ', ' + TabStableCollectModel.R37D_MS_VALUE + ' real'
        ', ' + TabStableCollectModel.R37D_WD_VALUE + ' real'
        ', ' + TabStableCollectModel.R38D_MS_VALUE + ' real'
        ', ' + TabStableCollectModel.R38D_WD_VALUE + ' real'
        ', ' + TabStableCollectModel.R39D_MS_VALUE + ' real'
        ', ' + TabStableCollectModel.R39D_WD_VALUE + ' real'
        ', ' + TabStableCollectModel.R40D_MS_VALUE + ' real'
        ', ' + TabStableCollectModel.R40D_WD_VALUE + ' real'
        ', ' + TabStableCollectModel.J02D_MS_VALUE + ' real'
        ', ' + TabStableCollectModel.J02D_WD_VALUE + ' real'
        ', ' + TabStableCollectModel.IS_UPLOAD + ' INTEGER'
        ', ' + TabStableCollectModel.UPLOAD_TIME + ' TEXT'
        ')';
    createTabSqlMap[TabStableCollectModel.TAB_NAME] = _sqlCreateStableCollectTab;

    // 水位表
    String _sqlCreateWaterLevelCollectTab = 'CREATE TABLE ' +
        TabWaterLevelCollectModel.TAB_NAME + '(' +
        TabWaterLevelCollectModel.ID + ' TEXT PRIMARY KEY'
        ', ' + TabWaterLevelCollectModel.COLLECTOR_ID + ' TEXT'
        ', ' + TabWaterLevelCollectModel.WATER_LEVEL_VALUE + ' INTEGER'
        ', ' + TabWaterLevelCollectModel.IS_UPLOAD + ' INTEGER'
        ', ' + TabWaterLevelCollectModel.UPLOAD_TIME + ' TEXT'
        ')';
    createTabSqlMap[TabWaterLevelCollectModel.TAB_NAME] = _sqlCreateWaterLevelCollectTab;

    return createTabSqlMap;
  }
}