import 'dart:async' show Future;
import 'dart:convert';

import 'package:package_info/package_info.dart';

import 'net_utils.dart';
import 'package:mdc_bhl/common/net/address.dart';
import 'package:mdc_bhl/model/user_info.dart';
import 'package:mdc_bhl/model/version.dart';

import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/model/data_result.dart';

class VersionResult {
  bool update;
  Data versionData;

  VersionResult(this.update, {this.versionData});
}

class DataUtils {
  // 登陆获取用户信息
  static Future<UserInfo> doLogin(Map<String, String> params) async {
    var response = await NetUtils.get(Address.doLogin(), params);

    Map<String, dynamic> resultMap = json.decode(response); // 多做一步编码

    UserInfo userInfo = UserInfo.fromJson(resultMap['ResultValue']);
    return userInfo;
  }

  /// 验证登陆
  static Future<DataResult> checkLogin() async {
    // dynamic userInfoResult = await LocalStorage.get(Config.USER_INFO_KEY);
    // print('存储的用户信息1 $userInfoResult');

    dynamic departmentID =
        await LocalStorage.get(Config.USER_DEPARTMENT_ID); // 获取用户类型

    bool result = (departmentID == null ? false : true);
    return DataResult(departmentID, result);
  }

  //  退出登陆
  // static Future<bool> logout() async {
  //   var response = await NetUtils.get(Address.loginOut());
  //   print('退出登陆 $response');
  //   return response['success'];
  // }

  /*
   * {"status":200,"data":{"version":"0.0.2","name":"FlutterGo"},"success":true}
   */
  // 检查版本
  static Future<VersionResult> checkVersion(Map<String, String> params) async {
    var response = await NetUtils.post(Address.getPgyUpdateURL(), params);
    Version version = Version.fromJson(response);
    var currVersion = version.data.buildVersion;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var localVersion = packageInfo.version;
    //  相同=0、大于=1、小于=-1
//  localVersion = '0.0.2';
//  currVersion = '1.0.6';
    if (currVersion.compareTo(localVersion) == 1) {
      return VersionResult(true, versionData: version.data);
    } else {
      return VersionResult(false);
    }
  }
}
