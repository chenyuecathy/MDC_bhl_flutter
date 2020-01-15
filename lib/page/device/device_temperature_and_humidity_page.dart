import 'dart:convert';
import 'dart:ui'; //引入ui库，因为ImageFilter Widget在这个里边。

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/common/net/address.dart';
import 'package:mdc_bhl/db/tab_device_record_manager.dart';
import 'package:mdc_bhl/model/data_result.dart';
import 'package:mdc_bhl/utils/common_utils.dart';
import 'package:mdc_bhl/utils/date_utils.dart';
import 'package:mdc_bhl/utils/net_utils.dart';
import 'package:mdc_bhl/utils/userinfo_utils.dart';
import 'package:mdc_bhl/widget/gradient_appbar.dart';

class DeviceTemperatureAndHumidityPage extends StatefulWidget {
  final TabDeviceRecordModel taskRecordModel;
  final String title;

  DeviceTemperatureAndHumidityPage(this.taskRecordModel, this.title);

  @override
  State<StatefulWidget> createState() =>
      DeviceTemperatureAndHumidityPageState(this.taskRecordModel);
}

class DeviceTemperatureAndHumidityPageState
    extends State<DeviceTemperatureAndHumidityPage> {
  TabDeviceRecordModel _taskRecordModel;
  DeviceTemperatureAndHumidityPageState(this._taskRecordModel);

  TextEditingController _temperatureController = TextEditingController();
  FocusNode _temperatureFocusNode = FocusNode();
  TextEditingController _humidityController = TextEditingController();
  FocusNode _humidityFocusNode = FocusNode();

  // DeviceTemperatureAndHumidityPageState(this._taskRecordModel, this._title);

  bool isShowSaveAndUploadBtn = true; // 是否显示保存和上传按钮

  @override
  void initState() {
    _initData();

    super.initState();
  }

  _initData() {
    if (_taskRecordModel.temperature != null) {
      _temperatureController.text = _taskRecordModel.temperature;
    }
    if (_taskRecordModel.humidity != null) {
      _humidityController.text = _taskRecordModel.humidity;
    }

    if (_taskRecordModel.isUpload == 1) {
      isShowSaveAndUploadBtn = false;
    } else {
      isShowSaveAndUploadBtn = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        /// 通过GestureDetector捕获点击事件，再通过FocusScope将焦点转移至空焦点—— FocusNode()
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
          appBar: GradientAppBar(
              gradientStart: Color(0xFF2171F5),
              gradientEnd: Color(0xFF49A2FC),
              centerTitle: true,
              title: Text(widget.title,
                  style: TextStyle(fontSize: FontConfig.naviTextSize)),
              leading: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.pop(context, "未保存");
                  },
                  child: Icon(Icons.chevron_left, size: 30)),
              actions: <Widget>[
                isShowSaveAndUploadBtn
                    ? Center(
                        child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              _saveWSDRecord(true, 0);
                            },
                            child: Padding(
                                padding: EdgeInsets.all(15),
                                child: Text("保存",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)))))
                    : Container()
              ]),
          body: SingleChildScrollView(
              child: Column(children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                // BackdropFilter(
                //     //背景滤镜器
                //     filter: ImageFilter.blur(
                //         sigmaX: 5.0, sigmaY: 5.0), //图片模糊过滤，横向竖向都设置5.0
                //     child: Opacity(
                //       //透明控件
                //       opacity: 0.5,
                // child:
                Image.asset('images/ic_task_bg.jpg',
                    height: 65,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fill),
                Container(
                    padding: EdgeInsets.fromLTRB(20, 3, 20, 3),
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(_taskRecordModel.recordTitle,
                            style: TextStyle(
                                color: const Color(ColorConfig.borderColor),
                                fontWeight: FontWeight.bold,
                                fontSize: FontConfig.normalTextSize))
                      ],
                    ))
              ],
            ),
            SizedBox(height: 20),
            _layoutTextField("温度:", "°C", "images/ic_temperature.png",
                _temperatureController, _temperatureFocusNode),
            _layoutTextField("湿度:", "%", "images/ic_humidity.png",
                _humidityController, _humidityFocusNode),
          ])),
          floatingActionButton: isShowSaveAndUploadBtn
              ? FloatingActionButton(
                  heroTag: 'report_btn',
                  onPressed: _uploadWSDRecord,
                  tooltip: '提交',
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.file_upload),
                        Text("提交", style: TextStyle(fontSize: 10))
                      ]))
              : null),
    );
  }

  _layoutTextField(String title, String unit, String icon,
      TextEditingController controller, FocusNode focusNode) {
    return Container(
        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
        child: Row(children: <Widget>[
          Container(
              margin: EdgeInsets.only(right: 10),
              child: Image.asset(icon, height: 30, width: 30)),
          Center(
              child: Text(title,
                  style: TextStyle(
                      color: const Color(ColorConfig.darkTextColor),
                      fontSize: FontConfig.titleTextSize))),
          Expanded(
              child: Container(
                  margin: EdgeInsets.only(left: 20, right: 10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Color(ColorConfig.borderColor), width: 0.5),
                      borderRadius: BorderRadius.circular(3)),
                  child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      enabled: isShowSaveAndUploadBtn,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                          color: const Color(ColorConfig.darkTextColor),
                          fontSize: FontConfig.contentTextSize),
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter(
                            RegExp("[0-9.]")), // 只输入数字（有小数）
                          //  WhitelistingTextInputFormatter.digitsOnly, // 只输入数字（无小数）
                      ],
                      decoration: InputDecoration(
                          hintText:
                              "请输入" + title.substring(0, title.length - 1),
                          contentPadding: const EdgeInsets.all(5.0),
                          border: InputBorder.none),
                      // 当value改变的时候，触发
                      onChanged: (val) {
//                                                  print(val);
                      })),
              flex: 3),
          Text(unit,
              style: TextStyle(
                  color: const Color(ColorConfig.darkTextColor),
                  fontSize: FontConfig.contentTextSize)),
        ]));
  }

  // 保存温湿度巡查内容
  _saveWSDRecord(bool isShowToast, int isUpload) async {
    if (_checkNeedSave() == false) {
      CommonUtils.showTextToast("无需要保存的内容");
      return;
    }

    Map userinfoMap = await UserinfoUtils.getUserInfo();
    _taskRecordModel.inspectorId = userinfoMap[Config.USER_ID];
    _taskRecordModel.inspectorName = userinfoMap[Config.USER_REALNAME];
    _taskRecordModel.recordType = 6;
    _taskRecordModel.humidity = _humidityController.text;
    _taskRecordModel.temperature = _temperatureController.text;
    _taskRecordModel.time = DateUtils.getCurrentTime();
    _taskRecordModel.isUpload = isUpload;

    print(
        'DeviceTemperatureAndHumidityPage insert method $_taskRecordModel');

    await TabDeviceRecordManager().insert(_taskRecordModel);

    if (isShowToast) {
      CommonUtils.showTextToast("保存成功");
    }
  }

  // 上传前检查内容
  _checkAbnormalRecord() {
    if (_temperatureController.text.length == 0) {
      CommonUtils.showCenterTextToast('请填写温度');
      return false;
    }
    if (_humidityController.text.length == 0) {
      CommonUtils.showCenterTextToast('请填写湿度');
      return false;
    }

    var temperature = double.parse(_temperatureController.text) ;
    var humidity = double.parse(_humidityController.text) ;
    if (!(temperature is double)) {
      CommonUtils.showCenterTextToast('温度输入格式有误');
      return false;
    }
    if (!(humidity is double)) {
      CommonUtils.showCenterTextToast('湿度输入格式有误');
      return false;
    }

    return true;
  }

  // 保存前检查上传内容
  _checkNeedSave() {
    if (_temperatureController.text.length == 0 &&
        _humidityController.text.length == 0) {
      return false;
    }
    return true;
  }

  // 上传巡查内容
  _uploadWSDRecord() async {
    // 先检查上传内容
    if (_checkAbnormalRecord() == false) return;

    CommonUtils.showLoadingDialog(
        context, '努力上传中...', SpinKitType.SpinKit_Circle);

    /*
     * 保存温湿度数据
     */
    Map userinfoMap = await UserinfoUtils.getUserInfo();
    _taskRecordModel.inspectorId = userinfoMap[Config.USER_ID];
    _taskRecordModel.inspectorName = userinfoMap[Config.USER_REALNAME];
    _taskRecordModel.temperature = _temperatureController.text;
    _taskRecordModel.humidity = _humidityController.text;
    _taskRecordModel.recordType = 6; // 不要忘记
    _taskRecordModel.isOpen = 0; // 不要忘记

    String wsd = json.encode(_taskRecordModel.toJson()); // 温湿度
    print('wsd：' + wsd);
    DataResult uploadDataResult =
        await NetUtils.uploadToNet(Address.saveWSD(), {'wsd': wsd});

    Navigator.pop(context); // hide loading dialog

    if (uploadDataResult.result) {
      // CommonUtils.showTextToast("数据上传成功");
    } else {
      CommonUtils.showTextToast(uploadDataResult.description);
      return;
    }

    /**
     * 数据库存储（修改数据库中 图片网络地址、是否上传、上传时间）
     */
    _taskRecordModel.isUpload = 1;
    _taskRecordModel.time = DateUtils.getCurrentTime();
    await _saveWSDRecord(false, 1);

    CommonUtils.showAlertDialog(context, '温馨提示', "数据上传成功", () {}).then((_) {
      Navigator.pop(context);
    });
  }
}
