import 'dart:io';
// import 'package:mdc_bhl/common/config/config.dart';

/** url address */

///地址数据
class Address {
//   static const String host = "http://172.16.103.6:8868/api/"; // 许云涛机器（内网）
//   static const String image_host = "http://172.16.103.6:8869/"; // 图片拼接根地址

  // static const String host = "http://172.16.103.18:1321/api/"; // 黄东东机器（统一出口）
  // static const String image_host = "http://172.16.103.18:1322/"; // 图片拼接根地址

  // static const String host = "http://bhl-ht.geo-compass.com/api/"; // 外网地址
  // static const String image_host = "http://bhl-ht.geo-compass.com/bhl_fj/"; // 图片拼接根地址


  static const String host = "http://123.146.225.94:9709/api/"; // 外网地址
  static const String image_host = "http://123.146.225.94:9709/bhl_fj/"; // 图片拼接根地址


  // static const String hostWeb = "https://github.com/";
  // static const String downloadUrl = 'https://www.pgyer.com/GSYGithubApp';
  // static const String graphicHost = 'https://ghchart.rshah.org/';
  // static const String updateUrl = 'https://www.pgyer.com/vj2B';

  //"http://183.230.1.245:9183/androidAPK/version.xml"; //更新版本地址

 static getPgyUpdateURL(){
   if (Platform.isIOS) {
     return "http://www.pgyer.com/apiv2/app/check?_api_key=b9888ba9a99310de23c3833efdb5e229&appKey=f25ab4484179dbcefcbd5e871544e162";
   } else {
     return "http://www.pgyer.com/apiv2/app/check?_api_key=b9888ba9a99310de23c3833efdb5e229&appKey=91364cd09117ef8a7be8e05b7c00a359";
   }
 }


  /// 获取日常巡查内容（设备科和保卫科）、获取异常上报id（异常上报id一天一个）
  static getRCXCB() {
    return "${host}RCXC/GetRCXCB";
  }

   static getRCXRL() {
    return "${host}RCXC/GetGzjlb";
  }

  /// 获取客流高峰采集点（办公室）
  static getCJD() {
    return "${host}KLGFZP/GetCJD";
  }

  /// 获取所有用户最后一次上传的水位数据
  static getSw() {
    return "${host}JcsjData/GetSwNewest";
  }

  /// 主动获取循环水数据（首次加载）
  static getCircularWater() {
    return "${host}JcsjData/GetXhsllNew";
  }

  /// 保存客流高峰数据（办公室）
  static saveCJSJ() {
    return "${host}KLGFZP/SaveCJSJ";
  }

  /// 保存异常巡查记录
  static saveRCXCCJSJ() {
    return "${host}RCXC/SaveCJSJ";
  }

  /// 保存温湿度
  static saveWSD() {
    return "${host}RCXC/SaveWSD";
  }

  /// 保存每日记录
  static saveMrjl() {
    return "${host}RCXC/SaveMrjl";
  }

    /// 保存处置数据
  static saveYccz() {
    return "${host}RCXC/SaveYccz";
  }

  /// 保存异常上报数据
  static saveYCJL() {
    return "${host}RCXC/SaveYCJL";
  }

  /// 保存渗漏水数据
  static saveSls() {
    return "${host}RCXC/SaveSls";
  }

  /// 保存稳定性数据
  static saveWdxSglr() {
    return "${host}RCXC/SaveWdxSglr";
  }

  /// 保存水位数据
  static saveSw() {
    return "${host}RCXC/SaveSw";
  }

  /// 普通登陆
  static doLogin() {
    return "${host}User/LoginNoVCodeEx";
  }

  /// 获取用户今日权限（get请求）
  /*
   * 参数：Ryid——人员id
   * 返回值：
     返回Ryid今日无巡查任务时返回结果
     {
        "ISSUCCESS": true,
        "RESULTVALUE": "",        //此项为返回xclx，无巡查任务返回空字符串
        "RESULTDESCRIPTION": "今日无巡查任务！"
     }
     返回Ryid今日有巡查任务时返回结果
     {
        "ISSUCCESS": true,
        "RESULTVALUE": "1,0",
        "RESULTDESCRIPTION": null
     }
   */
  static getTodayPower() {
    return "${host}RCXC/GetTodayFunc";
  }

  /// 获取验证码
  static getCheckcode() {
    return "${host}User/GetMessageCode";
  }

  /// 验证码登陆
  static checkLogin() {
    return "${host}User/PhonenVerify";
  }

  /// 更换密码
  static changePwd() {
    return "${host}User/UpdatePWDEx";
  }

  /// 更新头像
  static changeAvator() {
    return "${host}User/UpdateUserHeadImgEx";
  }

  /// 检查版本
  static checkAppVersion() {
    return "${host}checkAppVersion";
  }

  /// 上传图片
  /*
   * lj:12 日常巡查
   * lj:14 旅游与游客管理
   */
  static uploadImg(String lj) {
    return "${host}UpLoad/FileSave?LJ=$lj";
  }
}
