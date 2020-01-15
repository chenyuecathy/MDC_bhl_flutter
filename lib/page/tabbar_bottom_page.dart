import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/event/index.dart';
import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/page/mine/mine_page.dart';
import 'package:mdc_bhl/page/report/report_page.dart';
import 'package:mdc_bhl/page/task/task_device_home_page.dart';
import 'package:mdc_bhl/page/task/task_guard_page.dart';
import 'package:mdc_bhl/page/task/task_office_page.dart';
import 'package:mdc_bhl/utils/clean_over_time_date_utils.dart';
import 'package:mdc_bhl/utils/eventbus_utils.dart';

import 'collect/collect_home_page.dart';
import 'package:mdc_bhl/icon/custom_icons.dart';
import 'package:mdc_bhl/utils/common_utils.dart';
import 'package:mdc_bhl/utils/data_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class TabBarBottomPage extends StatefulWidget {
  final String departmentId;

  TabBarBottomPage(this.departmentId);

  @override
  _TabBarBottomPageState createState() => _TabBarBottomPageState();
}

class _TabBarBottomPageState extends State<TabBarBottomPage> {

  // static List tabData = [
  //   {
  //     'text': '任务',
  //     'icon': Icon(
  //       IconData(0xe629, fontFamily: 'test'),
  //       size: 24,
  //       color: Colors.grey,
  //     )
  //   },
  //   {'text': '采集', 'icon': Icon(Icons.extension)},
  //   {'text': '上报', 'icon': Icon(Icons.favorite)},
  //   {'text': '我的', 'icon': Icon(Icons.person)},
  // ];

  // List<BottomNavigationBarItem> _myTabs = [];

  int _currentIndex = 0;        // 默认选项卡
  List<Widget> _list = List();

  @override
  void initState() {
    super.initState();

    // for (int i = 0; i < tabData.length; i++) {
    //   _myTabs.add(BottomNavigationBarItem(
    //     icon: tabData[i]['icon'],
    //     title: Text(tabData[i]['text'],
    //     ),
    //   ));
    // }

    if (widget.departmentId == Config.DEPARTMENT_ID_OFFICE) {
      _list
        ..add(TaskOfficePage())
        ..add(CollectHomePage())
        ..add(ReportPage(false))
        ..add(MinePage());
    } else if (widget.departmentId == Config.DEPARTMENT_ID_DEVICE) {
      _list
        ..add(TaskDeviceHomePage())
        ..add(CollectHomePage())
        ..add(ReportPage(false))
        ..add(MinePage());
    } else if (widget.departmentId == Config.DEPARTMENT_ID_GUARD) {
      _list
        ..add(TaskGuardPage())
        ..add(CollectHomePage())
        ..add(ReportPage(false))
        ..add(MinePage());
    }

     // 2s后执行app更新操作
     Future.delayed(const Duration(milliseconds: 2000),_checkUpdate);
    // _checkUpdate();
  }

  _checkUpdate() {
    // 检查更新
    DataUtils.checkVersion({}).then((VersionResult result) {
      if (result.update) {
        // 有新版本
        CommonUtils.showMultiAlertDialog( context, '发现新版本${result.versionData.buildVersion}', '${result.versionData.buildUpdateDescription}', ['现在更新', '稍后更新']).then((index) async {
          if (index == 0) {
            String currUrl = result.versionData.buildShortcutUrl;
            if (await canLaunch(currUrl)) {
              await launch(currUrl);
            }
          }
        });
      } else {
      }
    }).catchError((onError) {
      print('获取失败:$onError');
    });
  }

  // _renderTab() {
  //   return [
  //     Tab(text: "任务", icon: Icon(Icons.assessment)),
  //     Tab(text: "采集", icon: Icon(Icons.collections_bookmark)),
  //     Tab(text: "上报", icon: Icon(Icons.report)),
  //     Tab(text: "我的", icon: Icon(Icons.person)),
  //   ];
  // }

  // _renderPage() {
  //   if (_departmentId == Config.DEPARTMENT_ID_OFFICE) {
  //     debugPrint('DEPARTMENT_OFFICE');
  //     return [
  //       TaskOfficePage(),
  //       CollectHomePage(),
  //       ReportPage(),
  //       MinePage(),
  //     ];
  //   } else {
  //     debugPrint('DEPARTMENT_DEVICE');
  //     return [
  //       TaskDevicePage(),
  //       CollectHomePage(),
  //       ReportPage(),
  //       MinePage(),
  //     ];
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // return TabBarWidget(
    //   type: TabBarWidget.BOTTOM_TAB,
    //   tabItems: _renderTab(),
    //   tabViews: _renderPage(),
    //   backgroundColor: Colors.blue,
    //   indicatorColor: Colors.white,
    //   title: Text('任务'),
    // );

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _list,
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: _myTabs,
      //   //高亮  被点击高亮
      //   currentIndex: _currentIndex,
      //   //修改 页面
      //   onTap: _itemTapped,
      //   //shifting :按钮点击移动效果
      //   //fixed：固定
      //   type: BottomNavigationBarType.fixed,

      //   fixedColor: Color(0xFFC91B3A),
      // ),
      bottomNavigationBar: FancyBottomNavigation(
        tabs: [
          TabData(iconData: CustomIcons.task, title: "任务"),
          TabData(iconData: CustomIcons.collect, title: "采集"),
          TabData(iconData: CustomIcons.report, title: "上报"),
          TabData(iconData: CustomIcons.mine, title: "我的")
        ],
        inactiveIconColor: Colors.grey,
        activeIconColor: Colors.white,
        onTabChangedListener: (position) async {
          if (_currentIndex == 1) {
            // 获取"采集"选项卡tab切换index
            String value = await LocalStorage.get(Config.COLLECT_TAB_INDEX);
            if (value == "1") {
              // 发送订阅消息保存渗漏水
              eventBus.fire( EventUtil(Config.SAVE_SEEPAGE_WITH_TABBAR_BOTTOM, null));
            } else if (value == "2") {
              // 发送订阅消息保存稳定性
              eventBus.fire(EventUtil(Config.SAVE_STABLE_WITH_TABBAR_BOTTOM, null));
            } else if (value == "3") {
              // 发送订阅消息保存水位
              eventBus.fire( EventUtil(Config.SAVE_WATER_LEVEL_WITH_TABBAR_BOTTOM, null));
            }
          }
          if (position == 3) {
            /// 清理超时数据
            CleanOverTimeDateUtils.cleanOverTimeDate();
            print("清理超时数据");
          }
          setState(() {
            _currentIndex = position;
          });
        },
      ),
    );
  }

// void _itemTapped(int index) {
//   setState(() {
//     _currentIndex = index;
//   });
// }
}
