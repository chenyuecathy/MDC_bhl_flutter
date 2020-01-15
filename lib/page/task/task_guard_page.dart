import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';

import 'package:mdc_bhl/page/task/item/task_device_abnormal_item.dart';
import 'package:mdc_bhl/page/task/item/task_device_detail_item.dart';
import 'package:mdc_bhl/page/task/item/task_device_open_close_item.dart';
import 'package:mdc_bhl/page/task/item/task_device_has_item.dart';

import 'package:mdc_bhl/utils/userinfo_utils.dart';
import 'package:mdc_bhl/utils/task_net_utils.dart';
import 'package:mdc_bhl/utils/net_utils.dart';
import 'package:mdc_bhl/utils/common_utils.dart';
import 'package:mdc_bhl/utils/date_utils.dart';

import 'package:mdc_bhl/common/net/address.dart';
import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/common/config/style.dart';

import 'package:mdc_bhl/widget/gradient_appbar.dart';
import 'package:mdc_bhl/widget/blank_widget.dart';

import 'package:mdc_bhl/model/data_result.dart';
import 'package:mdc_bhl/db/tab_device_record_manager.dart';
import 'package:mdc_bhl/icon/custom_icons.dart';

import 'task_calendar_page.dart';

/* 保卫科巡查记录页面 */
class TaskGuardPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TaskGuardPageState();
}

