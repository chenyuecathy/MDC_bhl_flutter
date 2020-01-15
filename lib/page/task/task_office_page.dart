import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/common/net/address.dart';

import 'package:mdc_bhl/model/data_result.dart';
import 'package:mdc_bhl/model/office.dart';


import 'package:mdc_bhl/utils/common_utils.dart';
import 'package:mdc_bhl/utils/date_utils.dart';
import 'package:mdc_bhl/utils/net_utils.dart';

import 'package:mdc_bhl/widget/blank_widget.dart';
import 'package:mdc_bhl/widget/gradient_appbar.dart';

import 'package:mdc_bhl/icon/custom_icons.dart';
import 'package:mdc_bhl/page/task/item/task_office_item.dart';

class TaskOfficePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new TaskOfficePageState();
}

class TaskOfficePageState extends State<TaskOfficePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<OfficeModel> officeModels = new List(); // 服务获取的巡查内容

  ScrollController _scrollController = new ScrollController();

  /// pull down refresh
  Future<Null> _refresh() async {
    // fetch task data from net
    await _fetchTasksFromNet();

    return;
  }

  // 判断今日是否获取过任务
  Future<bool> _todayGainTask() async {
    String officePreviousDownTimeString = await LocalStorage.get(Config.DOWNLOAD_OFFICE_INFO_TIME_KEY);
    print('office storage time:$officePreviousDownTimeString now time:${DateTime.now().toString()}');
    bool isSameDay = false; // 默认不是同一天
    if (officePreviousDownTimeString != null) {
      DateTime previousDownTime = DateTime.parse(officePreviousDownTimeString);
      isSameDay = DateUtils.isSameDay(previousDownTime, DateTime.now());
    }

    return isSameDay;
  }

  Future _initTasks() async {
    // reset data
    officeModels.clear();
    // 判断今日是否获取过任务
    bool todayGainTask = await _todayGainTask();
    if (todayGainTask == true) {
      await _fetchTasksFromCache();
    } else {
      await _fetchTasksFromNet();
    }
  }

  /// 网络获取任务
  Future _fetchTasksFromNet([Map<String, dynamic> params]) async {
    // show Loading Dialog
    CommonUtils.showLoadingDialog(
        context, '拼命加载中...', SpinKitType.SpinKit_Circle);

    var cjdURL = Address.getCJD();
    DataResult dataResult = await NetUtils.getFromNet(cjdURL);

    // hide Loading Dialog
    Navigator.pop(context);

    if (dataResult.result) {
      dynamic responseList = dataResult.data;
      if (responseList.length > 0) officeModels.clear();
      setState(() {
        for (int i = 0; i < responseList.length; i++) {
          OfficeModel officeModel = OfficeModel.fromJson(responseList[i]);
          officeModels.add(officeModel);
        }
      });
      String jsonString = json.encode({'XCNR': responseList});
      LocalStorage.save(Config.DEPARTMENT_ID_OFFICE + '4', jsonString);

      // 获取成功的情况下，记住获取时间
      LocalStorage.save(
          Config.DOWNLOAD_OFFICE_INFO_TIME_KEY, DateTime.now().toString());
    } else {
      CommonUtils.showTextToast(dataResult.description);
    }
  }

  Future _fetchTasksFromCache() async {
    String tasksString =
        await LocalStorage.get(Config.DEPARTMENT_ID_OFFICE + '4');
    if (tasksString != null) {
      Map<String, dynamic> tasks = json.decode(tasksString);
      // 服务获取的巡查内容
      dynamic responseList = tasks['XCNR'];
      if (responseList.length > 0) officeModels.clear();
      setState(() {
        for (int i = 0; i < responseList.length; i++) {
          OfficeModel officeModel =
              OfficeModel.fromJson(responseList[i]); // 解析json
          officeModels.add(officeModel);
        }
      });
    }
  }

  @override
  void initState() {
    _initTasks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: GradientAppBar(
        gradientStart: Color(0xFF2171F5),
        gradientEnd: Color(0xFF49A2FC),
        centerTitle: true,
        title: Text('旅游与游客管理', style: TextStyle(fontSize: FontConfig.naviTextSize)),
      ),
      body: Container(
        padding: EdgeInsets.all(2.0),
        child: officeModels.length > 0
            ? RefreshIndicator(
                onRefresh: _refresh,
                backgroundColor: Colors.white,
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    OfficeModel officeModel = officeModels[index]; // 数据
                    return TaskOfficeItem(officeModel);
                  },
                  itemCount: officeModels.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                ),
              )
            : BlankWidget(true, onClickButton: (value) async {
                print('click me ' + value);
                await _refresh();
              }),
      ),
    );
  }
}
