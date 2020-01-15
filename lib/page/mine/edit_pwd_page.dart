import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/utils/string_utils.dart';
import 'package:mdc_bhl/utils/net_utils.dart';
import 'package:mdc_bhl/utils/common_utils.dart';
import 'package:mdc_bhl/common/config/style.dart';

import 'package:mdc_bhl/common/net/address.dart';
import 'package:mdc_bhl/model/data_result.dart';

import 'package:mdc_bhl/widget/gradient_appbar.dart';

class EditPwdPage extends StatefulWidget {
  EditPwdPage({Key key}) : super(key: key);

  _EditPwdPageState createState() => _EditPwdPageState();
}

class _EditPwdPageState extends State<EditPwdPage> {
  String _userName = '';

  @override
  void initState() {
    _initParams(); //初始化参数

    super.initState();
  }

  //初始化参数，获取用户名
  _initParams() async {
    _userName = await LocalStorage.get(Config.USER_NAME_KEY);
  }

  // 更新密码
  Future<DataResult> _updatePassword() async {
    Map<String, String> parameter = {
      'userName': _userName,
      'oldPwd': StringUtils.generateMd5(_oldPwController.text).toUpperCase(),
      'newPwd': StringUtils.generateMd5(_newPwController.text).toUpperCase(),
    };

    DataResult dataResult =
        await NetUtils.getFromNet(Address.changePwd(), parameter);
    if (dataResult.result) {
      LocalStorage.save(Config.PW_KEY, _newPwController.text);

      return DataResult('更新密码成功', true);
    } else {
      return DataResult(null, false, description: dataResult.description);
    }
  }

  // 利用FocusNode和_focusScopeNode来控制焦点 可以通过FocusNode.of(context)来获取widget树中默认的_focusScopeNode
  FocusNode _oldpasswordFocusNode = new FocusNode();
  FocusNode _newpasswordFocusNode = new FocusNode();
  FocusNode _newpasswordFocusNode2 = new FocusNode(); // 确认密码

  FocusScopeNode _focusScopeNode = new FocusScopeNode();

  final TextEditingController _oldPwController = new TextEditingController();
  final TextEditingController _newPwController = new TextEditingController();
  final TextEditingController _newPwController2 = new TextEditingController();

  GlobalKey _formKey = new GlobalKey<FormState>();

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
              title: new Text(
                '修改密码',
                style: TextStyle(fontSize: FontConfig.naviTextSize),
              )),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                  top: 40, bottom: 20, left: 40, right: 40),
              child: Form(
                key: _formKey, //设置globalKey，用于后面获取FormState
                child: Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5.0,
                              offset: Offset(1, 1), // 左上角为起点
                              spreadRadius: 2.0),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            autofocus: false,
                            controller: _oldPwController,
                            focusNode: _oldpasswordFocusNode,
                            style: TextStyle(
                                color: Color(ColorConfig.primaryDarkValue),
                                fontSize: 14),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "请输入原始密码",
                                hintStyle: TextStyle(color: Colors.grey[300]),
                                hasFloatingPlaceholder: true,
                                prefixIcon: IconButton(
                                    icon: Icon(Icons.lock_open,
                                        color: Colors.blueGrey),
                                    onPressed: null)),
                            onEditingComplete: () {
                              if (_focusScopeNode == null) {
                                _focusScopeNode = FocusScope.of(context);
                              }
                              _focusScopeNode
                                  .requestFocus(_newpasswordFocusNode);
                            },
                          ),

                          Divider(
                              height: 1.0,
                              color: Color(ColorConfig.subLightTextColor)),

                          // SizedBox(height: 10),
                          TextFormField(
                            autofocus: false,
                            controller: _newPwController,
                            focusNode: _newpasswordFocusNode,
                            style: TextStyle(
                                color: Color(ColorConfig.primaryDarkValue),
                                fontSize: 14),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "请输入新密码",
                                hintStyle: TextStyle(color: Colors.grey[300]),
                                hasFloatingPlaceholder: true,
                                prefixIcon: IconButton(
                                    icon: Icon(Icons.lock_outline,
                                        color: Colors.blueGrey),
                                    onPressed: null)),
                            onEditingComplete: () {
                              if (_focusScopeNode == null) {
                                _focusScopeNode = FocusScope.of(context);
                              }
                              _focusScopeNode
                                  .requestFocus(_newpasswordFocusNode2);
                            },
                          ),

                          Divider(
                              height: 1.0,
                              color: Color(ColorConfig.subLightTextColor)),

                          // SizedBox(height: 10),
                          TextFormField(
                            autofocus: false,
                            controller: _newPwController2,
                            focusNode: _newpasswordFocusNode2,
                            style: TextStyle(
                                color: Color(ColorConfig.primaryDarkValue),
                                fontSize: 14),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "请再次输入新密码",
                                hintStyle: TextStyle(color: Colors.grey[300]),
                                hasFloatingPlaceholder: true,
                                prefixIcon: IconButton(
                                    icon: Icon(Icons.lock,
                                        color: Colors.blueGrey),
                                    onPressed: null)),
                            onEditingComplete: () {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    // 登录按钮
                    Container(
                      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5.0,
                              offset: Offset(1, 1), // 左上角为起点
                              spreadRadius: 2.0),
                        ],
                        gradient: LinearGradient(
                            colors: [Color(0xFF2171F5), Color(0xFF49A2FC)]),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: FlatButton(
                              padding: EdgeInsets.all(0.0),
                              child: Text("保    存",
                                  style: TextStyle(fontSize: 18.0)),
                              color: Colors
                                  .transparent, // Theme.of(context).primaryColor,
                              textColor: Colors.white,
                              onPressed: () async {
                                if (_oldPwController.text.length == 0) {
                                  CommonUtils.showTextToast('请输入原始密码');
                                  return;
                                }
                                if (_newPwController.text.length == 0) {
                                  CommonUtils.showTextToast('请输入新密码');
                                  return;
                                }
                                if (_newPwController2.text.length == 0) {
                                  CommonUtils.showTextToast('请再次输入新密码');
                                  return;
                                }
                                if (_newPwController2.text !=
                                    _newPwController.text) {
                                  CommonUtils.showTextToast(
                                      '新密码和确认密码必须相同，请重新填写！');
                                  return;
                                }

                                // show Loading Dialog
                                CommonUtils.showLoadingDialog(context,
                                    '努力上传中...', SpinKitType.SpinKit_Circle);

                                // 验证通过，执行登陆操作
                                DataResult dataResult = await _updatePassword();

                                // hide Loading Dialog
                                Navigator.pop(context);

                                if (dataResult.result) {
                                  LocalStorage.save( Config.PW_KEY, _newPwController.text);
                                  // TODO：此处未修改useinfo的信息，主要考虑到工程均未用到此信息
                                  // CommonUtils.showTextToast('成功修改密码');
                                  CommonUtils.showAlertDialog( context, '温馨提示', "成功修改密码", () {}) .then((_) {
                                    Navigator.pop(context);
                                  });
                                  // Future.delayed(Duration(milliseconds: 2000),(){
                                  //   Navigator.pop(context);
                                  // });
                                } else {
                                  CommonUtils.showTextToast(
                                      dataResult.description);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
