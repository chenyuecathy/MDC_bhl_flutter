import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:mdc_bhl/page/tabbar_bottom_page.dart';

import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/net/address.dart';

import 'package:mdc_bhl/utils/common_utils.dart';
import 'package:mdc_bhl/utils/net_utils.dart';
import 'package:mdc_bhl/utils/string_utils.dart';

import 'package:mdc_bhl/model/data_result.dart';
import 'package:mdc_bhl/icon/custom_icons.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 利用FocusNode和_focusScopeNode来控制焦点 可以通过FocusNode.of(context)来获取widget树中默认的_focusScopeNode
  FocusNode _userFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  FocusScopeNode _focusScopeNode = FocusScopeNode();

  final TextEditingController _userController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  GlobalKey _formKey = GlobalKey<FormState>();

  String _userName = '';
  String _password = '';

  bool _obsecure = true;

  bool _tip = false;

  @override
  void initState() {
    super.initState();

    // pwController.addListener(() => setState(() => {}));
    // userController.addListener(() => setState(() => {}));

    initParams();
  }

  initParams() async {
    _userName = await LocalStorage.get(Config.USER_NAME_KEY);
    _password = await LocalStorage.get(Config.PW_KEY);
    _userController.value = TextEditingValue(text: _userName ?? "");
    _pwController.value = TextEditingValue(text: _password ?? "");
  }

  /// 获取任务数据
  Future _fetchUserInfoFromNet([Map<String, dynamic> params]) async {
    String account = _userController.text.trim();
    String pwd = _pwController.text.trim();

    /// save login name and password
    await LocalStorage.save(Config.USER_NAME_KEY, account);
    await LocalStorage.save(Config.PW_KEY, pwd);

    Map<String, String> parameter = {'userName': account, 'pwd': StringUtils.generateMd5(pwd).toUpperCase()};

    DataResult dataResult = await NetUtils.getFromNet(Address.doLogin(), parameter);
    // DWID是单位id【办公室、保卫科、设备科】，ID是用户id，RoleIDS是角色id【馆领导、科室领导、巡查员、数据管理员】
    // DataResult{data: {NAME: cheny, REALNAME: 陈玥, DWName: 办公室, DWID: 4ba42b9f-7caf-4847-ac2f-933ffe8f9812, ID: 1c041b9e-11fd-4130-b6de-cbba0e9f1e01, RoleIDS: a5fc51c9-b4f1-4280-8713-d5a3f9d9c60a, ROLENAME: 科室领导, MOBILE: 18311038236, PHOTOPATH: http://123.146.225.94:971012//b2b2786c-3318-4af1-ab04-f1f25af80a51.png, Token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxYzA0MWI5ZS0xMWZkLTQxMzAtYjZkZS1jYmJhMGU5ZjFlMDEiLCJhdXRoX3RpbWUiOiIyMDE5MTExOTIxNTUyIiwiZXhwIjoxNTc0MTQ1OTUyLCJpc3MiOiJBbnkiLCJhdWQiOiJBbnkifQ.Whz-5obcZ7DDgxVKFvE1oQHHRBOwLZdueBEd0gmRfPI, RefreshToken: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxYzA0MWI5ZS0xMWZkLTQxMzAtYjZkZS1jYmJhMGU5ZjFlMDEiLCJhdXRoX3RpbWUiOiIyMDE5MTExOTIxMzUyIiwiZXhwIjoxNTc0MTUxMzUyLCJpc3MiOiJBbnkiLCJhdWQiOiJBbnkifQ.dYveIew9DmSHl4z9rE1AOXYf5jU65y31SG7-k4za0iU}
    //            , result: true
    //            , description: 获取数据成功
    //            , next: null}

    if (dataResult.result) {
      Map<String, dynamic> mapUserInfo = dataResult.data;
      String userInfoString = json.encode(mapUserInfo);
      LocalStorage.save(Config.USER_INFO_KEY, userInfoString); // save useInfo data in disk
      LocalStorage.save(Config.USER_DEPARTMENT_ID, mapUserInfo[Config.USER_DWID]); // save use department id in disk

      return DataResult(mapUserInfo[Config.USER_DWID], true);
    } else {
      await LocalStorage.remove(Config.USER_INFO_KEY); // remove useInfo data
      await LocalStorage.remove(Config.USER_DEPARTMENT_ID); // remove use department id in disk

      return DataResult(null, false, description: dataResult.description);
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
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('images/ic_login_bg.png'), fit: BoxFit.cover),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 45.0),
          child: Center(
            child: SafeArea(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey, //设置globalKey，用于后面获取FormState
                  autovalidate: true, //开启自动校验
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      // 标题
                      // Text("白鹤梁监测云",
                      //     style: TextStyle(
                      //         color: Colors.black,
                      //         fontSize: 35,
                      //         fontWeight: FontWeight.bold)),

                      // Column(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   mainAxisSize: MainAxisSize.min,
                      //   children: <Widget>[
                      SizedBox(height: 80),
                      // 输入框
                      Container(
                          padding: const EdgeInsets.fromLTRB(0, 50, 0, 50),
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                autofocus: false,
                                controller: _userController,
                                focusNode: _userFocusNode,
                                style: TextStyle(color: Colors.white),
                                cursorColor: Colors.white24,
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide(color: Colors.white, width: 1.0)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(3), borderSide: BorderSide(color: Colors.white, width: 1.0)),
                                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(3), borderSide: BorderSide(color: Colors.white, width: 1.0)),
                                    focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2.0)),
                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2.0)),
                                    // labelText: "用户名",
                                    // labelStyle:TextStyle(color: Colors.white54),
                                    hintText: "请输入用户名",
                                    hintStyle: TextStyle(color: Colors.grey[300]),
                                    // filled: true,
                                    // fillColor: Colors.white,
                                    hasFloatingPlaceholder: true,
                                    // errorText: '',
                                    prefixIcon: IconButton(icon: Icon(Icons.person, color: Colors.white), onPressed: null)),
                                validator: (v) {
                                  return v.trim().length > 0 ? null : _tip ? "用户名不能为空" : null;
                                },
                                onEditingComplete: () {
                                  if (_focusScopeNode == null) {
                                    _focusScopeNode = FocusScope.of(context);
                                  }
                                  _focusScopeNode.requestFocus(_passwordFocusNode);
                                },
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                controller: _pwController,
                                focusNode: _passwordFocusNode,
                                style: TextStyle(color: Colors.white),
                                cursorColor: Colors.white24,
                                //光标颜色
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide(color: Colors.white, width: 1.0)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(3), borderSide: BorderSide(color: Colors.white, width: 1.0)),
                                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(3), borderSide: BorderSide(color: Colors.white, width: 1.0)),
                                    focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2.0)),
                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2.0)),
                                    // labelText: "密码",
                                    // labelStyle:TextStyle(color: Colors.white54),
                                    // errorText: '',
                                    hintText: "请输入登录密码",
                                    hintStyle: TextStyle(color: Colors.grey[300]),
                                    suffixIcon: IconButton(
                                        icon: _obsecure ? Icon(CustomIcons.eye, color: Colors.white) : Icon(CustomIcons.eye_off, color: Colors.white),
                                        onPressed: () {
                                          setState(() {
                                            _obsecure = !_obsecure;
                                          });
                                        }),
                                    prefixIcon: IconButton(icon: Icon(Icons.lock, color: Colors.white), onPressed: null)),
                                obscureText: _obsecure,
                                validator: (v) {
                                  return v.trim().length > 0 ? null : _tip ? "密码不能为空" : null;
                                },
                                autofocus: false,
                              ),
                              SizedBox(height: 15)
                            ],
                          )),
                      // 登录按钮
                      Container(
                        padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.0),
                          gradient: LinearGradient(colors: [Color(0xFF2171F5), Color(0xFF49A2FC)]),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: FlatButton(
                                padding: EdgeInsets.all(10.0),
                                child: Text("登      录", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700)),
                                color: Colors.transparent,
                                // Theme.of(context).primaryColor,
                                textColor: Colors.white,
                                onPressed: () async {
                                  setState(() {
                                    _tip = true;
                                  });

                                  if ((_formKey.currentState as FormState).validate()) {
                                    // show Loading Dialog
                                    CommonUtils.showLoadingDialog(context, '登录中...', SpinKitType.SpinKit_CubeGrid);

                                    // 验证通过，执行登陆操作
                                    DataResult dataResult = await _fetchUserInfoFromNet();

                                    // hide Loading Dialog
                                    Navigator.pop(context);

                                    if (dataResult.result) {
                                      String dwId = dataResult.data;
                                      // 跳转主页 且销毁当前页面
                                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => TabBarBottomPage(dwId)), (Route<dynamic> rout) => false);
                                    } else {
                                      CommonUtils.showTextToast(dataResult.description);
                                    }
                                  } else {
                                    CommonUtils.showTextToast("用户名或密码不能为空！");
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                    //   ),
                    // ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
