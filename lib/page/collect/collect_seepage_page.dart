import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/common/event/index.dart';
import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/common/net/address.dart';
import 'package:mdc_bhl/db/tab_seepage_collect_manager.dart';
import 'package:mdc_bhl/utils/common_utils.dart';
import 'package:mdc_bhl/utils/date_utils.dart';
import 'package:mdc_bhl/utils/eventbus_utils.dart';
import 'package:mdc_bhl/utils/net_utils.dart';
import 'package:uuid/uuid.dart';

/* 渗漏水采集页面 */
class CollectSeepagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CollectSeepagePageState();
}

class CollectSeepagePageState extends State<CollectSeepagePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  StreamSubscription subscription;

  String _userId;
  String _userName;
  String _seepageId;

  TabSeepageCollectManager _tabSeepageCollectManager =
      TabSeepageCollectManager();

  TextEditingController _upstreamLineController =
      TextEditingController(); // 上游廊道线路出处
  FocusNode _upstreamLineFocusNode = FocusNode();
  TextEditingController _downstreamLineController =
      TextEditingController(); // 下游廊道线路出处
  FocusNode _downstreamLineFocusNode = FocusNode();
  TextEditingController _downstreamGapController =
      TextEditingController(); // 下游廊道伸缩缝
  FocusNode _downstreamGapFocusNode = FocusNode();

  @override
  void initState() {
    // 文本框改变监听
    _upstreamLineFocusNode.addListener(() {
      if (_upstreamLineFocusNode.hasFocus &&
          _upstreamLineController.text == "0") {
        _upstreamLineController.text = "";
      }
    });
    _downstreamLineFocusNode.addListener(() {
      if (_downstreamLineFocusNode.hasFocus &&
          _downstreamLineController.text == "0") {
        _downstreamLineController.text = "";
      }
    });
    _downstreamGapFocusNode.addListener(() {
      if (_downstreamGapFocusNode.hasFocus &&
          _downstreamGapController.text == "0") {
        _downstreamGapController.text = "";
      }
    });

    _initParams().then((_) => _getUnupload());
    super.initState();
  }

  _initParams() async {
    // 初始化用户id
    var userInfo = await LocalStorage.get(Config.USER_INFO_KEY);
    Map<String, dynamic> responseDictionary = json.decode(userInfo);
    _userId = responseDictionary["ID"];
    _userName = responseDictionary["REALNAME"];
    // 初始化渗漏水id
    String seepageId =
        await LocalStorage.get(Config.SEEPAGE_ID_WITH_TABBAR_BOTTOM);
    if (seepageId != null) {
      _seepageId = seepageId;
    } else {
      _seepageId = Uuid().v1();
      await LocalStorage.save(Config.SEEPAGE_ID_WITH_TABBAR_BOTTOM, _seepageId);
    }

    //订阅eventbus
    subscription = eventBus.on<EventUtil>().listen((event) {
      if (event.message == Config.SAVE_SEEPAGE_WITH_TABBAR_BOTTOM) {
        if (_seepageId != null) {
          debugPrint("保存渗漏水" + _seepageId);
          _saveRecord();
        }
      } else if (event.message == Config.REFRESH_COLLECT_TAB_SEEPAGE) {
        _initParams().then((_) => _getUnupload());
      }
    });
  }

  // 获取未提交
  _getUnupload() async {
    List<TabSeepageCollectModel> _tabSeepageCollectModelList =
        await _tabSeepageCollectManager.queryByUserIdWithUnupload(_userId);
    if (_tabSeepageCollectModelList.length == 0) {
      _seepageId = Uuid().v1();
      await LocalStorage.save(Config.SEEPAGE_ID_WITH_TABBAR_BOTTOM, _seepageId);
      _upstreamLineController.text = "";
      _downstreamLineController.text = "";
      _downstreamGapController.text = "";
      return;
    }
    TabSeepageCollectModel _tabSeepageCollectModel =
        _tabSeepageCollectModelList[0];
    _seepageId = _tabSeepageCollectModel.id;
    _upstreamLineController.text =
        _tabSeepageCollectModel.upstreamLineValue.toString();
    _downstreamLineController.text =
        _tabSeepageCollectModel.downstreamLineValue.toString();
    _downstreamGapController.text =
        _tabSeepageCollectModel.downstreamGapValue.toString();
    LocalStorage.save(Config.SEEPAGE_ID_WITH_TABBAR_BOTTOM, _seepageId);
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
          /// 通过GestureDetector捕获点击事件，再通过FocusScope将焦点转移至空焦点—— FocusNode()
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
            body: Container(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(children: <Widget>[
                  _item("上游廊道线路出处", _upstreamLineController,
                      _upstreamLineFocusNode),
                  const SizedBox(height: 20.0), // 占位图
                  _item("下游廊道线路出处", _downstreamLineController,
                      _downstreamLineFocusNode),
                  const SizedBox(height: 20.0), // 占位图
                  _item("下游廊道伸缩缝", _downstreamGapController,
                      _downstreamGapFocusNode)
                ])),
            floatingActionButton: FloatingActionButton(
                heroTag: 'collect_seepage_btn',
                onPressed: () {
                  _uploadRecord().then((_) async {
                    if (_isAllTextFileHasContent() == false) {
                      return;
                    }
                    _allTextFileReset();
                    _seepageId = Uuid().v1();
                    await LocalStorage.save(
                        Config.SEEPAGE_ID_WITH_TABBAR_BOTTOM, _seepageId);
                  });
                },
                tooltip: '提交',
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.file_upload),
                      Text("提交", style: TextStyle(fontSize: 10))
                    ]))));
  }

  _item(String title, TextEditingController controller, FocusNode focusNode) {
    return Container(
        padding: EdgeInsets.all(10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: Text(title,
                      style: TextStyle(
                          color: const Color(ColorConfig.darkTextColor),
                          fontSize: FontConfig.contentTextSize)),
                  flex: 4),
              Expanded(
                  child: Container(
                      margin: EdgeInsets.only(right: 10, left: 5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: const Color(ColorConfig.borderColor),
                              width: 0.5),
                          borderRadius: BorderRadius.circular(3)),
                      child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          style: TextStyle(
                              color: const Color(ColorConfig.darkTextColor),
                              fontSize: FontConfig.contentTextSize),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: <TextInputFormatter>[
                            WhitelistingTextInputFormatter(
                                RegExp("[0-9.]")), // 只输入数字（有小数）
//                            WhitelistingTextInputFormatter.digitsOnly, // 只输入数字（无小数）
//                            LengthLimitingTextInputFormatter(6) // 最大长度
                          ],
                          decoration: const InputDecoration(
                            hintText: '请输入信息',
                            contentPadding: const EdgeInsets.all(8),
                            border: InputBorder.none,
                          ),
                          // 当value改变的时候，触发
                          onChanged: (val) {
                            print('val:' + val);
                          })),
                  flex: 5),
              Expanded(
                  child: Text("Kg",
                      style: TextStyle(
                          color: const Color(ColorConfig.darkTextColor),
                          fontSize: FontConfig.contentTextSize)))
            ]));
  }

  // 保存渗漏水采集数据
  _saveRecord() async {
    if (_isAllTextFileNoContent()) {
      return;
    }
    // 插入数据
    TabSeepageCollectModel _tabSeepageCollectModel = TabSeepageCollectModel();
    _tabSeepageCollectModel.id = _seepageId;
    _tabSeepageCollectModel.collectorId = _userId;
    _tabSeepageCollectModel.upstreamLineValue = double.parse(
        _upstreamLineController.text == ""
            ? "0"
            : _upstreamLineController.text);
    _tabSeepageCollectModel.downstreamLineValue = double.parse(
        _downstreamLineController.text == ""
            ? "0"
            : _downstreamLineController.text);
    _tabSeepageCollectModel.downstreamGapValue = double.parse(
        _downstreamGapController.text == ""
            ? "0"
            : _downstreamGapController.text);
    _tabSeepageCollectModel.upstreamLineId = "";
    _tabSeepageCollectModel.downstreamLineId = "";
    _tabSeepageCollectModel.downstreamGapId = "";
    _tabSeepageCollectModel.isUpload = 0;
    _tabSeepageCollectModel.uploadTime = DateUtils.getCurrentTime();
    await _tabSeepageCollectManager.insert(_tabSeepageCollectModel);
  }

  // 上传渗漏水采集数据
  _uploadRecord() async {
    if (_isAllTextFileHasContent() == false) {
      CommonUtils.showTextToast("请输入后提交");
      return;
    }
    // 插入数据
    TabSeepageCollectModel _tabSeepageCollectModel = TabSeepageCollectModel();
    _tabSeepageCollectModel.id = _seepageId;
    _tabSeepageCollectModel.collectorId = _userId;
    _tabSeepageCollectModel.upstreamLineValue = double.parse(
        _upstreamLineController.text == ""
            ? "0"
            : _upstreamLineController.text);
    _tabSeepageCollectModel.downstreamLineValue = double.parse(
        _downstreamLineController.text == ""
            ? "0"
            : _downstreamLineController.text);
    _tabSeepageCollectModel.downstreamGapValue = double.parse(
        _downstreamGapController.text == ""
            ? "0"
            : _downstreamGapController.text);
    _tabSeepageCollectModel.upstreamLineId = Uuid().v1();
    _tabSeepageCollectModel.downstreamLineId = Uuid().v1();
    _tabSeepageCollectModel.downstreamGapId = Uuid().v1();
    _tabSeepageCollectModel.isUpload = 1;
    _tabSeepageCollectModel.uploadTime = DateUtils.getCurrentTime();
    await _tabSeepageCollectManager.insert(_tabSeepageCollectModel);
    // 上传数据
    List<String> list = List();
    TabSeepageCollectServiceModel tabSeepageCollectServiceModel1 =
        TabSeepageCollectServiceModel(
            _tabSeepageCollectModel.upstreamLineId,
            "01",
            _tabSeepageCollectModel.upstreamLineValue.toString(),
            _tabSeepageCollectModel.collectorId,
            _userName);
    TabSeepageCollectServiceModel tabSeepageCollectServiceModel2 =
        TabSeepageCollectServiceModel(
            _tabSeepageCollectModel.downstreamLineId,
            "02",
            _tabSeepageCollectModel.downstreamLineValue.toString(),
            _tabSeepageCollectModel.collectorId,
            _userName);
    TabSeepageCollectServiceModel tabSeepageCollectServiceModel3 =
        TabSeepageCollectServiceModel(
            _tabSeepageCollectModel.downstreamGapId,
            "03",
            _tabSeepageCollectModel.downstreamGapValue.toString(),
            _tabSeepageCollectModel.collectorId,
            _userName);
    list.add(json.encode(tabSeepageCollectServiceModel1.toJson()));
    list.add(json.encode(tabSeepageCollectServiceModel2.toJson()));
    list.add(json.encode(tabSeepageCollectServiceModel3.toJson()));
    print("saveSls参数(List):" + list.toString());
    var saveSlsURL = Address.saveSls();
    var response = await NetUtils.post(saveSlsURL, {'Sls': list.toString()});
    print("saveSls返回值:" + response);
    if (json.decode(response)['IsSuccess'] == false) {
      CommonUtils.showTextToast("数据上传失败，请稍后重试");
      return;
    } else {
      CommonUtils.showAlertDialog(context, '温馨提示', "数据上传成功", () {});
    }
    
  }

  // 是否所有文本框都没有内容
  _isAllTextFileNoContent() {
    if (_upstreamLineController.text != "") {
      return false;
    }
    if (_downstreamLineController.text != "") {
      return false;
    }
    if (_downstreamGapController.text != "") {
      return false;
    }
    return true;
  }

  // 是否所有文本框都有内容
  _isAllTextFileHasContent() {
    if ((_upstreamLineController.text == "" ||
            _downstreamLineController.text == "" ||
            _downstreamGapController.text == "") ||
        (_upstreamLineController.text == "0" ||
            _downstreamLineController.text == "0" ||
            _downstreamGapController.text == "0")) {
      return false;
    } else {
      return true;
    }
  }

  // 清空所有文本框
  _allTextFileReset() {
    _upstreamLineController.text = "";
    _downstreamLineController.text = "";
    _downstreamGapController.text = "";
  }
}
