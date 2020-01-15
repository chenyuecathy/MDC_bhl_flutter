import 'package:flutter/material.dart';

import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/model/data_result.dart';
import 'package:mdc_bhl/widget/gradient_appbar.dart';
import 'package:mdc_bhl/icon/custom_icons.dart';

import 'task_device_day_page.dart';
import 'task_device_night_page.dart';
import 'task_calendar_page.dart';
// import 'package:mdc_bhl/Widget/tabbar_widget.dart';
import 'package:mdc_bhl/utils/task_net_utils.dart';

/* 设备科和保卫科巡查主页 */

class TaskDeviceHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new TaskDeviceHomePageState();
}

class TaskDeviceHomePageState extends State<TaskDeviceHomePage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  TabController _tabController;

  // _renderTab() {
  //   return [
  //     Text('日间巡查'),
  //     Text('夜间巡查'),
  //   ];
  // }

  // _renderPage() {
  //   return [
  //     TaskDeviceDayPage(),
  //     TaskDeviceNightPage(),
  //   ];
  // }
  List<Widget> pages = [
    TaskDeviceDayPage(),
    TaskDeviceNightPage(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController( length: pages.length, vsync: this); //SingleTickerProviderStateMixin

    Future.delayed( const Duration(milliseconds: 2000), _fetchTaskCalendarFromNet);
  }

  _fetchTaskCalendarFromNet() async {
    TaskNetUtils.getTaskCalendarFromNet(DepartmentTaskType.Device).then((DataResult result) {
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // return TabBarWidget(
    //   type: TabBarWidget.TOP_TAB,
    //   tabItems: <Widget>[
    //     Tab(text: "日间巡查"),
    //     Tab(text: "夜间巡查"),
    //   ],
    //   tabViews: <Widget>[
    //     TaskDeviceDayPage(),
    //     TaskDeviceNightPage(),
    //   ],
    //   backgroundColor: Colors.blue,
    //   indicatorColor: Colors.white,
    //   title: null// Center(child: Text('任务',style: TextStyle(fontSize: FontConfig.normalTextSize))),
    // );

    return Scaffold(
      appBar: GradientAppBar(
        gradientStart: Color(0xFF2171F5),
        gradientEnd: Color(0xFF49A2FC),
        title: TabBar(
          tabs: <Widget>[
            Tab(
                child: Text('日间巡查',
                    style:
                        TextStyle(fontSize: FontConfig.middleTextWhiteSize))),
            Tab(
                child: Text(
              '夜间巡查',
              style: TextStyle(fontSize: FontConfig.middleTextWhiteSize),
            )),
          ],
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: Colors.white,
          controller: _tabController,
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(CustomIcons.task, color: Colors.white),
              tooltip: '任务日历',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => TaskCalendarPage(DepartmentTaskType.Device)));
              }),
        ],
      ),
      body: TabBarView(controller: _tabController, children: pages),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
