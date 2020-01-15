import 'dart:convert';

import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/common/config/config.dart';

class UserinfoUtils {
  static getUserId() async {
    var userInfo = await LocalStorage.get(Config.USER_INFO_KEY);
    Map<String, dynamic> responseDictionary = json.decode(userInfo);
    return responseDictionary[Config.USER_ID];
  }
  static getUserRealName() async {
    var userInfo = await LocalStorage.get(Config.USER_INFO_KEY);
    Map<String, dynamic> responseDictionary = json.decode(userInfo);
    return responseDictionary[Config.USER_REALNAME];
  }

    static getUserInfo() async {
    var userInfo = await LocalStorage.get(Config.USER_INFO_KEY);
    Map<String, dynamic> responseDictionary = json.decode(userInfo);
    return responseDictionary;
  }

}
