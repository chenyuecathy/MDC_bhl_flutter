import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/db/tab_stable_collect_manager.dart';
import 'package:mdc_bhl/utils/common_utils.dart';
import 'package:mdc_bhl/utils/date_utils.dart';
import 'package:mdc_bhl/widget/gradient_appbar.dart';

import '../my_collect_list_home_page.dart';

/* 稳定性采集页面——我的采集二级页面 */
class CollectStablePage extends StatefulWidget {
  MyCollectListModel _myCollectListModel;

  CollectStablePage(this._myCollectListModel);

  @override
  State<StatefulWidget> createState() => new CollectStablePageState(_myCollectListModel);
}

class CollectStablePageState extends State<CollectStablePage> {
  MyCollectListModel _myCollectListModel;

  CollectStablePageState(this._myCollectListModel);

  TabStableCollectManager _tabStableCollectManager = new TabStableCollectManager();
  TabStableCollectModel _tabStableCollectModel = new TabStableCollectModel();

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

    setState(() {
      _initData().then((_) {
        _r32dMsController.text = _tabStableCollectModel.r32dMsValue.toString();
        _r32dWdController.text = _tabStableCollectModel.r32dWdValue.toString();
        _r33dMsController.text = _tabStableCollectModel.r33dMsValue.toString();
        _r33dWdController.text = _tabStableCollectModel.r33dWdValue.toString();
        _r34dMsController.text = _tabStableCollectModel.r34dMsValue.toString();
        _r34dWdController.text = _tabStableCollectModel.r34dWdValue.toString();
        _r35dMsController.text = _tabStableCollectModel.r35dMsValue.toString();
        _r35dWdController.text = _tabStableCollectModel.r35dWdValue.toString();
        _r36dMsController.text = _tabStableCollectModel.r36dMsValue.toString();
        _r36dWdController.text = _tabStableCollectModel.r36dWdValue.toString();
        _r37dMsController.text = _tabStableCollectModel.r37dMsValue.toString();
        _r37dWdController.text = _tabStableCollectModel.r37dWdValue.toString();
        _r38dMsController.text = _tabStableCollectModel.r38dMsValue.toString();
        _r38dWdController.text = _tabStableCollectModel.r38dWdValue.toString();
        _r39dMsController.text = _tabStableCollectModel.r39dMsValue.toString();
        _r39dWdController.text = _tabStableCollectModel.r39dWdValue.toString();
        _r40dMsController.text = _tabStableCollectModel.r40dMsValue.toString();
        _r40dWdController.text = _tabStableCollectModel.r40dWdValue.toString();
        _j02dMsController.text = _tabStableCollectModel.j02dMsValue.toString();
        _j02dWdController.text = _tabStableCollectModel.j02dWdValue.toString();
      });
    });
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

