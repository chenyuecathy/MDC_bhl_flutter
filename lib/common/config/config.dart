/* 全局常量在此定义 */

enum DepartmentTaskType {
  Device_Day,
  Device_Night,
  Guard,
  Office,
  Device,
}

/// The height of the toolbar component of the [AppBar].
const double kToolbarHeight = 56.0;

/// The height of the bottom navigation bar.
const double kBottomNavigationBarHeight = 56.0;

/// The height of a tab bar containing text.
const double kTextTabBarHeight = 48.0;

class Config {
  /// //////////////////////////////////////常量////////////////////////////////////// ///
  ///设备科
  static const DEPARTMENT_ID_DEVICE = "daf04b0f-9972-47ce-a684-515fb5caab3e";

  ///办公室
  static const DEPARTMENT_ID_OFFICE = "4ba42b9f-7caf-4847-ac2f-933ffe8f9812";

  ///保卫科
  static const DEPARTMENT_ID_GUARD = "270C7924-AEEB-4C33-9623-C455A860DA62";

  /* 存储巡查记录id */
  ///巡查ID
  static const INSPENTION_REOCRDID = "INSPENTION_REOCRDID";

    ///任务日历
  static const TASK_CALENDAR = "TASK_CALENDAR";

  // ///设备科日巡查ID
  // static const INSPENTION_REOCRDID_DEVIC_DAY = "INSPENTION_REOCRDID_DEVIC_DAY";

  // ///设备科日巡查ID
  // static const INSPENTION_REOCRDID_DEVICE_NIGHT =
  //     "INSPENTION_REOCRDID_DEVICE_NIGHT";

  // ///保卫科巡查ID
  // static const INSPENTION_REOCRDID_GUARD = "INSPENTION_REOCRDID_GUARD";

  static const INSPENTION_TIME = "INSPENTION_TIMET";

  // // 设备科日间巡查起止时间
  // static const INSPENTION_TIME_DEVICE_DAY = "INSPENTION_TIME_DEVICE_DAY";

  // // 设备科夜间巡查起止时间
  // static const INSPENTION_TIME_DEVICE_NIGHT = "INSPENTION_TIME_DEVICE_NIGHT";

  // // 保卫科巡查记录起止时间
  // static const INSPENTION_TIME_GUARD = "INSPENTION_TIME_DEVICE_NIGHT";


  // 部门字典地图（存储巡查内容id时用到）
  static const Map<String, dynamic> DepartmentMap = {
    '0': 'daf04b0f-9972-47ce-a684-515fb5caab3e',
    '1': 'daf04b0f-9972-47ce-a684-515fb5caab3e',
    '2': '270C7924-AEEB-4C33-9623-C455A860DA62',
    '3': '4ba42b9f-7caf-4847-ac2f-933ffe8f9812'
  };

  // 记录下载巡查记录信息的key
  static const DOWNLOAD_INSPECTION_INFO_TIME_KEY = 'Download_Inspection_Info_Time';
  static const DOWNLOAD_OFFICE_INFO_TIME_KEY = 'Download_Office_Info_Time'; // 将DOWNLOAD_INSPECTION_INFO_TIME_KEY拆开——office办公室
  static const OFFICE_TODAY_HAS_POWER_KEY = 'Office_Today_Has_Power'; // office今天是否有权限
  static const DOWNLOAD_GUARD_INFO_TIME_KEY = 'Download_Guard_Info_Time'; // 将DOWNLOAD_INSPECTION_INFO_TIME_KEY拆开——guard保卫科
  static const GUARD_TODAY_HAS_POWER_KEY = 'Guard_Today_Has_Power'; // guard今天是否有权限
  static const DOWNLOAD_DEVICE_DAY_INFO_TIME_KEY = 'Download_Device_Day_Info_Time'; // 将DOWNLOAD_INSPECTION_INFO_TIME_KEY拆开——device_day设备科日
  static const DEVICE_DAY_TODAY_HAS_POWER_KEY = 'Device_Day_Today_Has_Power'; // device_day今天是否有权限
  static const DOWNLOAD_DEVICE_NIGHT_INFO_TIME_KEY = 'Download_Device_Night_Info_Time'; // 将DOWNLOAD_INSPECTION_INFO_TIME_KEY拆开——device_night设备科夜
  static const DEVICE_NIGHT_TODAY_HAS_POWER_KEY = 'Device_Night_Today_Has_Power'; // device_night今天是否有权限

  static const USER_NAME_KEY = "user-name";
  static const PW_KEY = "user-pw";
  static const USER_INFO_KEY = "user-info";
  static const USER_DEPARTMENT_ID = "user-department-id"; // 用于判断是否登陆

  /// 以下为服务器返回的用户信息JSON的key
  static const USER_NAME = 'NAME';
  static const USER_REALNAME = 'REALNAME';
  static const USER_DWNAME = 'DWName';
  static const USER_DWID = 'DWID';
  static const USER_ID = 'ID';
  static const USER_ROLENAME = 'ROLENAME';
  static const USER_MOBILE = 'MOBILE';
  static const USER_PHOTOPATH = 'PHOTOPATH';

