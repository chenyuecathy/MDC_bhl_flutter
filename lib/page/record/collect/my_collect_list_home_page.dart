import 'package:flutter/material.dart';
import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/common/event/index.dart';
import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/utils/date_picker_utils.dart';
import 'package:mdc_bhl/utils/eventbus_utils.dart';
import 'package:mdc_bhl/widget/gradient_appbar.dart';

import 'my_collect_list_seepage_page.dart';
import 'my_collect_list_stable_page.dart';
import 'my_collect_list_water_level_page.dart';

class MyCollectListModel {
  String recordType; // 0-渗漏水，1-稳定性，2-水位
  String recordId;
  bool isUpload;
  String uploadTime;

  @override
  String toString() {
    return 'MyCollectListModel{recordType: $recordType, recordId: $recordId, isUpload: $isUpload, uploadTime: $uploadTime}';
  }
}

/* 我的采集列表主页 */
class MyCollectListHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new MyCollectListHomePageState();
}

class MyCollectListHomePageState extends State<MyCollectListHomePage> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _initDate();
    _tabController = new TabController(vsync: this, length: 3);
    _tabController.addListener(() {
      // 刷新中间页（index == 1）
      setState(() {
        if (_tabController.index == 1) {
          // 发送订阅消息刷新中间页-稳定性
          eventBus.fire(EventUtil(Config.REFRESH_MY_COLLECT_STABLE_LIST, null));
        }
      });
    });
  }

  _initDate() async {
    await LocalStorage.save(Config.DATE_SELECT_LIST_ABOUT_SEEPAGE, "");
    await LocalStorage.save(Config.DATE_SELECT_LIST_ABOUT_STABLE, "");
    await LocalStorage.save(Config.DATE_SELECT_LIST_ABOUT_WATER_LEVEL, "");
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new GradientAppBar(
            gradientStart: Color(0xFF2171F5),
            gradientEnd: Color(0xFF49A2FC),
            title: Text("我的采集",
                style: TextStyle(fontSize: FontConfig.naviTextSize)),
            centerTitle: true,
            leading: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pop(context, "未保存");
                },
                child: Icon(Icons.chevron_left, size: 30)
            ),
            bottom: new TabBar(
              tabs: <Widget>[
                new Tab(child: Text('渗漏水')),
                new Tab(child: Text('稳定性')),
                new Tab(child: Text('水位')),
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
                      child: Text("筛选",style: TextStyle(fontSize: FontConfig.titleTextSize))
                  )
              )
            ]
        ),
        body: new TabBarView(controller: _tabController, children: <Widget>[
          MyCollectListSeepagePage(),
          MyCollectListStablePage(),
          MyCollectListWaterLevelPage()
        ]));
  }

  _dataPickerInit() async {
    await _getSP().then((_) async {
      await _showDataPicker();
    });
  }

  String dateSelectListAboutSeepage = "";
  String dateSelectListAboutStable = "";
  String dateSelectListAboutWaterLevel = "";

  _getSP() async {
    dateSelectListAboutSeepage = await LocalStorage.get(Config.DATE_SELECT_LIST_ABOUT_SEEPAGE);
    dateSelectListAboutStable = await LocalStorage.get(Config.DATE_SELECT_LIST_ABOUT_STABLE);
    dateSelectListAboutWaterLevel = await LocalStorage.get(Config.DATE_SELECT_LIST_ABOUT_WATER_LEVEL);
  }

  _showDataPicker() async {
    if (_tabController.index == 0) { // 渗漏水
      await DatePickerUtils.showDataPicker(context, dateSelectListAboutSeepage, Config.REFRESH_MY_COLLECT_SEEPAGE_LIST, Config.DATE_SELECT_LIST_ABOUT_SEEPAGE);
    } else if (_tabController.index == 1) { // 稳定性
      await DatePickerUtils.showDataPicker(context, dateSelectListAboutStable, Config.REFRESH_MY_COLLECT_STABLE_LIST, Config.DATE_SELECT_LIST_ABOUT_STABLE);
    } else if (_tabController.index == 2) { // 水位
      await DatePickerUtils.showDataPicker(context, dateSelectListAboutWaterLevel, Config.REFRESH_MY_COLLECT_WATER_LEVEL_LIST, Config.DATE_SELECT_LIST_ABOUT_WATER_LEVEL);
    }
  }
}