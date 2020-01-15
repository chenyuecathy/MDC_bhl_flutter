import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/common/event/index.dart';
import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/common/net/address.dart';
import 'package:mdc_bhl/db/tab_water_level_collect_manager.dart';
import 'package:mdc_bhl/utils/common_utils.dart';
import 'package:mdc_bhl/utils/date_utils.dart';
import 'package:mdc_bhl/utils/eventbus_utils.dart';
import 'package:mdc_bhl/utils/net_utils.dart';
import 'package:uuid/uuid.dart';

const int maxWaterLevel = 184;
const int minWaterLevel = 96;
const double topContainerH = 150;

/* 水位页面 */
/*
 * 文本框保存的是该用户输入或上传的上一次数据
 * 浮标鱼显示的是所有用户上一次提交的数据
 */
class CollectWaterLevelPage extends StatefulWidget {
  final double bulidHeight;

  CollectWaterLevelPage(this.bulidHeight);

  @override
  State<StatefulWidget> createState() => CollectWaterLevelPageState();
}

class CollectWaterLevelPageState extends State<CollectWaterLevelPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  StreamSubscription subscription;

  String _userId;
  String _userName;
  String _waterLevelId;


  TabWaterLevelCollectManager _tabWaterLevelCollectManager = TabWaterLevelCollectManager();

  // 当前水位
  TextEditingController _waterLevelController = TextEditingController();
  FocusNode _waterLevelFocusNode = FocusNode();


  double bottomHeight;
  double oneHundredAndTwentyWaterHeight;
  @override
  void initState() {

    bottomHeight = widget.bulidHeight - topContainerH;
    oneHundredAndTwentyWaterHeight = bottomHeight / (maxWaterLevel-minWaterLevel) ;

    _waterLevelFocusNode.addListener(() {
      if (_waterLevelFocusNode.hasFocus && _waterLevelController.text == "0") {
        _waterLevelController.text = "";
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
    // 初始化水位id
    String waterLevelId =
        await LocalStorage.get(Config.WATER_LEVEL_ID_WITH_TABBAR_BOTTOM);
    if (waterLevelId != null) {
      _waterLevelId = waterLevelId;
    } else {
      _waterLevelId = Uuid().v1();
      await LocalStorage.save(
          Config.WATER_LEVEL_ID_WITH_TABBAR_BOTTOM, _waterLevelId);
    }

    //订阅eventbus
    subscription = eventBus.on<EventUtil>().listen((event) async {
      if (event.message == Config.SAVE_WATER_LEVEL_WITH_TABBAR_BOTTOM) {
        if (_waterLevelId != null) {
          debugPrint("保存水位" + _waterLevelId);
          _saveRecord();
        }
        // 设置水位数据
        setWaterData(await _getWaterLevel());
      } else if (event.message == Config.REFRESH_COLLECT_TAB_WATER_LEVEL) {
        _initParams().then((_) => _getUnupload());
      }
    });
  }

  // 获取未提交
  _getUnupload() async {
    // 设置水位数据
    setWaterData(await _getWaterLevel());

    List<TabWaterLevelCollectModel> tabWaterLevelCollectModelList =
        await _tabWaterLevelCollectManager.queryByUserIdWithUnupload(_userId);
    if (tabWaterLevelCollectModelList.length == 0) {
      _waterLevelId = Uuid().v1();
      await LocalStorage.save(
          Config.WATER_LEVEL_ID_WITH_TABBAR_BOTTOM, _waterLevelId);
      _waterLevelController.text = "";
      return;
    }
    TabWaterLevelCollectModel tabWaterLevelCollectModel =
        tabWaterLevelCollectModelList[0];
    _waterLevelId = tabWaterLevelCollectModel.id;
    _waterLevelController.text =
        tabWaterLevelCollectModel.waterLevelValue.toString();
    LocalStorage.save(Config.SEEPAGE_ID_WITH_TABBAR_BOTTOM, _waterLevelId);
  }

  @override
  void dispose() {
    super.dispose();
    if (subscription != null) {
      //取消eventbus订阅
      subscription.cancel();
    }
  }

  // 设置水位数据
  double readWaterValue = 0;
  double readWaterHeight = 0;
  double fishHeight = 0;

  setWaterData(double readValue) {
    setState(() {
      readWaterValue = readValue;
      readWaterHeight = (readValue - minWaterLevel) * oneHundredAndTwentyWaterHeight;
      // readWaterHeight = widget.oneHundredAndTwentyWaterHeight +
      //     ((widget.bottomHeight / 44 * (42 - 12)) *
      //         ((readValue - 120) / (180 - 120)));
      fishHeight = readWaterHeight - 15 / 2;
    });
  }

  // 获取所有用户最后一次上传的水位数据
  _getWaterLevel() async {
    var swURL = Address.getSw();
    var response = await NetUtils.get(swURL);
    print("获取所有用户最后一次上传的水位数据:$response");
    Map<String, dynamic> responseDictionary = json.decode(response);
    dynamic isSuccess = responseDictionary['RESULTVALUE']['SW'];
    return double.parse(isSuccess.toString());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    print('water level height:${MediaQuery.of(context).size.height}');

    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          /// 通过GestureDetector捕获点击事件，再通过FocusScope将焦点转移至空焦点—— FocusNode()
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
            body: 
            // SingleChildScrollView(
            //     scrollDirection: Axis.vertical,
            //     child: 
                // Column(children: <Widget>[
                //   Container(
                //     height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                //     width: MediaQuery.of(context).size.width,
                //     child:
                  Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                            height: topContainerH,
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                            child: _item("当前水位", _waterLevelController, _waterLevelFocusNode)),
                        Container(
                            height: bottomHeight,
                            child: Stack(
                              children: <Widget>[
                                Container(
                                    height: bottomHeight,
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(children: <Widget>[
                                      Stack(children: <Widget>[
                                        Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Container(
                                                  height: readWaterHeight,
                                                  width: 20,
                                                  color: Color(0XFF2196f3)),
                                            ]),
                                        Image.asset('images/ic_water_level_degree.png',
                                            fit: BoxFit.fill,
                                            height:bottomHeight,
                                            width: 20),
                                      ]),
                                      SizedBox(width: 5),
                                      Column(
                                        verticalDirection: VerticalDirection.up,
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Expanded( child:Container(alignment: Alignment.center,child:Text("100", style: TextStyle( color: Color(0XFF2196f3), fontSize: 14)))),
                                          Expanded( child:Container(alignment: Alignment.center,child:Text("110", style: TextStyle( color: Color(0XFF2196f3), fontSize: 14)))),
                                          Expanded( child:Container(alignment: Alignment.center,child:Text("120", style: TextStyle( color: Color(0XFF2196f3), fontSize: 14)))),
                                          Expanded( child:Container(alignment: Alignment.center,child:Text("130", style: TextStyle( color: Color(0XFF2196f3), fontSize: 14)))),
                                          Expanded( child:Container(alignment: Alignment.center,child:Text("140", style: TextStyle( color: Color(0XFF2196f3), fontSize: 14)))),
                                          Expanded( child:Container(alignment: Alignment.center,child:Text("150", style: TextStyle( color: Color(0XFF2196f3), fontSize: 14)))),
                                          Expanded( child:Container(alignment: Alignment.center,child:Text("160", style: TextStyle( color: Color(0XFF2196f3), fontSize: 14)))),
                                          Expanded( child:Container(alignment: Alignment.center,child:Text("170", style: TextStyle( color: Color(0XFF2196f3), fontSize: 14)))),
                                          Expanded( child:Container(alignment: Alignment.center,child:Text("180", style: TextStyle( color: Color(0XFF2196f3), fontSize: 14)))),
                                        ],
                                      ),
                                      Column(
                                          verticalDirection: VerticalDirection.up,
                                          children: <Widget>[
                                            SizedBox(height: fishHeight),
                                            Row(children: <Widget>[
                                              Image.asset( 'images/ic_water_level_fish.png', fit: BoxFit.fill, height: 15, width: 30),
                                              Text('  '+readWaterValue.toString(), style: TextStyle( color: Color(0XFF00cde3), fontSize: 14))
                                            ])
                                          ])
                                    ])),
                                Column(
                                  verticalDirection: VerticalDirection.up,
                                  children: <Widget>[
                                    Image.asset('images/water_level_bg.png', height: bottomHeight-topContainerH, width: MediaQuery.of(context).size.width, fit: BoxFit.fill)
                                  ],
                                )
                              ],
                            ))
                      ]),
                //   )
                
                // ])
                // )
                // ,
            floatingActionButton: FloatingActionButton(
                heroTag: 'collect_water_level_btn',
                onPressed: () {
                  _uploadRecord().then((_) async {
                    if (_waterLevelController.text == "" ||
                        _waterLevelController.text == "0") {
                      return;
                    }
                    _waterLevelController.text = "";
                    _waterLevelId = Uuid().v1();
                    await LocalStorage.save(
                        Config.WATER_LEVEL_ID_WITH_TABBAR_BOTTOM,
                        _waterLevelId);
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
        padding: EdgeInsets.all(20),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Image.asset('images/ic_water_level.png',
                      height: 20, width: 20)),
              Text(title,
                  style: TextStyle(
                      color: const Color(ColorConfig.darkTextColor),
                      fontSize: FontConfig.contentTextSize)),
              Expanded(
                  child: Container(
                      margin: EdgeInsets.only(right: 15, left: 20),
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
                              border: InputBorder.none),
                          // 当value改变的时候，触发
                          onChanged: (val) {
                            print(val);
                          })),
                  flex: 3),
              Text("米",
                  style: TextStyle(
                      color: const Color(ColorConfig.darkTextColor),
                      fontSize: FontConfig.contentTextSize))
            ]));
  }

  // 保存稳定性采���数据
  _saveRecord() async {
    if (_waterLevelController.text == "" || _waterLevelController.text == "0") {
      return;
    } else {
      // 水位阈值控制
      if (double.parse(_waterLevelController.text) < 120) {
        CommonUtils.showTextToast("水位值不得低于120米");
        _waterLevelController.text = "";
      } else if (double.parse(_waterLevelController.text) > 180) {
        CommonUtils.showTextToast("水位值不得高于180米");
        _waterLevelController.text = "";
      } else {
        // 插入数据
        TabWaterLevelCollectModel _tabWaterLevelCollectModel =
            TabWaterLevelCollectModel();
        _tabWaterLevelCollectModel.id = _waterLevelId;
        _tabWaterLevelCollectModel.collectorId = _userId;
        _tabWaterLevelCollectModel.waterLevelValue = double.parse(
            _waterLevelController.text == ""
                ? "0"
                : _waterLevelController.text);
        _tabWaterLevelCollectModel.isUpload = 0;
        _tabWaterLevelCollectModel.uploadTime = DateUtils.getCurrentTime();
        await _tabWaterLevelCollectManager.insert(_tabWaterLevelCollectModel);
      }
    }
  }

  // 上传水位采集数据
  _uploadRecord() async {
    if (_waterLevelController.text == "" || _waterLevelController.text == "0") {
      CommonUtils.showTextToast("请输入后提交");
    } else {
      // 水位阈值控制
      if (double.parse(_waterLevelController.text) < 120) {
        CommonUtils.showTextToast("水位值不得低于120米");
      } else if (double.parse(_waterLevelController.text) > 180) {
        CommonUtils.showTextToast("水位值不得高于180米");
      } else {
        // 插入数据
        TabWaterLevelCollectModel _tabWaterLevelCollectModel =
            TabWaterLevelCollectModel();
        _tabWaterLevelCollectModel.id = _waterLevelId;
        _tabWaterLevelCollectModel.collectorId = _userId;
        _tabWaterLevelCollectModel.waterLevelValue = double.parse(
            _waterLevelController.text == ""
                ? "0"
                : _waterLevelController.text);
        _tabWaterLevelCollectModel.isUpload = 1;
        _tabWaterLevelCollectModel.uploadTime = DateUtils.getCurrentTime();
        await _tabWaterLevelCollectManager.insert(_tabWaterLevelCollectModel);
        // 上传数据
        String waterlevel =
            json.encode(_tabWaterLevelCollectModel.toJson(_userName));
        print("saveSw参数:" + waterlevel);
        var saveSw = Address.saveSw();
        var response = await NetUtils.post(saveSw, {'Sw': waterlevel});
        print("saveSw返回值:" + response);
        if (json.decode(response)['IsSuccess'] == false) {
          CommonUtils.showTextToast("数据上传失败，请稍后重试");
          return;
        } else {
          CommonUtils.showAlertDialog(context, '温馨提示', "数据上传成功", () {});
        }
        // 设置水位数据
        setWaterData(_tabWaterLevelCollectModel.waterLevelValue);
      }
    }
  }
}
