import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/event/index.dart';
import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/db/tab_device_record_manager.dart';
import 'package:mdc_bhl/utils/date_picker_utils.dart';
import 'package:mdc_bhl/utils/eventbus_utils.dart';
import 'package:mdc_bhl/widget/blank_widget.dart';

import 'package:mdc_bhl/page/record/item/task_device_record_item.dart';


/* 我的任务-设备科日间巡查页面 */
class MyTaskListDeviceDayPage extends StatefulWidget {
  final String userId;

  MyTaskListDeviceDayPage(this.userId);

  @override
  State<StatefulWidget> createState() => MyTaskListDeviceDayPageState();
}

class MyTaskListDeviceDayPageState extends State<MyTaskListDeviceDayPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

   StreamSubscription subscription;

  List<String> _dateKeys = [];
  Map<String, List<TabDeviceRecordModel>> _tasksMap = Map();

  @override
  void initState() {
    _fetchTasksMapSortByDate();

    super.initState();

     //订阅eventbus
     subscription = eventBus.on<EventUtil>().listen((event) {
       if (event.message == Config.REFRESH_DEVICE_DAY_LIST) {
         _refresh();
       }
     });
  }

  @override
  void dispose() {
    super.dispose();
     if (subscription != null) {
       //取消eventbus订阅
       subscription.cancel();
     }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
        onRefresh: _refresh,
        backgroundColor: Colors.white,
        child: _dateKeys.length == 0
            ? BlankWidget(false)
            : ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  String datekey = _dateKeys[index];

                  return TaskDeviceRecordItem(
                      recordType: 1,
                      dateTitle: datekey,
                      taskModels: _tasksMap[datekey]); // 1——设备科（任务）
                },
                itemCount: _dateKeys.length,
                physics: const AlwaysScrollableScrollPhysics(),
              ));
  }

  /// pull down refresh
  Future<Null> _refresh() async {
    // _dateKeys.clear(); // reset data
    await _fetchTasksMapSortByDate();
    return;
  }

  _fetchTasksMapSortByDate() async {
    List<TabDeviceRecordModel> taskList = await TabDeviceRecordManager()
        .queryUploadRecordsByUserid(widget.userId, 0);

    // print('device day record list:${taskList.length}');
    // 获取筛选
    String dateSelectListAboutDeviceDay =
        await LocalStorage.get(Config.DATE_SELECT_LIST_ABOUT_DEVICE_DAY);

    _dateKeys.clear();
    _tasksMap.clear();

    setState(() {
      for (var item in taskList) {
        String day = item.time.substring(0, 10); // 获取日期

        List<TabDeviceRecordModel> oneDayTasks = _tasksMap[day];

        // oneDayTasks ??= [];  // 注意处理

        if (oneDayTasks == null) {
          oneDayTasks = []; // 注意处理
          _dateKeys.add(day); // 防止重复添加
        }

        if (DatePickerUtils.getIsSelectDate(dateSelectListAboutDeviceDay, day)) {
          // print(item);
          oneDayTasks.add(item);
          _tasksMap[day] = oneDayTasks;
        }
      }
    });
  }

  // /// 获取设备科日记录
  // _fetchRecord([Map<String, dynamic> params]) async {
  //   List<TabDeviceRecordModel> tabDeviceRecordModelList =
  //       await TabDeviceRecordManager().queryUnoperatedOrderSort();
  //   // 获取筛选
  //   String dateSelectListAboutDeviceDay =
  //       await LocalStorage.get(Config.DATE_SELECT_LIST_ABOUT_DEVICE_DAY);
  //   // 获取记录
  //   setState(() {
  //     for (int i = 0; i < tabDeviceRecordModelList.length; i++) {
  //       bool _isThisUser =
  //           (tabDeviceRecordModelList[i].inspectorId == widget.userId); // 该用户
  //       bool _isDeviceNight =
  //           (tabDeviceRecordModelList[i].inspectionType == 0); // 设备科日
  //       bool _isSelectDate = DatePickerUtils.getIsSelectDate(
  //           dateSelectListAboutDeviceDay,
  //           tabDeviceRecordModelList[i].time); // 是否为筛选的日期
  //       if (_isThisUser && _isDeviceNight && _isSelectDate) {
  //         // if (!_inspectionIdList.contains(tabDeviceRecordModelList[i].inspectionId)) { // inspectionIdList不存在该inspectionId则添加
  //         _dateKeys.add(tabDeviceRecordModelList[i].inspectionId);
  //         // }
  //       }
  //     }
  //   });
  // }
}