  static const String ITEM_ICON = 'item_icon';
  static const String ITEM_TITLE = 'item_title';
  static const String ITEM_CONTENT = 'item_content';

  /// 以下均不使用
  static const PAGE_SIZE = 20;

  /// 一页多少条记录
  static const DEBUG = true;
  static const USE_NATIVE_WEBVIEW = true;

  static const TOKEN_KEY = "token";
  static const USER_BASIC_CODE = "user-basic-code";
  static const LANGUAGE_SELECT = "language-select";
  static const LANGUAGE_SELECT_NAME = "language-select-name";
  static const REFRESH_LANGUAGE = "refreshLanguageApp";
  static const THEME_COLOR = "theme-color";
  static const LOCALE = "locale";

  /// EventBus
  static const String REFRESH_MY_OFFICE_LIST = 'refreshMyOfficeList'; // 刷新办公室列表
  static const String REFRESH_MY_GUARD_LIST = 'refreshMyGuardList'; // 刷新保卫科列表
  static const String REFRESH_DEVICE_DAY_LIST = 'refreshDeviceDayList'; // 刷新设备科日列表
  static const String REFRESH_DEVICE_NIGHT_LIST = 'refreshDeviceNightList'; // 刷新设备科夜列表
  static const String REFRESH_MY_REPORT_LIST = 'refreshMyReportList'; // 刷新异常上报列表

  static const String REFRESH_MY_COLLECT_SEEPAGE_LIST = 'refreshMyCollectSeepageList'; // 刷新我的采集渗漏水列表
  static const String SAVE_SEEPAGE_WITH_TABBAR_BOTTOM = 'saveSeepageWithTabbarBottom'; // 保存渗漏水（主页切换中的渗漏水采集）
  static const String REFRESH_COLLECT_TAB_SEEPAGE = 'refreshCollectTabSeepage'; // 刷新主页切换中的渗漏水采集

  static const String REFRESH_MY_COLLECT_STABLE_LIST = 'refreshMyCollectStableList'; // 刷新我的采集稳定性列表
  static const String SAVE_STABLE_WITH_TABBAR_BOTTOM = 'saveStableWithTabbarBottom'; // 保存稳定性（主页切换中的稳定性采集）
  static const String REFRESH_COLLECT_TAB_STABLE = 'refreshCollectTabStable'; // 刷新主页切换中的稳定性采集

  static const String REFRESH_MY_COLLECT_WATER_LEVEL_LIST = 'refreshMyCollectWaterLevelList'; // 刷新我的采集水位列表
  static const String SAVE_WATER_LEVEL_WITH_TABBAR_BOTTOM = 'saveWaterLevelWithTabbarBottom'; // 保存水位（主页切换中的水位采集）
  static const String REFRESH_COLLECT_TAB_WATER_LEVEL = 'refreshCollectTabWaterLevel'; // 刷新主页切换中的水位采集

  /// SP
  // 数据保留时间
  static const String DATA_SAVE_TIME = 'dataSaveTime';
  static const String A_WEEK = 'aWeek'; // 一周
  static const String HALF_MONTH = 'halfMonth'; // 半个月
  static const String A_MONTH = 'aMonth'; // 一个月
  // 渗漏水
  static const String SEEPAGE_ID_WITH_TABBAR_BOTTOM = 'seepageIdWithTabbarBottom'; // 渗漏水id（主页切换中的渗漏水采集）
  // 稳定性
  static const String STABLE_ID_WITH_TABBAR_BOTTOM = 'stableIdWithTabbarBottom'; // 稳定性id（主页切换中的稳定性采集）
  // 水位
  static const String WATER_LEVEL_ID_WITH_TABBAR_BOTTOM = 'waterLevelIdWithTabbarBottom'; // 水位id（主页切换中的水位采集）
  // "采集"选项卡tab切换index
  static const String COLLECT_TAB_INDEX = 'collectTabIndex';
  // 时间筛选列表（格式：2019-08-27, 2019-08-23, 2019-08-28）
  static const String DATE_SELECT_LIST_ABOUT_OFFICE = 'dateSelectListAboutOffice'; // 办公室
  static const String DATE_SELECT_LIST_ABOUT_GUARD = 'dateSelectListAboutGuard'; // 保卫科
  static const String DATE_SELECT_LIST_ABOUT_DEVICE_DAY = 'dateSelectListAboutDeviceDay'; // 设备科日
  static const String DATE_SELECT_LIST_ABOUT_DEVICE_NIGHT = 'dateSelectListAboutDeviceNight'; // 设备科夜
  static const String DATE_SELECT_LIST_ABOUT_REPORT = 'dateSelectListAboutReport'; // 异常上报
  static const String DATE_SELECT_LIST_ABOUT_SEEPAGE = 'dateSelectListAboutSeepage'; // 渗漏水
  static const String DATE_SELECT_LIST_ABOUT_STABLE = 'dateSelectListAboutStable'; // 稳定性
  static const String DATE_SELECT_LIST_ABOUT_WATER_LEVEL = 'dateSelectListAboutWaterLevel'; // 水位
}
