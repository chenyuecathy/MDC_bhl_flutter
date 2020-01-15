import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/common/event/index.dart';
import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/db/tab_inspection.dart';
import 'package:mdc_bhl/db/tab_report_record_manager.dart';
import 'package:mdc_bhl/page/record/item/record_item.dart';
import 'package:mdc_bhl/utils/date_picker_utils.dart';
import 'package:mdc_bhl/utils/eventbus_utils.dart';
import 'package:mdc_bhl/widget/blank_widget.dart';
import 'package:mdc_bhl/widget/gradient_appbar.dart';

/* 我的上报页面 */
class MyReportListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyReportListPageState();
}

class MyReportListPageState extends State<MyReportListPage> {
  StreamSubscription subscription;

  String _userId = "";

  List<TabReportRecordModel> _tabReportRecordModelList = List();

  String _reportDateSelectStr = ""; //日期选择串

  @override
  void initState() {
    super.initState();
    _initDate();
    _initParams().then((_) => _fetchRecord());

    //订阅eventbus
    subscription = eventBus.on<EventUtil>().listen((event) {
      if (event.message == Config.REFRESH_MY_REPORT_LIST) {
        setState(() {
          _refresh();
        });
      }
    });
  }

  _initDate() async {
    await LocalStorage.save(Config.DATE_SELECT_LIST_ABOUT_REPORT, "");
  }

  Future _initParams() async {
    var userInfo = await LocalStorage.get(Config.USER_INFO_KEY);
    setState(() {
      Map<String, dynamic> responseDictionary = json.decode(userInfo);
      _userId = responseDictionary["ID"];
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
    return Scaffold(
        appBar: GradientAppBar(
            gradientStart: Color(0xFF2171F5),
            gradientEnd: Color(0xFF49A2FC),
            centerTitle: true,
            leading: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pop(context, "未保存");
                },
                child: Icon(Icons.chevron_left, size: 30)),
            title: Text("我的异常记录"),
            actions: <Widget>[
              GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    await DatePickerUtils.showDataPicker(
                        context,
                        _reportDateSelectStr,
                        Config.REFRESH_MY_REPORT_LIST,
                        Config.DATE_SELECT_LIST_ABOUT_REPORT);
                  },
                  child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(right: 20),
                      child: Text("筛选",style: TextStyle(fontSize: FontConfig.titleTextSize))))
            ]),
        body: RefreshIndicator(
            onRefresh: _refresh,
            backgroundColor: Colors.white,
            child: _tabReportRecordModelList.length == 0
                ? BlankWidget(false)
                : ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      TabReportRecordModel tabReportRecordModel =
                          _tabReportRecordModelList[index];
                      return Column(children: <Widget>[
                        RecordItem(recordType: RecordType.report,
                            tabReportRecordModel: tabReportRecordModel),
                        (index == _tabReportRecordModelList.length - 1)
                            ? Divider()
                            : Container()
                      ]);
                    },
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: _tabReportRecordModelList.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                  )));
  }

  /// pull down refresh
  Future<Null> _refresh() async {
    _tabReportRecordModelList.clear(); // reset data
    await _fetchRecord();
    return;
  }

  /// 获取上报记录
  _fetchRecord([Map<String, dynamic> params]) async {
    // 获取筛选
    String dateSelectListAboutReport =
        await LocalStorage.get(Config.DATE_SELECT_LIST_ABOUT_REPORT);
    setState(() {
      _reportDateSelectStr = dateSelectListAboutReport;
    });
    // 1.先在巡查记录表里找到该用户的巡查记录
    TabInspectionManager _tabInspectionManager = TabInspectionManager();
    List<TabInspectionModel> tabInspectionModelList =
        await _tabInspectionManager.queryByUserId(_userId);
    TabReportRecordManager _tabReportRecordManager = TabReportRecordManager();
    List<TabReportRecordModel> tabReportRecordModelList = []; // 总的上报记录
    for (var item in tabInspectionModelList) {
      // 2.根据巡查记录id，查找上报记录
      List<TabReportRecordModel> recordAboutInspectionIdList =
          await _tabReportRecordManager.queryByInspectionId(item.id);
      for (var recordItem in recordAboutInspectionIdList) {
        // 3.将每组巡查记录的上报记录，放到总的上报记录中
        tabReportRecordModelList.add(recordItem);
      }
    }
    // 4.sort
    List<TabReportRecordModel> sortList = [];
    for (var i = tabReportRecordModelList.length - 1; i >= 0; i--) {
      sortList.add(tabReportRecordModelList[i]);
    }
    setState(() {
      for (var item in sortList) {
        bool _isSelectDate = DatePickerUtils.getIsSelectDate(
            _reportDateSelectStr, item.time); // 是否为筛选的日期
        if (_isSelectDate) {
          _tabReportRecordModelList.add(item);
        }
      }
    });
  }
}
