import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/common/event/index.dart';
import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/db/tab_device_record_manager.dart';
import 'package:mdc_bhl/utils/date_picker_utils.dart';
import 'package:mdc_bhl/utils/eventbus_utils.dart';
import 'package:mdc_bhl/widget/blank_widget.dart';
import 'package:mdc_bhl/widget/gradient_appbar.dart';
import 'package:mdc_bhl/page/record/item/task_device_record_item.dart';

/* 我的任务-保卫科页面 */
class MyTaskListGuardPage extends StatefulWidget {
  final String userId;

  MyTaskListGuardPage(this.userId);

  @override
  State<StatefulWidget> createState() => MyTaskListGuardPageState();
}

class MyTaskListGuardPageState extends State<MyTaskListGuardPage> {
   StreamSubscription subscription;

  List<String> _dateKeys = []; // inspectionId去重集合
   Map<String, List<TabDeviceRecordModel>> _tasksMap = Map();

  String _guardDateSelectStr = ""; //日期选择串

  @override
  void initState() {
    super.initState();
    _initDate();
    _fetchTasksMapSortByDate();

     //订阅eventbus
     subscription = eventBus.on<EventUtil>().listen((event) {
       if (event.message == Config.REFRESH_MY_GUARD_LIST) {
         setState(() {
           _refresh();
         });
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

  _initDate() async {
    await LocalStorage.save(Config.DATE_SELECT_LIST_ABOUT_GUARD, "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(
            gradientStart: Color(0xFF2171F5),
            gradientEnd: Color(0xFF49A2FC),
            title: Text("我的任务",
                style: TextStyle(fontSize: FontConfig.naviTextSize)),
            leading: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pop(context, "未保存");
                },
                child: Icon(Icons.chevron_left, size: 30)
            ),
            centerTitle: true,
            actions: <Widget>[
              GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    await DatePickerUtils.showDataPicker(context, _guardDateSelectStr, Config.REFRESH_MY_GUARD_LIST, Config.DATE_SELECT_LIST_ABOUT_GUARD);
                  },
                  child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(right: 20),
                      child: Text("筛选",style: TextStyle(fontSize: FontConfig.titleTextSize))
                  )
              )
            ]
        ),
        body: RefreshIndicator(
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
              )));
  }

  /// pull down refresh
  Future<Null> _refresh() async {
    // _dateKeys.clear(); // reset data
    await _fetchTasksMapSortByDate();
    return;
  }

    _fetchTasksMapSortByDate() async {
    List<TabDeviceRecordModel> taskList = await TabDeviceRecordManager()
        .queryUploadRecordsByUserid(widget.userId, 2);

    print('device day record list:${taskList.length}');
    // 获取筛选
    String dateSelectListAboutDeviceDay =
        await LocalStorage.get(Config.DATE_SELECT_LIST_ABOUT_GUARD);
    setState(() {
      _guardDateSelectStr = dateSelectListAboutDeviceDay;
    });

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

        if (DatePickerUtils.getIsSelectDate(
            dateSelectListAboutDeviceDay, day)) {
          // print(item);
          oneDayTasks.add(item);
          _tasksMap[day] = oneDayTasks;
        }
      }
    });
  }

  // /// 获取保卫科记录
  // _fetchRecord([Map<String, dynamic> params]) async {
  //   List<TabDeviceRecordModel> tabDeviceRecordModelList = await TabDeviceRecordManager().queryUnoperatedOrderTime();
  //   // 获取筛选
  //   String dateSelectListAboutGuard = await LocalStorage.get(Config.DATE_SELECT_LIST_ABOUT_GUARD);
  //   setState(() {
  //     _guardDateSelectStr = dateSelectListAboutGuard;
  //   });
  //   // 获取记录
  //   setState(() {
  //     for (int i = 0; i < tabDeviceRecordModelList.length; i++) {
  //       bool _isThisUser = (tabDeviceRecordModelList[i].inspectorId == widget.userId); // 该用户
  //       bool _isSelectDate = DatePickerUtils.getIsSelectDate(_guardDateSelectStr, tabDeviceRecordModelList[i].time); // 是否为筛选的日期
  //       if (_isThisUser && _isSelectDate) {
  //         if (!_dateKeys.contains(tabDeviceRecordModelList[i].inspectionId)) {
  //           // inspectionIdList不存在该inspectionId则添加
  //           _dateKeys.add(tabDeviceRecordModelList[i].inspectionId);
  //         }
  //       }
  //     }
  //   });
  // }
}