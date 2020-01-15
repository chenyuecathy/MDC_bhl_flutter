import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:mdc_bhl/page/task/item/task_device_detail_item.dart';
import 'package:mdc_bhl/page/task/item/task_device_abnormal_item.dart';
import 'package:mdc_bhl/page/task/item/task_device_open_close_item.dart';
import 'package:mdc_bhl/page/task/item/task_device_has_item.dart';

import 'package:mdc_bhl/utils/date_utils.dart';
import 'package:mdc_bhl/utils/userinfo_utils.dart';
import 'package:mdc_bhl/utils/common_utils.dart';
import 'package:mdc_bhl/utils/net_utils.dart';
import 'package:mdc_bhl/utils/task_net_utils.dart';

import 'package:mdc_bhl/common/net/address.dart';
import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/common/local/local_storage.dart';

import 'package:mdc_bhl/model/data_result.dart';
import 'package:mdc_bhl/widget/blank_widget.dart';
import 'package:mdc_bhl/db/tab_device_record_manager.dart';

/* 设备科日间巡查记录列表页面 */

class TaskDeviceDayPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new TaskDeviceDayPageState();
}

class TaskDeviceDayPageState extends State<TaskDeviceDayPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool showCustomText = false;
  bool isShowSubmitBtn = false;
  String inspectionId = '';

  // List<TaskModel> taskList = new List(); // 未用到
  List<TabDeviceRecordModel> taskRecords = new List();
  List<TabDeviceRecordModel> submitTaskRecords = new List();
  ScrollController _scrollController = new ScrollController();

  _initTasks() async {
    _fetchTasksFromNet();
  }

  Future<Null> _refresh() async {
    _fetchTasksFromNet();
  }

  Future _fetchTasksFromCache() async {
    inspectionId = await LocalStorage.get(Config.INSPENTION_REOCRDID+DepartmentTaskType.Device_Day.index.toString());

    try {
      List<TabDeviceRecordModel> tempTabRecords = await TabDeviceRecordManager.getCurrentCircleDeviceRecords( inspectionId, -1);
      print('device day length all :${tempTabRecords.length}');
      if (tempTabRecords.length > 0) {
        taskRecords.clear();
        setState(() {
          for (TabDeviceRecordModel model in tempTabRecords) {
            print('night ${model.recordTitle} upload:${model.isUpload} open:${model.isOpen}');

            taskRecords.add(model);
            if (model.isUpload == 0) isShowSubmitBtn = true;
          }
        });
        // print(' device day fetchTasksFromCache **************' +taskRecords.toString());
      }
    } catch (e) {
      CommonUtils.showCenterTextToast(e.toString());
    }
  }

  _fetchTasksFromNet() async {
    showCustomText = false;

    TaskNetUtils.getObservationPointsFromNet(DepartmentTaskType.Device_Day).then((result) {
      DataResult dataResult = result;
      if (!dataResult.result) {
        CommonUtils.showCenterTextToast(dataResult.description);
      } else if (dataResult.data == null) {
        CommonUtils.showCenterTextToast(dataResult.description);
        setState(() {
          showCustomText = true;
        });
      } else {
        _fetchTasksFromCache();
      }
    }).catchError((onError) {
      CommonUtils.showCenterTextToast(onError.toString());
    });
  }

  @override
  void initState() {
    _initTasks(); // 获取巡查内容数据
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
        body: Container(
          padding: EdgeInsets.all(2.0),
          child: showCustomText
              ? Container(
                  alignment: Alignment.center,
                  child: Text('今日无巡查',
                      style: TextStyle(fontSize: FontConfig.naviTextSize),
                      textAlign: TextAlign.center))
              : (taskRecords.length > 0
                  ? buildListView()
                  : BlankWidget(true, onClickButton: (value) async {
                      await _refresh();
                    })),
        ),
        floatingActionButton: (isShowSubmitBtn&&!showCustomText)
            ? FloatingActionButton(
                heroTag: 'task_device_day_page_btn',
                onPressed: _submit,
                tooltip: '提交',
                child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.file_upload),
                      Text("提交", style: new TextStyle(fontSize: 10))
                    ]))
            : Container());
  }

  RefreshIndicator buildListView() {
    return RefreshIndicator(
      onRefresh: _refresh,
      backgroundColor: Colors.white,
      child: ListView.separated(
        itemBuilder: buildItem,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemCount: taskRecords.length + 1,
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
      ),
    );
  }

  Widget buildItem(context, index) {
    if (index < taskRecords.length) {
      TabDeviceRecordModel taskRecord = taskRecords[index];
      print('task_device_day_page ${taskRecord.recordState}');
      if (taskRecord.recordState == 2) {
        // 2 开关
        return TaskDeviceOpenCloseItem(taskRecord, (tip) {}, (record) {
          taskRecords[index] = record;
        });
      } else if (taskRecord.recordState == 0) {
        // 0 正常/ 异常
        return TaskDeviceAbnormalItem(taskRecord, "设备科日间巡查记录", (wrongTip) {
          CommonUtils.showCenterTextToast(wrongTip);
        }, (record) {
          taskRecords[index] = record;
        });
      } else if (taskRecord.recordState == 3) {
        // 3 有/无
        return TaskDeviceHasItem(taskRecord, (tip) {
          CommonUtils.showCenterTextToast(tip);
        }, (record) {
          taskRecords[index] = record;
        });
      } else {
        // 1 温湿度  4 录入
        return TaskDeviceDetailItem(taskRecord, "设备科日间巡查记录",(wrongTip){
          CommonUtils.showCenterTextToast(wrongTip);
        });
      }
    } else {
      return SizedBox(height: 80);
    }
  }

  _submit() async {
    // 检查巡查时间
    DataResult checkResult = await DateUtils.checkInspectionTime(DepartmentTaskType.Device_Day);
    if (!checkResult.result) {
      CommonUtils.showCenterTextToast(checkResult.description);
      return;
    }

    // 取出所有数据
    submitTaskRecords = await TabDeviceRecordManager.getCurrentCircleDeviceRecords(inspectionId, -1);

    int inspectionRecordType = 1; // 0	异常  1	正常  2	未巡查
    bool completed = true;
    String inspectionContent = '';

    /// 1. 检查所有非异常和非录入类型的巡查内容都已经完成录入  recordType为-1时，表示未初始化。recordState为 1、4时，分别代表温湿度、录入的巡查数据
    for (var taskRecord in submitTaskRecords) {
      if (taskRecord.recordType == -1 &&
          taskRecord.recordState != 1 &&
          taskRecord.recordState != 4) {
        print('asd' + taskRecord.toString());

        /// 未巡查
        inspectionRecordType = 2;
        completed = false;
        inspectionContent = taskRecord.recordTitle;
        break;
      }
    }

    if (completed == false) {
      CommonUtils.showMultiAlertDialog(context, '温馨提示', "【$inspectionContent】未进行巡查,请核查后再提交！", ['确定', '继续提交']).then((index) {
        if (index == 0)
          return; // 确定
        else
          _checkDetailPageSubmit(inspectionRecordType, false); // 继续提交
      });
    } else {
      _checkDetailPageSubmit(
          inspectionRecordType, true); // 2. 检查所有异常记录和录入型记录都已经完成上传
    }
  }

  _checkDetailPageSubmit(int inspectionRecordType, bool allSubmit) {
    bool canSubmit = true;
    String inspectionContent = '';

    /// 2. 检查所有异常记录和录入型记录都已经完成上传
    for (var taskRecord in submitTaskRecords) {
      if (taskRecord.isUpload == 0 &&
          (taskRecord.recordType == 0 /*异常*/ ||
              taskRecord.recordState == 1 /*温湿度*/ ||
              taskRecord.recordState == 4 /*录入*/)) {
        canSubmit = false;
        inspectionContent = taskRecord.recordTitle;
        break;
      }
    }

    // /// 3. 检查所有已上传的异常记录，更改巡查记录状态
    // for (var taskRecord in submitTaskRecords) {
    //   if (taskRecord.isUpload == 1 && taskRecord.recordType == 0 /*异常*/) {
    //     inspectionRecordType = 0;
    //     break;
    //   }
    // }

    if (canSubmit == false) {
      CommonUtils.showAlertDialog(context, '温馨提示', "【$inspectionContent】的巡查内容需在详情页提交，请核实！", () {});
      return;
    } else {
      _submitInspectionRecord(inspectionRecordType, allSubmit);
    }
  }

  _submitInspectionRecord(int inspectionRecordType, bool allSubmit) async {
    /// 3. 配置cjsj参数，即所有未上传的巡查内容记录
    List<String> jsonList = [];
    List<String> uploadInspectionContentList = []; // 存放上传巡查内容ID的list，后期根据这些id修改本地数据库
    for (var taskRecord in submitTaskRecords) {
      /// 有异常记录
      if (taskRecord.recordType == 0) inspectionRecordType = 0;

      if (taskRecord.isUpload == 0 && taskRecord.recordType != -1) {
        // 未处理的数据不上传
        String cjsj = json.encode(taskRecord.toJson()); // 正常异常
        jsonList.add(cjsj);

        uploadInspectionContentList.add(taskRecord.inspectionContentId);
      }
    }
    print('jsonList: $jsonList');
    if (jsonList.length == 0) {
      CommonUtils.showTextToast('没有巡查内容需要上传！');
      return;
    }

    /// 4.配置xcjl参数，即巡查记录
    Map<String, dynamic> xcjlMap = Map();
    Map userinfoMap = await UserinfoUtils.getUserInfo();
    xcjlMap['Id'] = await LocalStorage.get(Config.INSPENTION_REOCRDID+DepartmentTaskType.Device_Day.index.toString());
    xcjlMap['Cjrid'] = userinfoMap[Config.USER_ID];
    xcjlMap['Cjrmc'] = userinfoMap[Config.USER_REALNAME];
    xcjlMap['Xclx'] = 0; // 0 设备科日巡查  1设备科夜巡查  2保卫科巡查
    xcjlMap['Jlzt'] = inspectionRecordType; // 0	异常  1	正常  2	未巡查

    /// 5. post
    String xcjl = json.encode(xcjlMap); // 正常异常
    print('device day xcjl' + xcjl);
    DataResult uploadDataResult = await NetUtils.uploadToNet(Address.saveMrjl(), {'cjsj': jsonList.toString(), 'xcjl': xcjl});
    print("device day saveMrjl返回值:${uploadDataResult.description}");

    /// 6.返回
    if (uploadDataResult.result) {
      await TabDeviceRecordManager.updateUploadStateWithInspectionContentIds(uploadInspectionContentList);

      List<TabDeviceRecordModel> tempTabRecords = await TabDeviceRecordManager.getCurrentCircleDeviceRecords(inspectionId, 0); // 查找未上传的记录
      if (tempTabRecords.length == 0) {
        taskRecords.clear();
        List<TabDeviceRecordModel> records = await TabDeviceRecordManager.getCurrentCircleDeviceRecords(inspectionId, -1);

        ///仅在本地无可提交数据的情况下将提交按钮隐藏,刷新列表
        setState(() {
          isShowSubmitBtn = false;

          for (TabDeviceRecordModel model in records) {
            taskRecords.add(model);
          }
        });
      }

      CommonUtils.showTextToast("提交成功");
    } else {
      CommonUtils.showTextToast(uploadDataResult.description);
      return;
    }
  }

  //   // 今日是否获取过任务
  // Future<bool> _todayGainTask() async {
  //   String deviceDayPreviousDownTimeString = await LocalStorage.get(Config.DOWNLOAD_DEVICE_DAY_INFO_TIME_KEY);
  //   print(
  //       'deviceDay previous time:$deviceDayPreviousDownTimeString now time:${DateTime.now().toString()}');
  //   bool isSameDay = false; // 默认不是同一天
  //   if (deviceDayPreviousDownTimeString != null) {
  //     DateTime previousDownTime =
  //         DateTime.parse(deviceDayPreviousDownTimeString);
  //     isSameDay = DateUtils.isSameDay(previousDownTime, DateTime.now());
  //   }
  //   // 如果不是同一天，则清空今日权限、inspectionId
  //   if (isSameDay == false) {
  //     await LocalStorage.remove(Config.DEVICE_DAY_TODAY_HAS_POWER_KEY);
  //     await LocalStorage.remove(Config.INSPENTION_REOCRDID_DEVIC_DAY);
  //   }
  //   return isSameDay;
  // }

  // // 获取今日权限
  // Future<bool> _todayHasPower() async {
  //   String todayHasPower = await LocalStorage.get(Config.DEVICE_DAY_TODAY_HAS_POWER_KEY);
  //   if (todayHasPower == null) {
  //     // 根据用户id，获取今日操作任务的权限（GetTodayFunc——get请求）
  //     String userId = await UserinfoUtils.getUserId();
  //     Map<String, String> parameter = {'Ryid': userId};
  //     DataResult dataResult = await NetUtils.getFromNet(Address.getTodayPower(), parameter);
  //     // dataResult.data：""-今日无权限、"0,1"-有设备科权限、"2"-有保卫科权限、"4"-有办公室权限
  //     if (dataResult.data != "") {
  //       // 用户有今日操作任务的权限
  //       if (dataResult.data == "0") {
  //         // 有办公室权限
  //         await LocalStorage.save(
  //             Config.DEVICE_DAY_TODAY_HAS_POWER_KEY, 'true');
  //         return true;
  //       } else {
  //         // 其他科室权限
  //         await LocalStorage.save(
  //             Config.DEVICE_DAY_TODAY_HAS_POWER_KEY, 'false');
  //         return false;
  //       }
  //     } else {
  //       // 用户无今日操作任务的权限
  //       await LocalStorage.save(Config.DEVICE_DAY_TODAY_HAS_POWER_KEY, 'false');
  //       return false;
  //     }
  //   } else {
  //     if (todayHasPower == 'true')
  //       return true;
  //     else
  //       return false;
  //   }
  // }
}
