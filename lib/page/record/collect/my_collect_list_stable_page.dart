import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/event/index.dart';
import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/db/tab_stable_collect_manager.dart';
import 'package:mdc_bhl/page/record/item/record_item.dart';
import 'package:mdc_bhl/utils/date_picker_utils.dart';
import 'package:mdc_bhl/utils/eventbus_utils.dart';
import 'package:mdc_bhl/widget/blank_widget.dart';

import 'my_collect_list_home_page.dart';

/* 我的采集列表稳定性页 */
class MyCollectListStablePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new MyCollectListStablePageState();
}

class MyCollectListStablePageState extends State<MyCollectListStablePage> with AutomaticKeepAliveClientMixin {
  StreamSubscription subscription;

  String _userId = "";

  List<MyCollectListModel> _myCollectListModels = new List();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    //订阅eventbus
    subscription = eventBus.on<EventUtil>().listen((event) {
      if (event.message == Config.REFRESH_MY_COLLECT_STABLE_LIST) {
        _myCollectListModels.clear();
        _initParams().then((_) => _fetchRecord());
        debugPrint("刷新中间页-稳定性");
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

  Future _initParams() async {
    var userInfo = await LocalStorage.get(Config.USER_INFO_KEY);
    setState(() {
      Map<String, dynamic> responseDictionary = json.decode(userInfo);
      _userId = responseDictionary["ID"];
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
        onRefresh: _refresh,
        backgroundColor: Colors.white,
        child: _myCollectListModels.length == 0
            ? BlankWidget(false)
            : ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            MyCollectListModel _myCollectListModel = _myCollectListModels[index];
            return RecordItem(recordType: RecordType.collect, myCollectListModel: _myCollectListModel);
          },
          itemCount: _myCollectListModels.length,
          physics: const AlwaysScrollableScrollPhysics(),
        ));
  }

  /// pull down refresh
  Future<Null> _refresh() async {
    _initParams();
    _myCollectListModels.clear(); // reset data
    await _fetchRecord();
    return;
  }

  /// 获取稳定性记录
  _fetchRecord([Map<String, dynamic> params]) async {
    List<TabStableCollectModel> _tabStableCollectModelList = await TabStableCollectManager().queryByUserId(_userId);
    // 获取筛选
    String dateSelectListAboutStable = await LocalStorage.get(Config.DATE_SELECT_LIST_ABOUT_STABLE);
    // 获取记录
    setState(() {
      for (var item in _tabStableCollectModelList) {
        bool _isSelectDate = DatePickerUtils.getIsSelectDate(dateSelectListAboutStable, item.uploadTime); // 是否为筛选的日期
        if (_isSelectDate) {
          MyCollectListModel _myCollectListModel = new MyCollectListModel();
          _myCollectListModel.recordType = "1";
          _myCollectListModel.recordId = item.id;
          _myCollectListModel.isUpload = (item.isUpload == 0 ? false : true);
          _myCollectListModel.uploadTime = item.uploadTime;
          _myCollectListModels.add(_myCollectListModel);
        }
      }
    });
  }
}