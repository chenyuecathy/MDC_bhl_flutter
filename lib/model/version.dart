class Data {
  String buildBuildVersion; // build版本
  String forceUpdateVersion;
  String forceUpdateVersionNo;
  bool needForceUpdate;
  String
      downloadURL; //"itms-services://?action=download-manifest&url=https://www.pgyer.com/app/plist/62a8dec7bba9afcb9d3af2fc525552f4/update/s.plist"
  bool buildHaveNewVersion;
  String buildVersionNo; // build number
  String buildVersion; // 版本号
  String buildShortcutUrl; //"https://www.pgyer.com/AaWD"
  String buildUpdateDescription; // 描述

  Data(
      {this.buildBuildVersion,
      this.forceUpdateVersion,
      this.forceUpdateVersionNo,
      this.needForceUpdate,
      this.downloadURL,
      this.buildHaveNewVersion,
      this.buildVersionNo,
      this.buildVersion,
      this.buildShortcutUrl,
      this.buildUpdateDescription});

  Data.fromJson(Map<String, dynamic> json) {
    buildBuildVersion = json['buildBuildVersion'];
    forceUpdateVersion = json['forceUpdateVersion'];
    forceUpdateVersionNo = json['forceUpdateVersionNo'];
    needForceUpdate = json['needForceUpdate'];
    downloadURL = json['downloadURL'];
    buildHaveNewVersion = json['buildHaveNewVersion'];
    buildVersionNo = json['buildVersionNo'];
    buildVersion = json['buildVersion'];
    buildShortcutUrl = json['buildShortcutUrl'];
    buildUpdateDescription = json['buildUpdateDescription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['buildBuildVersion'] = this.buildBuildVersion;
    data['forceUpdateVersion'] = this.forceUpdateVersion;
    data['forceUpdateVersionNo'] = this.forceUpdateVersionNo;
    data['needForceUpdate'] = this.needForceUpdate;
    data['downloadURL'] = this.downloadURL;
    data['buildHaveNewVersion'] = this.buildHaveNewVersion;
    data['buildVersionNo'] = this.buildVersionNo;
    data['buildVersion'] = this.buildVersion;
    data['buildShortcutUrl'] = this.buildShortcutUrl;
    data['buildUpdateDescription'] = this.buildUpdateDescription;
    return data;
  }

  @override
  String toString() {
    return 'buildBuildVersion: $buildBuildVersion,downloadURL: $downloadURL,buildVersionNo: $buildVersionNo,buildVersion: $buildVersion, buildShortcutUrl: $buildShortcutUrl,buildUpdateDescription: $buildUpdateDescription';
  }
}

class Version {
  int code;
  String message;
  Data data;

  Version({this.code, this.message, this.data});

  Version.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return 'code: $code ,message: $message,date: ${data.toString()}';
  }
}