class TaskGuardPageState extends State<TaskGuardPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String inspectionId = '';

  bool showCustomText = false;

  List<TabDeviceRecordModel> taskRecords = List();
  List<TabDeviceRecordModel> submitTaskRecords = List();
  ScrollController _scrollController = ScrollController();

  _initTasks() async {
    _fetchTasksFromNet();
  }

  Future<Null> _refresh() async {
    _fetchTasksFromNet();
  }

  Future _fetchTasksFromCache() async {
    inspectionId = await LocalStorage.get(Config.INSPENTION_REOCRDID+DepartmentTaskType.Guard.index.toString());

    try {
      List<TabDeviceRecordModel> tempTabRecords =
          await TabDeviceRecordManager.getCurrentCircleGuardRecords(
              inspectionId, 0);
      print('guard length all :${tempTabRecords.length}');

      if (tempTabRecords.length > 0) {
        taskRecords.clear();

        setState(() {
          for (TabDeviceRecordModel model in tempTabRecords) {
            taskRecords.add(model);
          }
        });
      }
    } catch (e) {
      CommonUtils.showCenterTextToast(e.toString());
    }
  }

  _fetchTasksFromNet() async {
    showCustomText = false;

    TaskNetUtils.getObservationPointsFromNet(DepartmentTaskType.Guard)
        .then((result) {
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
    _initTasks();
    
    Future.delayed( const Duration(milliseconds: 2000), _fetchTaskCalendarFromNet);

    super.initState();
  }

  _fetchTaskCalendarFromNet() async {
    TaskNetUtils.getTaskCalendarFromNet(DepartmentTaskType.Guard).then((DataResult result) {
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    print('guard widget build');
    return Scaffold(
        appBar: GradientAppBar(
          gradientStart: Color(0xFF2171F5),
          gradientEnd: Color(0xFF49A2FC),
          centerTitle: true,
          title: Text('任务', style: TextStyle(fontSize: FontConfig.naviTextSize)),
          actions: <Widget>[IconButton( 
            icon: Icon(CustomIcons.task,
            color: Colors.white), 
            tooltip: '任务日历', 
            onPressed: (){
              Navigator.push(context,  MaterialPageRoute(builder: (BuildContext context) => TaskCalendarPage(DepartmentTaskType.Guard)));
            }), ],
        ),
        body: showCustomText
            ? Container(
                alignment: Alignment.center,
                child: Text('今日无巡查',
                    style: TextStyle(fontSize: FontConfig.naviTextSize),
                    textAlign: TextAlign.center))
            : (taskRecords.length > 0
                ? buildListView()
                : BlankWidget(true, onClickButton: (value) async {
                    print('click me ' + value);
                    await _refresh();
                  })),
        floatingActionButton: Opacity(
          opacity: (taskRecords.length == 0 || showCustomText) ? 0.0 : 1.0,
          child: FloatingActionButton(
              heroTag: 'task_guard_page_btn',
              onPressed: _submit,
              tooltip: '提交',
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.file_upload),
                    Text("提交", style: TextStyle(fontSize: 10))
                  ])),
        ));
  }

  buildListView() {
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

  Widget buildItem(BuildContext context, int index) {
    if (index < taskRecords.length) {
      TabDeviceRecordModel taskRecord = taskRecords[index];
      // print('itemBuilder***** 【${taskRecord.recordTitle} recordType:${taskRecord.recordType} upload:${taskRecord.isUpload} time:${taskRecord.time} 】';

      if (taskRecord.recordState == 2) {
        // 2 开关
        return TaskDeviceOpenCloseItem(taskRecord, (tip) {
          CommonUtils.showCenterTextToast(tip);
        }, (record) {
          taskRecords[index] = record;
        });
      } else if (taskRecord.recordState == 0) {
        // 0 正常/ 异常
        return TaskDeviceAbnormalItem(taskRecord, "保卫科巡查记录", (wrongTip) {
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
        return TaskDeviceDetailItem(taskRecord, "保卫科巡查记录",(wrongTip){
          CommonUtils.showCenterTextToast(wrongTip);
        });
      }
    } else {
      return SizedBox(height: 80);
    }
  }

  _submit() async {

    // 检查巡查时间
    DataResult checkResult = await DateUtils.checkInspectionTime(DepartmentTaskType.Guard);
    if (!checkResult.result) {
      CommonUtils.showCenterTextToast(checkResult.description);
      return;
    }

    submitTaskRecords = await TabDeviceRecordManager.getCurrentCircleGuardRecords(inspectionId, -1);

    int inspectionRecordType = 1; // 0	异常  1	正常  2	未巡查
    bool completed = true;
    String inspectionContent = '';

    /// 1. 检查所有记录都已经完成录入
    for (var taskRecord in submitTaskRecords) {
      if (taskRecord.recordType == -1 &&
          taskRecord.recordState != 1 &&
          taskRecord.recordState != 4) {
        /// 未巡查
        inspectionRecordType = 2;
        completed = false;
        inspectionContent = taskRecord.recordTitle;
        break;
      }
    }

    if (completed == false) {
      CommonUtils.showMultiAlertDialog(context, '温馨提示',
          "【$inspectionContent】未进行巡查,请核对后再提交！", ['确定', '继续提交']).then((index) {
        print(index);
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

/* allsubmit：是否全部提交 true为全部， false为不是全部 */
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

    if (canSubmit == false) {
      CommonUtils.showAlertDialog(
          context, '温馨提示', "【$inspectionContent】的巡查内容需在详情页提交，请核实！", () {});
      return;
    } else {
      _submitInspectionRecord(inspectionRecordType, allSubmit);
    }
  }

  _submitInspectionRecord(int inspectionRecordType, bool allSubmit) async {
    ///3. ����置cjsj参数，即所有未上传的巡查内容记录
    List<dynamic> jsonList = [];
    List<String> uploadInspectionContentList =
        []; //存放上传巡查内容ID的list，后期根据这些id修改本地数据库
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
    print('guard jsonList: $jsonList');
    if (jsonList.length == 0) {
      CommonUtils.showTextToast('没有巡查内容需要上传！');
      return;
    }

    /// 4.配置xcjl参数，即巡查记录
    Map<String, dynamic> xcjlMap = Map();
    Map userinfoMap = await UserinfoUtils.getUserInfo();
    xcjlMap['Id'] = await LocalStorage.get(Config.INSPENTION_REOCRDID+DepartmentTaskType.Guard.index.toString());
    xcjlMap['Cjrid'] = userinfoMap[Config.USER_ID];
    xcjlMap['Cjrmc'] = userinfoMap[Config.USER_REALNAME];
    xcjlMap['Xclx'] = 2; // 0 设备科日巡查  1设备科夜巡查  2保卫科巡查
    xcjlMap['Jlzt'] = inspectionRecordType; // 0	异常  1	正常  2	未巡查

    /// 5. post
    String xcjl = json.encode(xcjlMap); // 正常异常
    print('guard xcjl' + xcjl);
    DataResult uploadDataResult = await NetUtils.uploadToNet(Address.saveMrjl(), {'cjsj': jsonList.toString(), 'xcjl': xcjl});
    print("guard saveMrjl返回值:${uploadDataResult.description}");

    /// 6.返回
    if (uploadDataResult.result) {
      // 更新状态
      await TabDeviceRecordManager.updateUploadStateWithInspectionContentIds(uploadInspectionContentList);

      List<TabDeviceRecordModel> tempTabRecords = await TabDeviceRecordManager.getCurrentCircleGuardRecords( inspectionId, 0);
      print('guard tempTabRecords:${tempTabRecords.length}');
      if (tempTabRecords.length == 0) {
        await TabDeviceRecordManager.updatOpenStateWithInspectionId(inspectionId); // 位置很重要

        //仅在本地无可提交数据的情况下重新生成数据
        String jsonString = await LocalStorage.get(Config.DEPARTMENT_ID_GUARD + '2');
        await TabDeviceRecordManager.insertBatchData(jsonString, 2);

        List<TabDeviceRecordModel> insertTabRecords = await TabDeviceRecordManager.getCurrentCircleGuardRecords(inspectionId, 0);
        setState(() {
          taskRecords.clear();

          for (TabDeviceRecordModel model in insertTabRecords) {
            // print('insert ===' + model.toString());
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
}
