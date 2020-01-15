import 'package:flutter/material.dart';
import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/common/event/index.dart';
import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/utils/eventbus_utils.dart';
import 'package:mdc_bhl/widget/gradient_appbar.dart';

import 'collect_circular_water.dart';
import 'collect_seepage_page.dart';
import 'collect_stable_page.dart';
import 'collect_water_level_page.dart';

/* 采集记录主页 */
class CollectHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CollectHomePageState();
}

class CollectHomePageState extends State<CollectHomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
    _saveCollectTabIndex("0");
    _tabController.addListener(() async {
      if (_tabController.previousIndex == 1) {
        // 发送订阅消息保存渗漏水
        eventBus.fire(EventUtil(Config.SAVE_SEEPAGE_WITH_TABBAR_BOTTOM, null));
      } else if (_tabController.previousIndex == 2) {
        // 发送订阅消息保存稳定性
        eventBus.fire(EventUtil(Config.SAVE_STABLE_WITH_TABBAR_BOTTOM, null));
      } else if (_tabController.previousIndex == 3) {
        // 发送订阅消息保存水位
        eventBus
            .fire(EventUtil(Config.SAVE_WATER_LEVEL_WITH_TABBAR_BOTTOM, null));
      }
      _saveCollectTabIndex(_tabController.index.toString());
    });
  }

  // 保存"采集"选项卡tab切换index
  _saveCollectTabIndex(String index) async {
    await LocalStorage.save(Config.COLLECT_TAB_INDEX, index);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print('${MediaQuery.of(context).padding.top}===${MediaQuery.of(context).padding.bottom}');
    return Scaffold(
        appBar: GradientAppBar(
          gradientStart: Color(0xFF2171F5),
          gradientEnd: Color(0xFF49A2FC),
          title: TabBar(
            tabs: <Widget>[
              Tab(
                  child: Text('循环水',
                      style:TextStyle(fontSize: FontConfig.middleTextWhiteSize))),
              Tab(
                  child: Text('渗漏水',
                      style:TextStyle(fontSize: FontConfig.middleTextWhiteSize))),
              Tab(
                  child: Text('稳定性',
                      style:TextStyle(fontSize: FontConfig.middleTextWhiteSize))),
              Tab(
                  child: Text('水位',
                      style:TextStyle(fontSize: FontConfig.middleTextWhiteSize))),
            ],
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: Colors.white,
            controller: _tabController,
          ),
        ),
        body: TabBarView(controller: _tabController, children: <Widget>[
          CollectCircularWaterPage(),
          CollectSeepagePage(),
          CollectStablePage(),
          CollectWaterLevelPage(MediaQuery.of(context).size.height-MediaQuery.of(context).padding.top - 160)
        ]));
  }
}
