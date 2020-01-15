import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';

import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/common/net/address.dart';
import 'package:mdc_bhl/db/tab_device_record_manager.dart';
import 'package:mdc_bhl/model/data_result.dart';
import 'package:mdc_bhl/utils/net_utils.dart';
import 'package:mdc_bhl/utils/userinfo_utils.dart';

// init dio object
var dio = new Dio(BaseOptions(connectTimeout: 30000 /*, headers: optHeader*/));

class TaskNetUtils {
  ///判断是否联网
  static Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  /// 获取任务日历
  static Future<DataResult> getTaskCalendarFromNet(DepartmentTaskType type) async {

    try {
      /// 1.判断网络连通性
      bool isConnect = await isConnected();
      if (!isConnect) {
        return DataResult(null, false, description: '设备未联网');
      }

      /// 2.配置URI和参数
      String userid = await UserinfoUtils.getUserId(); 
      String requestUrl = Address.getRCXRL() + '?Ryid=$userid';

      /// 2.配置URI和参数
      Response response = await dio.get(requestUrl);
      print("response:$response");

      /// 3.处理response出错
      if (response.statusCode != 200)
        return DataResult(null, false, description: '服务出错，请稍后再试');

      /// 4.解析response，包括成功和失败两种情况
      ///A JsonCodec encodes JSON objects to strings and decodes strings to JSON objects.
      ///https://api.dartlang.org/stable/1.24.3/dart-convert/JsonCodec-class.html
      Map<String, dynamic> mapResponse = json.decode(response.data); // json map

      dynamic isSuccess = mapResponse['IsSuccess'];

      if (isSuccess) {
        dynamic mapResultValue = mapResponse['ResultValue']; // Map<String, dynamic>
        String jsonString = json.encode(mapResultValue);
        await LocalStorage.save(Config.TASK_CALENDAR+type.index.toString(), jsonString);
        return DataResult(mapResultValue, true, description: '获取数据成功');
      } else {
        await LocalStorage.remove(Config.TASK_CALENDAR+type.index.toString());
        return DataResult(null, false, description: mapResponse['ResultDescription'] ?? '未知错误，请稍后再试');
      }
    } on DioError catch (e) {
      await LocalStorage.remove(Config.TASK_CALENDAR+type.index.toString());

      String description = NetUtils.dioErrorTipExtract(e);
      return DataResult(null, false, description: description);
    }
  }

  /// 针对特定response封装的get方法
  static Future getObservationPointsFromNet(DepartmentTaskType type) async {
    try {
      /// 1.判断网络连通性
      bool isConnect = await isConnected();
      if (!isConnect) {
        return DataResult(null, false, description: '设备未联网');
      }

      /// 2.配置URI和参数
      String requestUrl = '';
      if (type == DepartmentTaskType.Office) {
        // office
        requestUrl = Address.getCJD();
      } else {
        String userid = await UserinfoUtils.getUserId(); //'ad58ffd6-d3ea-4450-949a-ed28947a3571'
        requestUrl = Address.getRCXCB() + '?Ryid=$userid&Xclx=${type.index.toString()}';
      }

      /// 3.发出请求
      Response response = await dio.get(requestUrl);

      /// 3.处理response出错
      if (response.statusCode != 200) {
        return DataResult(null, false, description: '服务出错，请稍后再试');
      }

      /// 4.解析response，包括成功和失败两种情况
      ///A JsonCodec encodes JSON objects to strings and decodes strings to JSON objects.
      ///https://api.dartlang.org/stable/1.24.3/dart-convert/JsonCodec-class.html
      Map<String, dynamic> mapResponse = json.decode(response.data); // json map

      dynamic isSuccess = mapResponse['IsSuccess'];

      if (isSuccess) {
        dynamic mapResultValue = mapResponse['ResultValue'];
        print('mapResultValue $mapResultValue');

        if (type == DepartmentTaskType.Office) {
          String jsonString = json.encode({'XCNR': mapResultValue});
          await LocalStorage.save(Config.DEPARTMENT_ID_OFFICE + type.index.toString(), jsonString);
        }else {
         if(mapResultValue== null) return DataResult(null, true, description:mapResponse['ResultDescription']);
          
          // 巡查记录id
          String oldXcjlid = await LocalStorage.get(Config.INSPENTION_REOCRDID+type.index.toString());
          String xcjlid = mapResultValue['Xcjlid'];
          print('===1 $oldXcjlid $xcjlid');
          if (oldXcjlid == null || oldXcjlid != xcjlid) {
            print('===1 after');

            // 巡查内容变动的情况下，生成一批巡查记录数据
            String jsonString = json.encode(mapResultValue);
            await TabDeviceRecordManager.insertBatchData(jsonString, type.index);
            await LocalStorage.save(Config.INSPENTION_REOCRDID + type.index.toString(), xcjlid);

            // 巡查起止时间
            String inspectionTime = mapResultValue['Xckssj'] + ',' + mapResultValue['Xcjssj'];
            String key = Config.INSPENTION_TIME + type.index.toString();
            await LocalStorage.save(key, inspectionTime);
          }

          return DataResult(mapResultValue['Xcnr'], true, description: '获取数据成功');
        } 
        // else {
        //   return DataResult(null, false,
        //       description: mapResponse['ResultDescription'] ?? '未知错误，请稍后再试');
        // }
      }
    } catch (e) {
      return DataResult(null, false, description: e.toString());
    }

  }

