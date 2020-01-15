import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/db/tab_seepage_collect_manager.dart';
import 'package:mdc_bhl/page/record/collect/my_collect_list_home_page.dart';
import 'package:mdc_bhl/widget/gradient_appbar.dart';

/* 渗漏水采集页面——我的采集二级页面 */
class CollectSeepagePage extends StatefulWidget {
  MyCollectListModel _myCollectListModel;

  CollectSeepagePage(this._myCollectListModel);

  @override
  State<StatefulWidget> createState() =>
      new CollectSeepagePageState(_myCollectListModel);
}

class CollectSeepagePageState extends State<CollectSeepagePage> {
  MyCollectListModel _myCollectListModel;

  CollectSeepagePageState(this._myCollectListModel);

  TabSeepageCollectManager _tabSeepageCollectManager =
      new TabSeepageCollectManager();
  TabSeepageCollectModel _tabSeepageCollectModel = new TabSeepageCollectModel();

  TextEditingController _upstreamLineController =
      new TextEditingController(); // 上游廊道线路出处
  FocusNode _upstreamLineFocusNode = new FocusNode();
  TextEditingController _downstreamLineController =
      new TextEditingController(); // 下游廊道线路出处
  FocusNode _downstreamLineFocusNode = new FocusNode();
  TextEditingController _downstreamGapController =
      new TextEditingController(); // 下游廊道伸缩缝
  FocusNode _downstreamGapFocusNode = new FocusNode();

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

    setState(() {
      _initData().then((_) {
        _upstreamLineController.text =
            _tabSeepageCollectModel.upstreamLineValue.toString();
        _downstreamLineController.text =
            _tabSeepageCollectModel.downstreamLineValue.toString();
        _downstreamGapController.text =
            _tabSeepageCollectModel.downstreamGapValue.toString();
      });
    });
    super.initState();
  }

  _initData() async {
    List<TabSeepageCollectModel> tabSeepageCollectModelList =
        await _tabSeepageCollectManager.queryById(_myCollectListModel.recordId);
    setState(() {
      _tabSeepageCollectModel = tabSeepageCollectModelList[0];
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
            title: new Text('渗漏水记录',
                style: TextStyle(fontSize: FontConfig.naviTextSize)),
//            leading: GestureDetector(
//                onTap: () {
//                  setState(() {
//                    if (_tabSeepageCollectModel.isUpload != 1) {
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
                _item("上游廊道线路出处", _upstreamLineController,
                    _upstreamLineFocusNode),
                const SizedBox(height: 20.0), // 占位图
                _item("下游廊道线路出处", _downstreamLineController,
                    _downstreamLineFocusNode),
                const SizedBox(height: 20.0), // 占位图
                _item("下游廊道伸缩缝", _downstreamGapController,
                    _downstreamGapFocusNode)
              ])),
//        floatingActionButton: _tabSeepageCollectModel.isUpload != 1 ? FloatingActionButton(
//            heroTag: 'collect_seepage_btn',
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
        padding: EdgeInsets.all(10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: new Text(title,
                      style: new TextStyle(
                          color: const Color(ColorConfig.darkTextColor),
                          fontSize: FontConfig.contentTextSize)),
                  flex: 4),
              Expanded(
                  child: new Container(
                      margin: EdgeInsets.only(right: 10, left: 5),
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
                  flex: 5),
              Expanded(
                  child: new Text("Kg",
                      style: new TextStyle(
                          color: const Color(ColorConfig.darkTextColor),
                          fontSize: FontConfig.contentTextSize)))
            ]));
  }

  // // 保存渗漏水采集数据
  // _saveRecord() async {
  //   if (_isAllTextFileNoContent()) {
  //     return;
  //   }
  //   // 插入数据
  //   setState(() {
  //     _tabSeepageCollectModel.upstreamLineValue = double.parse(
  //         _upstreamLineController.text == ""
  //             ? "0"
  //             : _upstreamLineController.text);
  //     _tabSeepageCollectModel.downstreamLineValue = double.parse(
  //         _downstreamLineController.text == ""
  //             ? "0"
  //             : _downstreamLineController.text);
  //     _tabSeepageCollectModel.downstreamGapValue = double.parse(
  //         _downstreamGapController.text == ""
  //             ? "0"
  //             : _downstreamGapController.text);
  //     _tabSeepageCollectModel.isUpload = 0;
  //     _tabSeepageCollectModel.uploadTime = DateUtils.getCurrentTime();
  //   });
  //   await _tabSeepageCollectManager.insert(_tabSeepageCollectModel);
  // }

  // // 上传渗漏水采集数据
  // _uploadRecord() async {
  //   if (_isAllTextFileHasContent() == false) {
  //     CommonUtils.showTextToast("请输入后提交");
  //     return;
  //   }
  //   // 插入数据
  //   setState(() {
  //     _tabSeepageCollectModel.upstreamLineValue = double.parse(
  //         _upstreamLineController.text == ""
  //             ? "0"
  //             : _upstreamLineController.text);
  //     _tabSeepageCollectModel.downstreamLineValue = double.parse(
  //         _downstreamLineController.text == ""
  //             ? "0"
  //             : _downstreamLineController.text);
  //     _tabSeepageCollectModel.downstreamGapValue = double.parse(
  //         _downstreamGapController.text == ""
  //             ? "0"
  //             : _downstreamGapController.text);
  //     _tabSeepageCollectModel.upstreamLineId = new Uuid().v1();
  //     _tabSeepageCollectModel.downstreamLineId = new Uuid().v1();
  //     _tabSeepageCollectModel.downstreamGapId = new Uuid().v1();
  //     _tabSeepageCollectModel.isUpload = 1;
  //     _tabSeepageCollectModel.uploadTime = DateUtils.getCurrentTime();
  //   });
  //   await _tabSeepageCollectManager.insert(_tabSeepageCollectModel);
  //   // 上传数据
  //   // TODO: 上传数据
  // }

  // // 是否所有文本框都没有内容
  // _isAllTextFileNoContent() {
  //   if (_upstreamLineController.text != "") {
  //     return false;
  //   }
  //   if (_downstreamLineController.text != "") {
  //     return false;
  //   }
  //   if (_downstreamGapController.text != "") {
  //     return false;
  //   }
  //   return true;
  // }

  // 是否所有文本框都有内容
  // _isAllTextFileHasContent() {
  //   if ((_upstreamLineController.text == "" ||
  //           _downstreamLineController.text == "" ||
  //           _downstreamGapController.text == "") ||
  //       (_upstreamLineController.text == "0" ||
  //           _downstreamLineController.text == "0" ||
  //           _downstreamGapController.text == "0")) {
  //     return false;
  //   } else {
  //     return true;
  //   }
  // }
}
