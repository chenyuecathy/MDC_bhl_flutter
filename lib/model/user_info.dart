import 'dart:convert';

import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/model/data_result.dart';

class UserInfo {
  String id;
  String name;
  String userType;
  String pwd;
  String mobile;
  String department;
  String departmentName;
  String realname;
  String sex;
  String deviceId;
  String photoPath;

  UserInfo(
      {this.id,
      this.name,
      this.department,
      this.userType,
      this.pwd,
      this.mobile,
      this.departmentName,
      this.realname,
      this.sex = '未知',
      this.deviceId,
      this.photoPath});

  /// json object to object
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
        id: json['ID'],
        name: json['NAME'],
        department: json['DWID'],
        userType: json['USERTYPE'],
        // pwd: json['pwd'],
        mobile: json['MOBILE'],
        departmentName: json['DWName'],
        realname: json['REALNAME'],
        //sex: json['sex'],
        deviceId: json['DEVICEID'],
        photoPath: json['PHOTOPATH']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['REALNAME'] = this.realname;
    data['DWName'] = this.departmentName;
    data['DWID'] = this.department;
    data['ID'] = this.id;
    data['NAME'] = this.name;
    data['MOBILE'] = this.mobile;
    data['DEVICEID'] = this.deviceId;
    data['PHOTOPATH'] = this.photoPath;
    data['USERTYPE'] = this.userType;
    data['PASSWORD'] = this.pwd;
    return data;
  }
}


class UserInfoCache {
  static getUserInfoLocal() async {
    var userText = await LocalStorage.get(Config.USER_INFO_KEY);
    if (userText != null) {
      var userMap = json.decode(userText);
      UserInfo user = UserInfo.fromJson(userMap);
      return new DataResult(user, true);
    } else {
      return new DataResult(null, false);
    }
  }
}