  // /// 针对特定response封装的get方法
  // static Future getObservationPointsFromNet(DepartmentTaskType type) async {
  //   try {
  //     /// 1.判断网络连通性
  //     bool isConnect = await isConnected();
  //     if (!isConnect) {
  //       return DataResult(null, false, description: '设备未联网');
  //     }

  //     /// 2.配置URI和参数
  //     String requestUrl = '';
  //     if (type == DepartmentTaskType.Office) {
  //       // office
  //       requestUrl = Address.getCJD();
  //     } else {
  //       // requestUrl = Address.getRCXCB() + '?xclx=${type.index}';
  //       requestUrl = Address.getRCXCB();
  //     }

  //     /// 3.发出请求
  //     Response response = await dio.get(requestUrl);

  //     /// 3.处理response出错
  //     if (response.statusCode != 200) {
  //       return DataResult(null, false, description: '服务出错，请稍后再试');
  //     }

  //     /// 4.解析response，包括成功和失败两种情况
  //     ///A JsonCodec encodes JSON objects to strings and decodes strings to JSON objects.
  //     ///https://api.dartlang.org/stable/1.24.3/dart-convert/JsonCodec-class.html
  //     Map<String, dynamic> mapResponse = json.decode(response.data); // json map

  //     dynamic isSuccess = mapResponse['IsSuccess'];

  //     if (isSuccess) {
  //       // office此字段是list  其它为字典
  //       dynamic mapResultValue =mapResponse['ResultValue'];
  //       print('mapResultValue $mapResultValue');

  //       await LocalStorage.save('FetchPointSuccess' + type.index.toString(), '1');  // 存储获取值成功与否

  //       /// 保存巡查记录id
  //       if (type == DepartmentTaskType.Office) {
  //         String jsonString = json.encode({'XCNR': mapResultValue});
  //         await LocalStorage.save(Config.DEPARTMENT_ID_OFFICE + type.index.toString(), jsonString);
  //       } else {
  //         String xcjlid = mapResultValue['xcjlid'];
  //         print(' xcjlid : ' + xcjlid);

  //         String oldXcjlid;

  //         if (type == DepartmentTaskType.Guard) {
  //           // 保卫科
  //           String jsonString = json.encode(mapResultValue);
  //           oldXcjlid = await LocalStorage.get(Config.INSPENTION_REOCRDID_GUARD);
  //           print('===1 $oldXcjlid $xcjlid');

  //           if (oldXcjlid == null || oldXcjlid != xcjlid) {
  //              print('===1 after');
  //             // LocalStorage.save(Config.NEW_RECORD_GUARD, '1'); // 是否生成新的记录 0是不生成 1是生成
  //              await TabDeviceRecordManager.insertBatchData(jsonString, 2);
  //           }

  //           LocalStorage.save(Config.INSPENTION_REOCRDID_GUARD, xcjlid); // 巡查记录id
  //           LocalStorage.save(Config.DEPARTMENT_ID_GUARD + type.index.toString(), jsonString); // 巡查内容集合
  //         } else if (type == DepartmentTaskType.Device_Day) {
  //           // 设备科日间
  //           String jsonString = json.encode(mapResultValue);
  //           oldXcjlid = await LocalStorage.get(Config.INSPENTION_REOCRDID_DEVIC_DAY);

  //           print('===2 $oldXcjlid $xcjlid');
  //           if (oldXcjlid == null || oldXcjlid != xcjlid) {
  //           print('===2 after');

  //             // LocalStorage.save(Config.NEW_RECORD_GUARD, '1'); // 是否生成新的记录 0是不生成 1是生成
  //             await TabDeviceRecordManager.insertBatchData(jsonString, 0);
  //           }
  //           LocalStorage.save(Config.INSPENTION_REOCRDID_DEVIC_DAY, xcjlid); // 巡查记录id
  //           LocalStorage.save(Config.DEPARTMENT_ID_DEVICE + type.index.toString(),jsonString); // 巡查内容集合

  //         } else if (type == DepartmentTaskType.Device_Night) {

  //           // 设备科夜间
  //           String jsonString = json.encode(mapResultValue);
  //           oldXcjlid = await LocalStorage.get(Config.INSPENTION_REOCRDID_DEVICE_NIGHT);

  //           print('===3 $oldXcjlid $xcjlid');
  //           if (oldXcjlid == null || oldXcjlid != xcjlid) {
  //             // LocalStorage.save(Config.NEW_RECORD_GUARD, '1'); // 是否生成新的记录 0是不生成 1是生成
  //             print('===3 after');

  //             await TabDeviceRecordManager.insertBatchData(jsonString, 1);
  //           }
  //           LocalStorage.save(Config.INSPENTION_REOCRDID_DEVICE_NIGHT, xcjlid); // 巡查记录id
  //           LocalStorage.save(Config.DEPARTMENT_ID_DEVICE + type.index.toString(),jsonString);  // 巡查内容集合
  //         }
  //       }

  //       return DataResult(mapResultValue, true, description: '获取数据成功');
  //     } else {
  //       await LocalStorage.save('FetchPointSuccess' + type.index.toString(), '0');

  //       return DataResult(null, false,description: mapResponse['ResultDescription'] ?? '未知错误，请稍后再试');
  //     }
  //   } catch (e) {
  //     await LocalStorage.save('FetchPointSuccess' + type.index.toString(), '0');

  //     return DataResult(null, false, description: e.toString());
  //   }
  // }

}
