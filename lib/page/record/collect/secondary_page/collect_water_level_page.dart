import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/db/tab_water_level_collect_manager.dart';
import 'package:mdc_bhl/utils/common_utils.dart';
import 'package:mdc_bhl/utils/date_utils.dart';
import 'package:mdc_bhl/widget/gradient_appbar.dart';

import '../my_collect_list_home_page.dart';

/* 水位页面——我的采集二级页面 */
class CollectWaterLevelPage extends StatefulWidget {
  MyCollectListModel _myCollectListModel;

  CollectWaterLevelPage(this._myCollectListModel);

  @override
  State<StatefulWidget> createState() =>
      new CollectWaterLevelPageState(_myCollectListModel);
}

class CollectWaterLevelPageState extends State<CollectWaterLevelPage> {
  MyCollectListModel _myCollectListModel;

  CollectWaterLevelPageState(this._myCollectListModel);

  TabWaterLevelCollectManager _tabWaterLevelCollectManager =
      new TabWaterLevelCollectManager();
  TabWaterLevelCollectModel _tabWaterLevelCollectModel =
      new TabWaterLevelCollectModel();

  // 当前水位
  TextEditingController _waterLevelController = new TextEditingController();
  FocusNode _waterLevelFocusNode = new FocusNode();

  @override
  void initState() {
    _waterLevelFocusNode.addListener(() {
      if (_waterLevelFocusNode.hasFocus && _waterLevelController.text == "0") {
        _waterLevelController.text = "";
      }
    });

    setState(() {
      _initData().then((_) {
        _waterLevelController.text =
            _tabWaterLevelCollectModel.waterLevelValue.toString();
      });
    });
    super.initState();
  }

  _initData() async {
    List<TabWaterLevelCollectModel> tabWaterLevelCollectModelList =
        await _tabWaterLevelCollectManager
            .queryById(_myCollectListModel.recordId);
    setState(() {
      _tabWaterLevelCollectModel = tabWaterLevelCollectModelList[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          /// 通过GestureDetector捕获点击事件，再通过FocusScope将焦点转移至空焦点——new FocusNode()
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          appBar: GradientAppBar(
            gradientStart: Color(0xFF2171F5),
            gradientEnd: Color(0xFF49A2FC),
            centerTitle: true,
            leading: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pop(context, "未保存");
                },
                child: Icon(Icons.chevron_left, size: 30)
            ),
            title: new Text('水位记录'),
//            leading: GestureDetector(
//                onTap: () {
//                  setState(() {
//                    if (_tabWaterLevelCollectModel.isUpload != 1) {
//                      _saveRecord().then((_) {
//                        Navigator.pop(context);
//                      });
//                    } else {
//                      Navigator.pop(context);
//                    }
//                  });
//                },
//                child: Icon(Icons.chevron_left, size: 30)
//            )
          ),
          body: Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(children: <Widget>[
                _item("当前水位", _waterLevelController, _waterLevelFocusNode)
              ])),
//        floatingActionButton: _tabWaterLevelCollectModel.isUpload != 1 ? FloatingActionButton(
//            heroTag: 'collect_water_level_btn',
//            onPressed: () {
//              _uploadRecord();
//            },
//            tooltip: '提交',
//            child: new Column(
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: <Widget>[
//                  Icon(Icons.file_upload),
//                  Text("提交", style: new TextStyle(fontSize: 10))
//                ]
//            )
//        ) : null
        ));
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
                  style: new TextStyle(
                      color: const Color(ColorConfig.darkTextColor),
                      fontSize: FontConfig.contentTextSize)),
              Expanded(
                  child: new Container(
                      margin: EdgeInsets.only(right: 15, left: 20),
                      decoration: new BoxDecoration(
                          color: Colors.white,
                          border: new Border.all(
                              color: const Color(ColorConfig.borderColor),
                              width: 0.5),
                          borderRadius: new BorderRadius.circular(3)),
                      child: new TextField(
                          enabled: false,
                          controller: controller,
                          focusNode: focusNode,
                          style: TextStyle(
                              color: const Color(ColorConfig.darkTextColor),
                              fontSize: FontConfig.contentTextSize),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            WhitelistingTextInputFormatter(RegExp("[0-9.]")), // 只输入数字（有小数）
//                            WhitelistingTextInputFormatter.digitsOnly, // 只输入数字（无小数）
//                            LengthLimitingTextInputFormatter(6) // 最大长度
                          ],
                          decoration: const InputDecoration(
                              hintText: '请输入信息',
                              contentPadding: const EdgeInsets.all(8),
                              border: InputBorder.none),
                          // 当value改变的时候，触发
                          onChanged: (val) {
                            // print(val);
                          })),
                  flex: 3),
              Text("米",
                  style: new TextStyle(
                      color: const Color(ColorConfig.darkTextColor),
                      fontSize: FontConfig.contentTextSize))
            ]));
  }

  // 保存水位采集数据
  _saveRecord() async {
    if (_waterLevelController.text == "" || _waterLevelController.text == "0") {
      return;
    }
    // 插入数据
    setState(() {
      _tabWaterLevelCollectModel.waterLevelValue = double.parse(
          _waterLevelController.text == "" ? "0" : _waterLevelController.text);
      _tabWaterLevelCollectModel.isUpload = 0;
      _tabWaterLevelCollectModel.uploadTime = DateUtils.getCurrentTime();
    });
    await _tabWaterLevelCollectManager.insert(_tabWaterLevelCollectModel);
  }

  // 上传水位采集数据
  _uploadRecord() async {
    if (_waterLevelController.text == "" || _waterLevelController.text == "0") {
      CommonUtils.showTextToast("请输入后提交");
      return;
    }
    // 插入数据
    setState(() {
      _tabWaterLevelCollectModel.waterLevelValue = double.parse(
          _waterLevelController.text == "" ? "0" : _waterLevelController.text);
      _tabWaterLevelCollectModel.isUpload = 1;
      _tabWaterLevelCollectModel.uploadTime = DateUtils.getCurrentTime();
    });
    await _tabWaterLevelCollectManager.insert(_tabWaterLevelCollectModel);
    // 上传数据
    // TODO: 上传数据
  }
}
