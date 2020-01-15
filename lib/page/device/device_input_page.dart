import 'dart:convert';
import 'dart:ui'; //引入ui库，因为ImageFilter Widget在这个里边。

import 'package:flutter/material.dart';

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

class DeviceInputPage extends StatefulWidget {
  final TabDeviceRecordModel taskRecordModel;
  final String title;

  DeviceInputPage(this.taskRecordModel, this.title);

  @override
  State<StatefulWidget> createState() =>
      DeviceInputPageState(this.taskRecordModel);
}

class DeviceInputPageState extends State<DeviceInputPage> {
  // TabDeviceRecordModel _taskRecordModel;
  // String _title;

  TextEditingController _contentController = TextEditingController();
  FocusNode _focusNode = FocusNode();

  TabDeviceRecordModel _taskRecordModel;
  DeviceInputPageState(this._taskRecordModel);

  bool isShowSaveAndUploadBtn = true; // 是否显示保存和上传按钮

  @override
  void initState() {
    _initData();

    super.initState();
  }

  _initData() {
    if (_taskRecordModel.abnormalExplain != null) {
      _contentController.text = _taskRecordModel.abnormalExplain;
    }

    if (_taskRecordModel.isUpload == 1) {
      isShowSaveAndUploadBtn = false;
    } else {
      isShowSaveAndUploadBtn = true;
    }
    print('record type $_taskRecordModel');
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
                              _saveInputRecord(true, 0);
                            },
                            child: Padding(
                                padding: EdgeInsets.all(15),
                                child: Text("保存",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: FontConfig.titleTextSize)))))
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
            Container(
                margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(right: 10),
                          child: Image.asset('images/ic_input.png',
                              height: 23, width: 23)),
                      Text("录入:",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: const Color(ColorConfig.darkTextColor),
                              fontSize: FontConfig.titleTextSize))
                    ])),
            _getTextField(_contentController, _focusNode),
          ])),
          floatingActionButton: isShowSaveAndUploadBtn
              ? FloatingActionButton(
                  heroTag: 'device_input_page_btn',
                  onPressed: _uploadInputRecord,
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

  _getTextField(TextEditingController controller, FocusNode focusNode) {
    return Container(
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(
            border:
                Border.all(color: Color(ColorConfig.borderColor), width: 0.5),
            borderRadius: BorderRadius.circular(3)),
        child: TextField(
            controller: controller,
            enabled: isShowSaveAndUploadBtn,
            // inputFormatters: [
            //   WhitelistingTextInputFormatter(
            //       RegExp("[a-zA-Z]|[\u4e00-\u9fa5]|[0-9]")), //只能输入汉字或者字母或数字
            //   LengthLimitingTextInputFormatter(200), //最大长度
            // ],
            maxLength: 200,
            focusNode: focusNode,
            style: TextStyle(
                color: const Color(ColorConfig.darkTextColor),
                fontSize: FontConfig.contentTextSize),
            maxLines: 6,
            decoration: InputDecoration(
                hintText: "请输入信息",
                contentPadding: const EdgeInsets.all(5.0),
                border: InputBorder.none),
            // 当value改变的时候，触发
            onChanged: (val) {
//                                                  print(val);
            }));
  }

  // 保存温湿度巡查内容
  _saveInputRecord(bool isShowToast, int isUpload) async {
    if (_checkNeedSave() == false) {
      CommonUtils.showTextToast("无需要保存的内容");
      return;
    }

    Map userinfoMap = await UserinfoUtils.getUserInfo();
    _taskRecordModel.inspectorId = userinfoMap[Config.USER_ID];
    _taskRecordModel.inspectorName = userinfoMap[Config.USER_REALNAME];
    _taskRecordModel.recordType = 7; // 不要忘记
    _taskRecordModel.abnormalExplain = _contentController.text;
    _taskRecordModel.time = DateUtils.getCurrentTime();
    _taskRecordModel.isUpload = isUpload;

    print('DeviceInputPage insert $_taskRecordModel');

    await TabDeviceRecordManager().insert(_taskRecordModel);

    if (isShowToast) {
      CommonUtils.showTextToast("保存成功");
    }
  }

  // 上传前检查内容
  _checkAbnormalRecord() {
    if (_contentController.text.length == 0) {
      CommonUtils.showCenterTextToast('请填写录入信息');
      return false;
    }

    return true;
  }

  // 保存前检查上传内容
  _checkNeedSave() {
    if (_contentController.text.length == 0) {
      return false;
    }
    return true;
  }

  // 上传input巡查内容
  _uploadInputRecord() async {
    // 先检查上传内容
    if (_checkAbnormalRecord() == false) return;

    CommonUtils.showLoadingDialog(
        context, '努力上传中...', SpinKitType.SpinKit_Circle);

    /*
     * 保存录入数据
     */
    Map userinfoMap = await UserinfoUtils.getUserInfo();
    _taskRecordModel.inspectorId = userinfoMap[Config.USER_ID];
    _taskRecordModel.inspectorName = userinfoMap[Config.USER_REALNAME];
    _taskRecordModel.abnormalExplain = _contentController.text;
    _taskRecordModel.recordType = 7; // 不要忘记
    _taskRecordModel.isOpen = 0; // 不要忘记

    print('record type ${_taskRecordModel.recordState}');

    String cjsj = json.encode(_taskRecordModel.toJson()); // 录入
    print('input：' + cjsj);
    DataResult uploadDataResult = await NetUtils.uploadToNet(
        Address.saveRCXCCJSJ(), {'cjsj': cjsj, 'picids': ''});

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
    await _saveInputRecord(false, 1);

    CommonUtils.showAlertDialog(context, '温馨提示', "数据上传成功", () {}).then((_) {
      Navigator.pop(context);
    });
  }
}