  _initData() async {
    List<TabStableCollectModel> tabStableCollectModelList = await _tabStableCollectManager.queryById(_myCollectListModel.recordId);
    setState(() {
      _tabStableCollectModel = tabStableCollectModelList[0];
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
                child: Icon(Icons.chevron_left, size: 30)),
            title: new Text('稳定性记录'),
//            leading: GestureDetector(
//                onTap: () {
//                  if (_tabStableCollectModel.isUpload != 1) {
//                    setState(() {
//                      _saveRecord().then((_) {
//                        Navigator.pop(context);
//                      });
//                    });
//                  } else {
//                    Navigator.pop(context);
//                  }
//                },
//                child: Icon(Icons.chevron_left, size: 30)
//            )
          ),
          body: new SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(children: <Widget>[
                    Row(children: <Widget>[
                      Expanded(
                          child: Container(
                              margin: EdgeInsets.only(right: 15),
                              child: new Text(
                                "监测设备",
                                style: new TextStyle(color: const Color(ColorConfig.darkTextColor), fontSize: FontConfig.contentTextSize, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              )),
                          flex: 2),
                      Expanded(
                          child: new Text("模数值",
                              style: new TextStyle(color: const Color(ColorConfig.darkTextColor), fontSize: FontConfig.contentTextSize, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          flex: 2),
                      Expanded(
                          child: new Text("温度值",
                              style: new TextStyle(color: const Color(ColorConfig.darkTextColor), fontSize: FontConfig.contentTextSize, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          flex: 2)
                    ]),
                    const SizedBox(height: 20.0), // 占位图
                    _item("钢筋计R32D", _r32dMsController, _r32dMsFocusNode, _r32dWdController, _r32dWdFocusNode),
                    const SizedBox(height: 20.0), // 占位图
                    _item("钢筋计R33D", _r33dMsController, _r33dMsFocusNode, _r33dWdController, _r33dWdFocusNode),
                    const SizedBox(height: 20.0), // 占位图
                    _item("钢筋计R34D", _r34dMsController, _r34dMsFocusNode, _r34dWdController, _r34dWdFocusNode),
                    const SizedBox(height: 20.0), // 占位图
                    _item("钢筋计R35D", _r35dMsController, _r35dMsFocusNode, _r35dWdController, _r35dWdFocusNode),
                    const SizedBox(height: 20.0), // 占位图
                    _item("钢筋计R36D", _r36dMsController, _r36dMsFocusNode, _r36dWdController, _r36dWdFocusNode),
                    const SizedBox(height: 20.0), // 占位图
                    _item("钢筋计R37D", _r37dMsController, _r37dMsFocusNode, _r37dWdController, _r37dWdFocusNode),
                    const SizedBox(height: 20.0), // 占位图
                    _item("钢筋计R38D", _r38dMsController, _r38dMsFocusNode, _r38dWdController, _r38dWdFocusNode),
                    const SizedBox(height: 20.0), // 占位图
                    _item("钢筋计R39D", _r39dMsController, _r39dMsFocusNode, _r39dWdController, _r39dWdFocusNode),
                    const SizedBox(height: 20.0), // 占位图
                    _item("钢筋计R40D", _r40dMsController, _r40dMsFocusNode, _r40dWdController, _r40dWdFocusNode),
                    const SizedBox(height: 20.0), // 占位图
                    _item("测缝计J02D", _j02dMsController, _j02dMsFocusNode, _j02dWdController, _j02dWdFocusNode)
                  ]))),
//        floatingActionButton: _tabStableCollectModel.isUpload != 1 ? FloatingActionButton(
//            heroTag: 'collect_stable_btn',
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

  _item(String title, TextEditingController msController, FocusNode msFocusNode, TextEditingController wdController, FocusNode wdFocusNode) {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          Expanded(child: new Text(title, style: new TextStyle(color: const Color(ColorConfig.darkTextColor), fontSize: FontConfig.contentTextSize)), flex: 2),
          Expanded(
              child: new Container(
                  margin: EdgeInsets.only(right: 5, left: 20),
                  decoration: new BoxDecoration(color: Colors.white, border: new Border.all(color: const Color(ColorConfig.borderColor), width: 0.5), borderRadius: new BorderRadius.circular(3)),
                  child:
//                      new TextField(
//                          controller: msController,
//                          focusNode: msFocusNode,
//                          style: TextStyle(
//                              color: const Color(ColorConfig.darkTextColor),
//                              fontSize: FontConfig.contentTextSize),
//                          keyboardType: TextInputType.number,
//                          inputFormatters: <TextInputFormatter>[
//                            WhitelistingTextInputFormatter(RegExp("[0-9.]")), // 只输入数字（有小数）
////                            WhitelistingTextInputFormatter.digitsOnly, // 只输入数字（无小数）
////                            LengthLimitingTextInputFormatter(6) // 最大长度
//                          ],
//                          decoration: const InputDecoration(
//                              // hintText: '请输入信息',
//                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
//                              border: InputBorder.none),
//                          // 当value改变的时候，触发
//                          onChanged: (val) {
//                            // print(val);
//                          })
                      Container(padding: EdgeInsets.all(8), child: Text(msController.text))),
              flex: 2),
          new Text(title != "测缝计J02D" ? "MPa" : "mm",
              style: new TextStyle(color: const Color(ColorConfig.darkTextColor), fontSize: title != "测缝计J02D" ? FontConfig.minTextSize : FontConfig.contentTextSize)),
          Expanded(
              child: new Container(
                  margin: EdgeInsets.only(right: 5, left: 20),
                  decoration: new BoxDecoration(color: Colors.white, border: new Border.all(color: const Color(ColorConfig.borderColor), width: 0.5), borderRadius: new BorderRadius.circular(3)),
                  child:
//                  new TextField(
//                      controller: wdController,
//                      focusNode: wdFocusNode,
//                      style: TextStyle(color: const Color(ColorConfig.darkTextColor), fontSize: FontConfig.contentTextSize),
//                      keyboardType: TextInputType.number,
//                      inputFormatters: <TextInputFormatter>[
//                        WhitelistingTextInputFormatter(RegExp("[0-9.]")), // 只输入数字（有小数）
////                            WhitelistingTextInputFormatter.digitsOnly, // 只输入数字（无小数）
////                            LengthLimitingTextInputFormatter(6) // 最大长度
//                      ],
//                      decoration: const InputDecoration(
//                          // hintText: '请输入信息',
//                          contentPadding: const EdgeInsets.all(8),
//                          border: InputBorder.none),
//                      // 当value改变的时候，触发
//                      onChanged: (val) {
//                        // print(val);
//                      })
                      Container(padding: EdgeInsets.all(8), child: Text(msController.text))),
              flex: 2),
          new Text("°C", style: new TextStyle(color: const Color(ColorConfig.darkTextColor), fontSize: FontConfig.contentTextSize))
        ]));
  }

  // 保存稳定性采集数据
  _saveRecord() async {
    if (_isAllTextFileNoContent()) {
      return;
    }
    // 插入数据
    setState(() {
      _setValue();
      _tabStableCollectModel.isUpload = 0;
      _tabStableCollectModel.uploadTime = DateUtils.getCurrentTime();
    });
    await _tabStableCollectManager.insert(_tabStableCollectModel);
  }

  // 上传稳定性采集数据
  _uploadRecord() async {
    if (_isAllTextFileHasContent() == false) {
      CommonUtils.showTextToast("请输入后提交");
      return;
    }
    // 插入数据
    setState(() {
      _setValue();
      _tabStableCollectModel.isUpload = 1;
      _tabStableCollectModel.uploadTime = DateUtils.getCurrentTime();
    });
    await _tabStableCollectManager.insert(_tabStableCollectModel);
    // 上传数据
    // TODO: 上传数据
  }

  // 设置各种value的值
  _setValue() {
    _tabStableCollectModel.r32dMsValue = double.parse(_r32dMsController.text == "" ? "0" : _r32dMsController.text);
    _tabStableCollectModel.r32dWdValue = double.parse(_r32dWdController.text == "" ? "0" : _r32dWdController.text);
    _tabStableCollectModel.r33dMsValue = double.parse(_r33dMsController.text == "" ? "0" : _r33dMsController.text);
    _tabStableCollectModel.r33dWdValue = double.parse(_r33dWdController.text == "" ? "0" : _r33dWdController.text);
    _tabStableCollectModel.r34dMsValue = double.parse(_r34dMsController.text == "" ? "0" : _r34dMsController.text);
    _tabStableCollectModel.r34dWdValue = double.parse(_r34dWdController.text == "" ? "0" : _r34dWdController.text);
    _tabStableCollectModel.r35dMsValue = double.parse(_r35dMsController.text == "" ? "0" : _r35dMsController.text);
    _tabStableCollectModel.r35dWdValue = double.parse(_r35dWdController.text == "" ? "0" : _r35dWdController.text);
    _tabStableCollectModel.r36dMsValue = double.parse(_r36dMsController.text == "" ? "0" : _r36dMsController.text);
    _tabStableCollectModel.r36dWdValue = double.parse(_r36dWdController.text == "" ? "0" : _r36dWdController.text);
    _tabStableCollectModel.r37dMsValue = double.parse(_r37dMsController.text == "" ? "0" : _r37dMsController.text);
    _tabStableCollectModel.r37dWdValue = double.parse(_r37dWdController.text == "" ? "0" : _r37dWdController.text);
    _tabStableCollectModel.r38dMsValue = double.parse(_r38dMsController.text == "" ? "0" : _r38dMsController.text);
    _tabStableCollectModel.r38dWdValue = double.parse(_r38dWdController.text == "" ? "0" : _r38dWdController.text);
    _tabStableCollectModel.r39dMsValue = double.parse(_r39dMsController.text == "" ? "0" : _r39dMsController.text);
    _tabStableCollectModel.r39dWdValue = double.parse(_r39dWdController.text == "" ? "0" : _r39dWdController.text);
    _tabStableCollectModel.r40dMsValue = double.parse(_r40dMsController.text == "" ? "0" : _r40dMsController.text);
    _tabStableCollectModel.r40dWdValue = double.parse(_r40dWdController.text == "" ? "0" : _r40dWdController.text);
    _tabStableCollectModel.j02dMsValue = double.parse(_j02dMsController.text == "" ? "0" : _j02dMsController.text);
    _tabStableCollectModel.j02dWdValue = double.parse(_j02dWdController.text == "" ? "0" : _j02dWdController.text);
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
}
