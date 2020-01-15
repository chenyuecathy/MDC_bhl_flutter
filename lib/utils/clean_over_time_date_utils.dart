import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/db/tab_device_record_manager.dart';
import 'package:mdc_bhl/db/tab_office_record_manager.dart';
import 'package:mdc_bhl/db/tab_report_record_manager.dart';
import 'package:mdc_bhl/db/tab_seepage_collect_manager.dart';
import 'package:mdc_bhl/db/tab_stable_collect_manager.dart';
import 'package:mdc_bhl/db/tab_water_level_collect_manager.dart';

import 'date_utils.dart';

/**
 * 清理超时数据工具类
 */
class CleanOverTimeDateUtils {
  // 清理超时数据
  static cleanOverTimeDate() async {
    // 清理设备科、保卫科数据
    List<TabDeviceRecordModel> tabDeviceRecordModelList = await TabDeviceRecordManager().queryAll();
    for (var item in tabDeviceRecordModelList) {
      if (await _getWhetherDelete(item.time)) {
        await TabDeviceRecordManager().deleteById(item.id);
      }
    }
    // 清理办公室数据
    List<TabOfficeRecordModel> tabOfficeRecordModelList = await TabOfficeRecordManager().queryAll();
    for (var item in tabOfficeRecordModelList) {
      if (await _getWhetherDelete(item.time)) {
        await TabOfficeRecordManager().deleteById(item.id);
      }
    }
    // 清理异常上报数据
    List<TabReportRecordModel> tabReportRecordModelList = await TabReportRecordManager().queryAll();
    for (var item in tabReportRecordModelList) {
      if (await _getWhetherDelete(item.time)) {
        await TabReportRecordManager().deleteById(item.id);
      }
    }
    // 清理渗漏水数据
    List<TabSeepageCollectModel> tabSeepageCollectModelList = await TabSeepageCollectManager().queryAll();
    for (var item in tabSeepageCollectModelList) {
      if (await _getWhetherDelete(item.uploadTime)) {
        await TabSeepageCollectManager().deleteById(item.id);
      }
    }
    // 清理稳定性数据
    List<TabStableCollectModel> tabStableCollectModelList = await TabStableCollectManager().queryAll();
    for (var item in tabStableCollectModelList) {
      if (await _getWhetherDelete(item.uploadTime)) {
        await TabStableCollectManager().deleteById(item.id);
      }
    }
    // 清理水位数据
    List<TabWaterLevelCollectModel> tabWaterLevelCollectModelList = await TabWaterLevelCollectManager().queryAll();
    for (var item in tabWaterLevelCollectModelList) {
      if (await _getWhetherDelete(item.uploadTime)) {
        await TabWaterLevelCollectManager().deleteById(item.id);
      }
    }
  }

  // 判断是否删除该时间的数据
  static _getWhetherDelete(String beforeDate) async {
    // 获取保留数据时间
    String _dateSaveTime = await LocalStorage.get(Config.DATA_SAVE_TIME);
    if (_dateSaveTime == null) {
      await LocalStorage.save(Config.DATA_SAVE_TIME, Config.A_WEEK); // 没有获取到保留数据时间，默认保留一周
      _dateSaveTime = Config.A_WEEK;
    }
    // 获取保留数据的天数差值
    int _days = 7;
    if (_dateSaveTime == Config.A_WEEK) {
      _days = 7;
    } else if (_dateSaveTime == Config.HALF_MONTH) {
      _days = 15;
    } else if (_dateSaveTime == Config.A_MONTH) {
      _days = 30;
    }
    // 获取前后日期的年月日
    String _currentDate = DateUtils.getCurrentDay();
    String _currentYear = _currentDate.substring(0, 4);
    String _currentMonth = _currentDate.substring(5, 7);
    String _currentDay = _currentDate.substring(8, 10);
    String _beforeDate = beforeDate;
    String _beforeYear = _beforeDate.substring(0, 4);
    String _beforeMonth = _beforeDate.substring(5, 7);
    String _beforeDay = _beforeDate.substring(8, 10);
    // 获取两个日期的差值
    var _d1 = new DateTime(int.parse(_currentYear), int.parse(_currentMonth), int.parse(_currentDay));
    var _d2 = new DateTime(int.parse(_beforeYear), int.parse(_beforeMonth), int.parse(_beforeDay));
    var _difference = _d1.difference(_d2);
//    print(_difference.inDays);
    // 判断数据是否删除
    if (_difference.inDays <= _days) {
      return false; //不删除
    } else {
      return true; //删除
    }
  }

  // 获取有效日期List
  static getValidDateList() async {
    List<String> validDateList = [];
    // 获取保留数据时间
    String _dateSaveTime = await LocalStorage.get(Config.DATA_SAVE_TIME);
    if (_dateSaveTime == null) {
      await LocalStorage.save(Config.DATA_SAVE_TIME, Config.A_WEEK); // 没有获取到保留数据时间，默认保留一周
      _dateSaveTime = Config.A_WEEK;
    }
    // 获取保留数据的天数差值
    int _days = 7;
    if (_dateSaveTime == Config.A_WEEK) {
      _days = 7;
    } else if (_dateSaveTime == Config.HALF_MONTH) {
      _days = 15;
    } else if (_dateSaveTime == Config.A_MONTH) {
      _days = 30;
    }
    // 获取有效日期List
    var today = DateTime.now();
    for (var i = 0; i < _days; i++) {
      DateTime daysAgo = today.subtract(new Duration(days: i));
      String _validDate = daysAgo.toString().substring(0, 10);
      validDateList.add(_validDate);
    }
    // 返回数据
    return validDateList;
  }
}