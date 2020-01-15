import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/common/event/index.dart';
import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/common/net/address.dart';
import 'package:mdc_bhl/db/tab_stable_collect_manager.dart';
import 'package:mdc_bhl/utils/common_utils.dart';
import 'package:mdc_bhl/utils/date_utils.dart';
import 'package:mdc_bhl/utils/eventbus_utils.dart';
import 'package:mdc_bhl/utils/net_utils.dart';
import 'package:uuid/uuid.dart';

/* 稳定性采集页面 */
class CollectStablePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new CollectStablePageState();
}

class CollectStablePageState extends State<CollectStablePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  StreamSubscription subscription;

  String _userId;
  String _userName;
  String _stableId;

  TabStableCollectManager _tabStableCollectManager = new TabStableCollectManager();

  TextEditingController _r32dMsController = new TextEditingController();
  FocusNode _r32dMsFocusNode = new FocusNode();
  TextEditingController _r32dWdController = new TextEditingController();
  FocusNode _r32dWdFocusNode = new FocusNode();
  TextEditingController _r33dMsController = new TextEditingController();
  FocusNode _r33dMsFocusNode = new FocusNode();
  TextEditingController _r33dWdController = new TextEditingController();
  FocusNode _r33dWdFocusNode = new FocusNode();
  TextEditingController _r34dMsController = new TextEditingController();
  FocusNode _r34dMsFocusNode = new FocusNode();
  TextEditingController _r34dWdController = new TextEditingController();
  FocusNode _r34dWdFocusNode = new FocusNode();
  TextEditingController _r35dMsController = new TextEditingController();
  FocusNode _r35dMsFocusNode = new FocusNode();
  TextEditingController _r35dWdController = new TextEditingController();
  FocusNode _r35dWdFocusNode = new FocusNode();
  TextEditingController _r36dMsController = new TextEditingController();
  FocusNode _r36dMsFocusNode = new FocusNode();
  TextEditingController _r36dWdController = new TextEditingController();
  FocusNode _r36dWdFocusNode = new FocusNode();
  TextEditingController _r37dMsController = new TextEditingController();
  FocusNode _r37dMsFocusNode = new FocusNode();
  TextEditingController _r37dWdController = new TextEditingController();
  FocusNode _r37dWdFocusNode = new FocusNode();
  TextEditingController _r38dMsController = new TextEditingController();
  FocusNode _r38dMsFocusNode = new FocusNode();
  TextEditingController _r38dWdController = new TextEditingController();
  FocusNode _r38dWdFocusNode = new FocusNode();
  TextEditingController _r39dMsController = new TextEditingController();
  FocusNode _r39dMsFocusNode = new FocusNode();
  TextEditingController _r39dWdController = new TextEditingController();
  FocusNode _r39dWdFocusNode = new FocusNode();
  TextEditingController _r40dMsController = new TextEditingController();
  FocusNode _r40dMsFocusNode = new FocusNode();
  TextEditingController _r40dWdController = new TextEditingController();
  FocusNode _r40dWdFocusNode = new FocusNode();
  TextEditingController _j02dMsController = new TextEditingController();
  FocusNode _j02dMsFocusNode = new FocusNode();
  TextEditingController _j02dWdController = new TextEditingController();
  FocusNode _j02dWdFocusNode = new FocusNode();

  @override
  void initState() {
    //文本框改变监听
    _initTextFileListener(_r32dMsFocusNode, _r32dMsController);
    _initTextFileListener(_r32dWdFocusNode, _r32dWdController);
    _initTextFileListener(_r33dMsFocusNode, _r33dMsController);
    _initTextFileListener(_r33dWdFocusNode, _r33dWdController);
    _initTextFileListener(_r34dMsFocusNode, _r34dMsController);
    _initTextFileListener(_r34dWdFocusNode, _r34dWdController);
    _initTextFileListener(_r35dMsFocusNode, _r35dMsController);
    _initTextFileListener(_r35dWdFocusNode, _r35dWdController);
    _initTextFileListener(_r36dMsFocusNode, _r36dMsController);
    _initTextFileListener(_r36dWdFocusNode, _r36dWdController);
    _initTextFileListener(_r37dMsFocusNode, _r37dMsController);
    _initTextFileListener(_r37dWdFocusNode, _r37dWdController);
    _initTextFileListener(_r38dMsFocusNode, _r38dMsController);
    _initTextFileListener(_r38dWdFocusNode, _r38dWdController);
    _initTextFileListener(_r39dMsFocusNode, _r39dMsController);
    _initTextFileListener(_r39dWdFocusNode, _r39dWdController);
    _initTextFileListener(_r40dMsFocusNode, _r40dMsController);
    _initTextFileListener(_r40dWdFocusNode, _r40dWdController);
    _initTextFileListener(_j02dMsFocusNode, _j02dMsController);
    _initTextFileListener(_j02dWdFocusNode, _j02dWdController);

    _initParams().then((_) => _getUnupload());
    super.initState();
  }

  //初始化文本框改变监听
  _initTextFileListener(FocusNode focusNode, TextEditingController controller) {
    focusNode.addListener(() {
      if (focusNode.hasFocus && controller.text == "0") {
        controller.text = "";
      }
    });
  }

  _initParams() async {
    // 初始化用户id
    var userInfo = await LocalStorage.get(Config.USER_INFO_KEY);
    Map<String, dynamic> responseDictionary = json.decode(userInfo);
    _userId = responseDictionary["ID"];
    _userName = responseDictionary["REALNAME"];
    // 初始化稳定性id
    String stableId = await LocalStorage.get(Config.STABLE_ID_WITH_TABBAR_BOTTOM);
    if (stableId != null) {
      _stableId = stableId;
    } else {
      _stableId = new Uuid().v1();
      await LocalStorage.save(Config.STABLE_ID_WITH_TABBAR_BOTTOM, _stableId);
    }

    //订阅eventbus
    subscription = eventBus.on<EventUtil>().listen((event) {
      if (event.message == Config.SAVE_STABLE_WITH_TABBAR_BOTTOM) {
        if (_stableId != null) {
          debugPrint("保存稳定性" + _stableId);
          _saveRecord();
        }
      } else if (event.message == Config.REFRESH_COLLECT_TAB_STABLE) {
        _initParams().then((_) => _getUnupload());
      }
    });
  }

  // 获取未提交
  _getUnupload() async {
    List<TabStableCollectModel> tabStableCollectModelList = await _tabStableCollectManager.queryByUserIdWithUnupload(_userId);
    if (tabStableCollectModelList.length == 0) {
      _stableId = new Uuid().v1();
      await LocalStorage.save(Config.STABLE_ID_WITH_TABBAR_BOTTOM, _stableId);
      _allTextFileReset();
      return;
    }

    TabStableCollectModel tabStableCollectModel = tabStableCollectModelList[0];
    _stableId = tabStableCollectModel.id;
    _setTextFileValue(tabStableCollectModel);
    LocalStorage.save(Config.STABLE_ID_WITH_TABBAR_BOTTOM, _stableId);
  }

  _setTextFileValue(TabStableCollectModel tabStableCollectModel) {
    _r32dMsController.text = tabStableCollectModel.r32dMsValue.toString();
    _r32dWdController.text = tabStableCollectModel.r32dWdValue.toString();
    _r33dMsController.text = tabStableCollectModel.r33dMsValue.toString();
    _r33dWdController.text = tabStableCollectModel.r33dWdValue.toString();
    _r34dMsController.text = tabStableCollectModel.r34dMsValue.toString();
    _r34dWdController.text = tabStableCollectModel.r34dWdValue.toString();
    _r35dMsController.text = tabStableCollectModel.r35dMsValue.toString();
    _r35dWdController.text = tabStableCollectModel.r35dWdValue.toString();
    _r36dMsController.text = tabStableCollectModel.r36dMsValue.toString();
    _r36dWdController.text = tabStableCollectModel.r36dWdValue.toString();
    _r37dMsController.text = tabStableCollectModel.r37dMsValue.toString();
    _r37dWdController.text = tabStableCollectModel.r37dWdValue.toString();
    _r38dMsController.text = tabStableCollectModel.r38dMsValue.toString();
    _r38dWdController.text = tabStableCollectModel.r38dWdValue.toString();
    _r39dMsController.text = tabStableCollectModel.r39dMsValue.toString();
    _r39dWdController.text = tabStableCollectModel.r39dWdValue.toString();
    _r40dMsController.text = tabStableCollectModel.r40dMsValue.toString();
    _r40dWdController.text = tabStableCollectModel.r40dWdValue.toString();
    _j02dMsController.text = tabStableCollectModel.j02dMsValue.toString();
    _j02dWdController.text = tabStableCollectModel.j02dWdValue.toString();
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
    super.build(context);
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          /// 通过GestureDetector捕获点击事件，再通过FocusScope将焦点转移至空焦点——new FocusNode()
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
            body: new SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                    color: Color(0xffebeef5),
                    child: Column(children: <Widget>[
                      SizedBox(height: 10),
                      _item("钢筋计R32D", _r32dMsController, _r32dMsFocusNode, _r32dWdController, _r32dWdFocusNode),
                      _item("钢筋计R33D", _r33dMsController, _r33dMsFocusNode, _r33dWdController, _r33dWdFocusNode),
                      _item("钢筋计R34D", _r34dMsController, _r34dMsFocusNode, _r34dWdController, _r34dWdFocusNode),
                      _item("钢筋计R35D", _r35dMsController, _r35dMsFocusNode, _r35dWdController, _r35dWdFocusNode),
                      _item("钢筋计R36D", _r36dMsController, _r36dMsFocusNode, _r36dWdController, _r36dWdFocusNode),
                      _item("钢筋计R37D", _r37dMsController, _r37dMsFocusNode, _r37dWdController, _r37dWdFocusNode),
                      _item("钢筋计R38D", _r38dMsController, _r38dMsFocusNode, _r38dWdController, _r38dWdFocusNode),
                      _item("钢筋计R39D", _r39dMsController, _r39dMsFocusNode, _r39dWdController, _r39dWdFocusNode),
                      _item("钢筋计R40D", _r40dMsController, _r40dMsFocusNode, _r40dWdController, _r40dWdFocusNode),
                      _item("测缝计J02D", _j02dMsController, _j02dMsFocusNode, _j02dWdController, _j02dWdFocusNode),
                      SizedBox(height: 80)
                    ]))),
            floatingActionButton: FloatingActionButton(
                heroTag: 'collect_stable_btn',
                onPressed: () {
                  _uploadRecord().then((_) async {
//                    // 必填验证
//                    if (_isAllTextFileHasContent() == false) {
//                      return;
//                    }
                    _allTextFileReset();
                    _stableId = new Uuid().v1();
                    await LocalStorage.save(Config.STABLE_ID_WITH_TABBAR_BOTTOM, _stableId);
                  });
                },
                tooltip: '提交',
                child: new Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Icon(Icons.file_upload), Text("提交", style: new TextStyle(fontSize: 10))]))));
  }

  _item(String title, TextEditingController msController, FocusNode msFocusNode, TextEditingController wdController, FocusNode wdFocusNode) {
    return Card(
        color: Colors.white,
        // 卡片背景颜色
        elevation: 0.0,
        // 卡片的z坐标,控制卡片下面的阴影大小
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0)), // 圆角
        ),
        child: Column(children: <Widget>[
          Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(10),
              child: Row(children: <Widget>[
                Image.asset('images/ic_stable.png', width: 18, height: 18),
                SizedBox(width: 5),
                Text(title, style: new TextStyle(color: const Color(ColorConfig.darkTextColor), fontSize: FontConfig.titleTextSize))
              ])),
          Divider(height: 1),
          Container(
              padding: EdgeInsets.fromLTRB(35, 15, 10, 15),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                Text("模数值", style: new TextStyle(color: const Color(ColorConfig.darkTextColor), fontSize: FontConfig.contentTextSize)),
                Expanded(
                    child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          FocusScope.of(context).requestFocus(msFocusNode); // 获取焦点
                        },
                        child: new Container(
                            margin: EdgeInsets.only(right: 5, left: 5),
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            decoration: new BoxDecoration(
                                color: Color(0xaaebeef5),
//                            border: new Border.all(color: const Color(ColorConfig.borderColor), width: 0.5),
                                borderRadius: new BorderRadius.circular(3)),
                            child: Row(children: <Widget>[
                              Expanded(
                                  child: TextField(
                                      controller: msController,
                                      focusNode: msFocusNode,
                                      style: TextStyle(color: const Color(ColorConfig.darkTextColor), fontSize: FontConfig.contentTextSize),
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: <TextInputFormatter>[
                                        WhitelistingTextInputFormatter(RegExp("[0-9.]")), // 只输入数字（有小数）
//                                    WhitelistingTextInputFormatter.digitsOnly, // 只输入数字（无小数）
//                                    LengthLimitingTextInputFormatter(6) // 最大长度
                                      ],
                                      decoration: const InputDecoration(
                                          // hintText: '请输入信息',
                                          contentPadding: const EdgeInsets.all(0),
                                          border: InputBorder.none),
                                      // 当value改变的时候，触发
                                      onChanged: (val) {
                                        // print(val);
                                      }
                                      ),
                                  flex: 1),
                              new Text(title != "测缝计J02D" ? "MPa" : "mm",
                                  style: new TextStyle(color: const Color(0xff919191), fontSize: title != "测缝计J02D" ? FontConfig.minTextSize : FontConfig.contentTextSize)),
                            ]))),
                    flex: 1),
                SizedBox(width: 10),
                Text("温度值", style: new TextStyle(color: const Color(ColorConfig.darkTextColor), fontSize: FontConfig.contentTextSize)),
                Expanded(
                    child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          FocusScope.of(context).requestFocus(wdFocusNode); // 获取焦点
                        },
                        child: Container(
                            margin: EdgeInsets.only(right: 5, left: 5),
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            decoration: new BoxDecoration(
                                color: Color(0xaaebeef5),
//                            border: new Border.all(color: const Color(ColorConfig.borderColor), width: 0.5),
                                borderRadius: new BorderRadius.circular(3)),
                            child: Row(children: <Widget>[
                              Expanded(
                                  child:
                                  new TextField(
                                      controller: wdController,
                                      focusNode: wdFocusNode,
                                      style: TextStyle(color: const Color(ColorConfig.darkTextColor), fontSize: FontConfig.contentTextSize),
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: <TextInputFormatter>[
                                        WhitelistingTextInputFormatter(RegExp("[0-9.]")), // 只输入数字（有小数）
//                            WhitelistingTextInputFormatter.digitsOnly, // 只输入数字（无小数）
//                            LengthLimitingTextInputFormatter(6) // 最大长度
                                      ],
                                      decoration: const InputDecoration(
                                          // hintText: '请输入信息',
//                                          contentPadding: const EdgeInsets.all(0),
                                          border: InputBorder.none),
                                      // 当value改变的时候，触发
                                      onChanged: (val) {
                                        // print(val);
                                      }),
                                  flex: 1),
                              new Text("°C", style: new TextStyle(color: const Color(0xff919191), fontSize: FontConfig.contentTextSize))
                            ]))),
                    flex: 1)
              ]))
        ]));
  }

  // 保存稳定性采集数据
  _saveRecord() async {
    if (_isAllTextFileNoContent()) {
      return;
    }
    // 插入数据
    TabStableCollectModel _tabStableCollectModel = new TabStableCollectModel();
    _tabStableCollectModel.id = _stableId;
    _tabStableCollectModel.collectorId = _userId;
    _setValue(_tabStableCollectModel);
    _tabStableCollectModel.isUpload = 0;
    _tabStableCollectModel.uploadTime = DateUtils.getCurrentTime();
    await _tabStableCollectManager.insert(_tabStableCollectModel);
  }

  // 上传稳定性采集数据
  _uploadRecord() async {
//    // 必填验证
//    if (_isAllTextFileHasContent() == false) {
//      CommonUtils.showTextToast("请输入后提交");
//      return;
//    }
    // 插入数据
    TabStableCollectModel _tabStableCollectModel = new TabStableCollectModel();
    _tabStableCollectModel.id = _stableId;
    _tabStableCollectModel.collectorId = _userId;
    _setValue(_tabStableCollectModel);
    _tabStableCollectModel.isUpload = 1;
    _tabStableCollectModel.uploadTime = DateUtils.getCurrentTime();
    await _tabStableCollectManager.insert(_tabStableCollectModel);
    // 上传数据
    String _wdx = json.encode(_tabStableCollectModel.toJson(_userId, _userName));
    print("saveWdxSglr参数:" + _wdx);
    var saveWdxSglr = Address.saveWdxSglr();
    var response = await NetUtils.post(saveWdxSglr, {'wdx': _wdx});
    print("saveWdxSglr返回值:" + response);
    if (json.decode(response)['IsSuccess'] == false) {
      CommonUtils.showTextToast("数据上传失败，请稍后重试");
      return;
    } else {
      CommonUtils.showAlertDialog(context, '温馨提示', "数据上传成功", () {});
    }
    
  }

  // 设置各种value的值
  _setValue(TabStableCollectModel tabStableCollectModel) {
    tabStableCollectModel.r32dMsValue = double.parse(_r32dMsController.text == "" ? "0" : _r32dMsController.text);
    tabStableCollectModel.r32dWdValue = double.parse(_r32dWdController.text == "" ? "0" : _r32dWdController.text);
    tabStableCollectModel.r33dMsValue = double.parse(_r33dMsController.text == "" ? "0" : _r33dMsController.text);
    tabStableCollectModel.r33dWdValue = double.parse(_r33dWdController.text == "" ? "0" : _r33dWdController.text);
    tabStableCollectModel.r34dMsValue = double.parse(_r34dMsController.text == "" ? "0" : _r34dMsController.text);
    tabStableCollectModel.r34dWdValue = double.parse(_r34dWdController.text == "" ? "0" : _r34dWdController.text);
    tabStableCollectModel.r35dMsValue = double.parse(_r35dMsController.text == "" ? "0" : _r35dMsController.text);
    tabStableCollectModel.r35dWdValue = double.parse(_r35dWdController.text == "" ? "0" : _r35dWdController.text);
    tabStableCollectModel.r36dMsValue = double.parse(_r36dMsController.text == "" ? "0" : _r36dMsController.text);
    tabStableCollectModel.r36dWdValue = double.parse(_r36dWdController.text == "" ? "0" : _r36dWdController.text);
    tabStableCollectModel.r37dMsValue = double.parse(_r37dMsController.text == "" ? "0" : _r37dMsController.text);
    tabStableCollectModel.r37dWdValue = double.parse(_r37dWdController.text == "" ? "0" : _r37dWdController.text);
    tabStableCollectModel.r38dMsValue = double.parse(_r38dMsController.text == "" ? "0" : _r38dMsController.text);
    tabStableCollectModel.r38dWdValue = double.parse(_r38dWdController.text == "" ? "0" : _r38dWdController.text);
    tabStableCollectModel.r39dMsValue = double.parse(_r39dMsController.text == "" ? "0" : _r39dMsController.text);
    tabStableCollectModel.r39dWdValue = double.parse(_r39dWdController.text == "" ? "0" : _r39dWdController.text);
    tabStableCollectModel.r40dMsValue = double.parse(_r40dMsController.text == "" ? "0" : _r40dMsController.text);
    tabStableCollectModel.r40dWdValue = double.parse(_r40dWdController.text == "" ? "0" : _r40dWdController.text);
    tabStableCollectModel.j02dMsValue = double.parse(_j02dMsController.text == "" ? "0" : _j02dMsController.text);
    tabStableCollectModel.j02dWdValue = double.parse(_j02dWdController.text == "" ? "0" : _j02dWdController.text);
  }

  // 是否所有文本框都没有内容
  _isAllTextFileNoContent() {
    if (_r32dMsController.text != "") {
      return false;
    }
    if (_r32dWdController.text != "") {
      return false;
    }
    if (_r33dMsController.text != "") {
      return false;
    }
    if (_r33dWdController.text != "") {
      return false;
    }
    if (_r34dMsController.text != "") {
      return false;
    }
    if (_r34dWdController.text != "") {
      return false;
    }
    if (_r35dMsController.text != "") {
      return false;
    }
    if (_r35dWdController.text != "") {
      return false;
    }
    if (_r36dMsController.text != "") {
      return false;
    }
    if (_r36dWdController.text != "") {
      return false;
    }
    if (_r37dMsController.text != "") {
      return false;
    }
    if (_r37dWdController.text != "") {
      return false;
    }
    if (_r38dMsController.text != "") {
      return false;
    }
    if (_r38dWdController.text != "") {
      return false;
    }
    if (_r39dMsController.text != "") {
      return false;
    }
    if (_r39dWdController.text != "") {
      return false;
    }
    if (_r40dMsController.text != "") {
      return false;
    }
    if (_r40dWdController.text != "") {
      return false;
    }
    if (_j02dMsController.text != "") {
      return false;
    }
    if (_j02dWdController.text != "") {
      return false;
    }
    return true;
  }

  // 是否所有文本框都有内容
  _isAllTextFileHasContent() {
    if ((_r32dMsController.text == "" ||
            _r32dWdController.text == "" ||
            _r33dMsController.text == "" ||
            _r33dWdController.text == "" ||
            _r34dMsController.text == "" ||
            _r34dWdController.text == "" ||
            _r35dMsController.text == "" ||
            _r35dWdController.text == "" ||
            _r36dMsController.text == "" ||
            _r36dWdController.text == "" ||
            _r37dMsController.text == "" ||
            _r37dWdController.text == "" ||
            _r38dMsController.text == "" ||
            _r38dWdController.text == "" ||
            _r39dMsController.text == "" ||
            _r39dWdController.text == "" ||
            _r40dMsController.text == "" ||
            _r40dWdController.text == "" ||
            _j02dMsController.text == "" ||
            _j02dWdController.text == "") ||
        (_r32dMsController.text == "0" ||
            _r32dWdController.text == "0" ||
            _r33dMsController.text == "0" ||
            _r33dWdController.text == "0" ||
            _r34dMsController.text == "0" ||
            _r34dWdController.text == "0" ||
            _r35dMsController.text == "0" ||
            _r35dWdController.text == "0" ||
            _r36dMsController.text == "0" ||
            _r36dWdController.text == "0" ||
            _r37dMsController.text == "0" ||
            _r37dWdController.text == "0" ||
            _r38dMsController.text == "0" ||
            _r38dWdController.text == "0" ||
            _r39dMsController.text == "0" ||
            _r39dWdController.text == "0" ||
            _r40dMsController.text == "0" ||
            _r40dWdController.text == "0" ||
            _j02dMsController.text == "0" ||
            _j02dWdController.text == "0")) {
      return false;
    } else {
      return true;
    }
  }

  // 清空所有文本框
  _allTextFileReset() {
    _r32dMsController.text = "";
    _r32dWdController.text = "";
    _r33dMsController.text = "";
    _r33dWdController.text = "";
    _r34dMsController.text = "";
    _r34dWdController.text = "";
    _r35dMsController.text = "";
    _r35dWdController.text = "";
    _r36dMsController.text = "";
    _r36dWdController.text = "";
    _r37dMsController.text = "";
    _r37dWdController.text = "";
    _r38dMsController.text = "";
    _r38dWdController.text = "";
    _r39dMsController.text = "";
    _r39dWdController.text = "";
    _r40dMsController.text = "";
    _r40dWdController.text = "";
    _j02dMsController.text = "";
    _j02dWdController.text = "";
  }
}
