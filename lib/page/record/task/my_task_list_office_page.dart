import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/common/event/index.dart';
import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/db/tab_office_record_manager.dart';
import 'package:mdc_bhl/page/record/item/record_item.dart';
import 'package:mdc_bhl/utils/date_picker_utils.dart';
import 'package:mdc_bhl/utils/eventbus_utils.dart';
import 'package:mdc_bhl/widget/blank_widget.dart';
import 'package:mdc_bhl/widget/gradient_appbar.dart';

/* 我的任务-办公室页面 */
class MyTaskListOfficePage extends StatefulWidget {
  final String userId;

  MyTaskListOfficePage(this.userId);

  @override
  State<StatefulWidget> createState() => MyTaskListOfficePageState();
}

class MyTaskListOfficePageState extends State<MyTaskListOfficePage> {
  StreamSubscription subscription;

  List<TabOfficeRecordModel> _tabOfficeRecordModelList = new List();

  String _officeDateSelectStr = ""; //日期选择串

  @override
  void initState() {
    super.initState();
    _initDate();
    _fetchRecord();

    //订阅eventbus
    subscription = eventBus.on<EventUtil>().listen((event) {
      if (event.message == Config.REFRESH_MY_OFFICE_LIST) {
        setState(() {
          _refresh();
        });
      }
    });
  }

  _initDate() async {
    await LocalStorage.save(Config.DATE_SELECT_LIST_ABOUT_OFFICE, "");
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
                    await DatePickerUtils.showDataPicker(context, _officeDateSelectStr, Config.REFRESH_MY_OFFICE_LIST, Config.DATE_SELECT_LIST_ABOUT_OFFICE);
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
            child: _tabOfficeRecordModelList.length == 0
                ? BlankWidget(false)
                : ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                TabOfficeRecordModel tabOfficeRecordModel = _tabOfficeRecordModelList[index];
                return RecordItem(recordType: RecordType.office, tabOfficeRecordModel: tabOfficeRecordModel);
              },
              itemCount: _tabOfficeRecordModelList.length,
              physics: const AlwaysScrollableScrollPhysics(),
            )
        )
    );
  }

  /// pull down refresh
  Future<Null> _refresh() async {
    _tabOfficeRecordModelList.clear(); // reset data
    await _fetchRecord();
    return;
  }

  /// 获取办公室记录
  _fetchRecord([Map<String, dynamic> params]) async {
    List<TabOfficeRecordModel> tabOfficeRecordModelList = await TabOfficeRecordManager().queryByUserId(widget.userId);
    // 获取筛选
    String dateSelectListAboutOffice = await LocalStorage.get(Config.DATE_SELECT_LIST_ABOUT_OFFICE);
    setState(() {
      _officeDateSelectStr = dateSelectListAboutOffice;
    });
    // 获取记录
    setState(() {
      for (var item in tabOfficeRecordModelList) {
        bool _isSelectDate = DatePickerUtils.getIsSelectDate(_officeDateSelectStr, item.time); // 是否为筛选的日期
        if (_isSelectDate) {
          _tabOfficeRecordModelList.add(item);
        }
      }
    });
  }
}