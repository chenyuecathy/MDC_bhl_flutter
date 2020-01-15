import 'package:flutter/material.dart';
import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/page/record/task/my_task_list_device_day_page.dart';
import 'package:mdc_bhl/page/record/task/my_task_list_device_night_page.dart';
import 'package:mdc_bhl/utils/date_picker_utils.dart';
import 'package:mdc_bhl/widget/gradient_appbar.dart';

/* 我的任务-设备科主页面 */
class MyTaskListDeviceHomePage extends StatefulWidget {
  final String userId;

  MyTaskListDeviceHomePage(this.userId);

  @override
  State<StatefulWidget> createState() => MyTaskListDeviceHomePageState();
}

class MyTaskListDeviceHomePageState extends State<MyTaskListDeviceHomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _initDate();
    _tabController =
        TabController(length: 2, vsync: this); //SingleTickerProviderStateMixin
  }

  _initDate() async {
    await LocalStorage.save(Config.DATE_SELECT_LIST_ABOUT_DEVICE_DAY, "");
    await LocalStorage.save(Config.DATE_SELECT_LIST_ABOUT_DEVICE_NIGHT, "");
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(
            gradientStart: Color(0xFF2171F5),
            gradientEnd: Color(0xFF49A2FC),
            title: Text("我的任务",
                style: TextStyle(fontSize: FontConfig.naviTextSize)),
            centerTitle: true,
            leading: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.chevron_left, size: 30)),
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                    child: Text('日间巡查',
                        style: TextStyle(
                            fontSize: FontConfig.middleTextWhiteSize))),
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
              GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    await _dataPickerInit();
                  },
                  child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(right: 20),
                      child: Text("筛选",style: TextStyle(fontSize: FontConfig.titleTextSize))))
            ]),
        body: TabBarView(controller: _tabController, children: <Widget>[
          MyTaskListDeviceDayPage(widget.userId),
          MyTaskListDeviceNightPage(widget.userId)
        ]));
  }

  _dataPickerInit() async {
    await _getSP().then((_) async {
      await _showDataPicker();
    });
  }

  String dateSelectListAboutDeviceDay = "";
  String dateSelectListAboutDeviceNight = "";

  _getSP() async {
    dateSelectListAboutDeviceDay =
        await LocalStorage.get(Config.DATE_SELECT_LIST_ABOUT_DEVICE_DAY);
    dateSelectListAboutDeviceNight =
        await LocalStorage.get(Config.DATE_SELECT_LIST_ABOUT_DEVICE_NIGHT);
  }

  _showDataPicker() async {
    if (_tabController.index == 0) {
      // 日间巡查
      await DatePickerUtils.showDataPicker(
          context,
          dateSelectListAboutDeviceDay,
          Config.REFRESH_DEVICE_DAY_LIST,
          Config.DATE_SELECT_LIST_ABOUT_DEVICE_DAY);
    } else if (_tabController.index == 1) {
      // 夜间巡查
      await DatePickerUtils.showDataPicker(
          context,
          dateSelectListAboutDeviceNight,
          Config.REFRESH_DEVICE_NIGHT_LIST,
          Config.DATE_SELECT_LIST_ABOUT_DEVICE_NIGHT);
    }
  }
}
