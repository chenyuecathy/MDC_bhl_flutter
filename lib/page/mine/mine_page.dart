import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/model/user_info.dart';

import 'package:mdc_bhl/page/about_us/about_us_page.dart';
import 'package:mdc_bhl/page/login/login_page.dart';
import 'package:mdc_bhl/page/mine/personal_central_page.dart';
import 'package:mdc_bhl/page/mine/setting_page.dart';
import 'package:mdc_bhl/page/record/collect/my_collect_list_home_page.dart';
import 'package:mdc_bhl/page/record/report/my_report_list_page.dart';
import 'package:mdc_bhl/page/record/task/my_task_list_device_home_page.dart';
import 'package:mdc_bhl/page/record/task/my_task_list_guard_page.dart';
import 'package:mdc_bhl/page/record/task/my_task_list_office_page.dart';
import 'package:mdc_bhl/page/task/task_calendar_page.dart';

import 'package:mdc_bhl/utils/common_utils.dart';
import 'package:mdc_bhl/utils/data_utils.dart';
import 'package:mdc_bhl/utils/userinfo_utils.dart';
import 'package:url_launcher/url_launcher.dart';

const double Icon_size = 20;

class MinePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MinePageState();
}

class MinePageState extends State<MinePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List items = [];

  List systemItems = [
    {Config.ITEM_ICON: 'images/ic_mine_setting.png', Config.ITEM_TITLE: '系统设置'},
    {Config.ITEM_ICON: 'images/ic_mine_about.png', Config.ITEM_TITLE: '关于我们'},
    {Config.ITEM_ICON: 'images/ic_mine_upgrade.png', Config.ITEM_TITLE: '检查更新'},
  ];

  Map<String, dynamic> _userInfo;
  String _avator =
      'http://172.16.103.18:1322/12//8b078637-eca3-4784-819c-6fdaf68cefd6.jpg';
  String _name = '';
  String _realname = '';
  String _userId = '';
  String _department = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('didChangeDependencies');
  }

  @override
  void didUpdateWidget(oldWidget) {
    print('didUpdateWidget');
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    print('deactivate');
    super.deactivate();
  }

  @override
  void initState() {
    print('initState');

    super.initState();
    _getUserInfo();
  }

  _getUserInfo() async {
    String userinfoString = await LocalStorage.get(Config.USER_INFO_KEY);

    setState(() {
      _userInfo = json.decode(userinfoString);
      _avator = _userInfo['PHOTOPATH'];
      print('avator:$_avator');
      _name = _userInfo['NAME'];
      _realname = _userInfo['REALNAME'];
      _userId = _userInfo['ID'];
      _department = _userInfo['DWID'];
    });

    if (_department == Config.DEPARTMENT_ID_OFFICE) {
      items = [
        { Config.ITEM_ICON: 'images/ic_mine_task.png', Config.ITEM_TITLE: '任务记录' },
        { Config.ITEM_ICON: 'images/ic_mine_collect.png', Config.ITEM_TITLE: '采集记录' },
        { Config.ITEM_ICON: 'images/ic_mine_report.png', Config.ITEM_TITLE: '异常记录' }, ];
    } else {
      items = [
        { Config.ITEM_ICON: 'images/ic_mine_task.png', Config.ITEM_TITLE: '任务记录' },
        { Config.ITEM_ICON: 'images/ic_mine_collect.png', Config.ITEM_TITLE: '采集记录' },
        { Config.ITEM_ICON: 'images/ic_mine_report.png', Config.ITEM_TITLE: '异常记录' },
        { Config.ITEM_ICON: 'images/ic_mine_calender.png', Config.ITEM_TITLE: '任务日历' }, ];
    }
  }

  _checkUpdate() {
    // 检查更新
    CommonUtils.showLoadingDialog(context, '', SpinKitType.SpinKit_Circle);
    DataUtils.checkVersion({}).then((VersionResult result) {
      Navigator.pop(context); // hide loading dialog
      if (result.update) {
        CommonUtils.showMultiAlertDialog(
            context,
            '发现新版本${result.versionData.buildVersion}',
            '${result.versionData.buildUpdateDescription}',
            ['现在更新', '稍后更新']).then((index) async {
          if (index == 0) {
            String currUrl = result.versionData.buildShortcutUrl;
            if (await canLaunch(currUrl)) {
              await launch(currUrl);
            } else {
              throw 'Could not launch $currUrl';
            }
          }
        });
      } else {
        CommonUtils.showTextToast('当前已是最新版本');
      }
    }).catchError((onError) {
      Navigator.pop(context); // hide loading dialog
      print('获取失败:$onError');
    });
  }

  // 列表项
  Widget _buildListItem(BuildContext context, int index) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Image.asset(items[index][Config.ITEM_ICON],
                width: Icon_size, height: Icon_size),
            onTap: () {
              if (index == 0) {
                // 任务记录
                if (_department == Config.DEPARTMENT_ID_OFFICE) {
                  // 办公室
                  Navigator.push( context, MaterialPageRoute( builder: (BuildContext context) => MyTaskListOfficePage(_userId)));
                } else if (_department == Config.DEPARTMENT_ID_DEVICE) {
                  // 设备科
                  Navigator.push( context, MaterialPageRoute( builder: (BuildContext context) => MyTaskListDeviceHomePage(_userId)));
                } else if (_department == Config.DEPARTMENT_ID_GUARD) {
                  // 保卫科
                  Navigator.push( context, MaterialPageRoute( builder: (BuildContext context) => MyTaskListGuardPage(_userId)));
                }
              } else if (index == 1) {
                // 采集记录
                Navigator.push( context, MaterialPageRoute( builder: (BuildContext context) => MyCollectListHomePage()));
              } else if (index == 2) {
                //异常记录
                Navigator.push( context, MaterialPageRoute( builder: (BuildContext context) => MyReportListPage()));
              } else {
                // 任务日历
                DepartmentTaskType type = DepartmentTaskType.Device;
                if (_department == Config.DEPARTMENT_ID_GUARD) {
                  type = DepartmentTaskType.Guard;
                }
                Navigator.push( context, MaterialPageRoute( builder: (BuildContext context) => TaskCalendarPage(type)));
              }
            },
            title: Text(items[index][Config.ITEM_TITLE],
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.black, fontSize: 15.0)),
            trailing: Icon(Icons.keyboard_arrow_right,
                color: Colors.grey, size: 20.0),
          ),
          new Divider(
            height: 1.0,
          )
        ],
      ),
    );
  }

  // 列表项
  Widget _buildSystemListItem(BuildContext context, int index) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Image.asset(systemItems[index][Config.ITEM_ICON], width: Icon_size, height: Icon_size),
            onTap: () {
              if (index == 0) {
                //系统设置
                Navigator.push( context, MaterialPageRoute( builder: (BuildContext context) => SettingPage()));
              } else if (index == 1) {
                // 关于我们
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) { return AboutUsPage(); }));
              } else {
                _checkUpdate();
              }
            },
            title: Text(systemItems[index][Config.ITEM_TITLE],
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.black, fontSize: 15.0)),
            trailing: Icon(Icons.keyboard_arrow_right, color: Colors.grey, size: 20.0),
          ),
          new Divider(
            height: 1.0,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              height: 280,
              color: Colors.white,
              child: Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: <Widget>[
                  Image.asset('images/ic_mine_bg.png',
                      height: 280,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ///用户头像
                      RawMaterialButton(
                        onPressed: () {
                          if (_userInfo != null) {
                            // 个人中心页
                            Navigator.push( context, MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        PersonalCentralPage(_userInfo, (newAvatorURL) {
                                          setState(() {
                                            _avator = newAvatorURL;
                                          });
                                        })));
                          }
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5.0,
                                  offset: Offset(1, 1), // 左上角���起点
                                  spreadRadius: 2.0),
                            ],
                          ),
                          child: ClipOval(
                              // child: FadeInImage.assetNetwork(
                              //   placeholder: IConConfig.DEFAULT_USER_ICON,
                              //   fit: BoxFit.cover,
                              //   image:_avator??IConConfig.DEFAULT_REMOTE_PIC,
                              //   width: 80.0,
                              //   height: 80.0,
                              // ),
                              child: CachedNetworkImage(
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.fill,
                                  imageUrl: _avator,
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Icon(Icons.person))),
                        ),
                      ),

                      SizedBox(height: 10),
                      Text(_realname == null ? '' : _realname,
                          style: TextStyle(
                              color: const Color(ColorConfig.primaryDarkValue),
                              fontSize: 20.0)),
                      Text(_name == null ? '' : _name,
                          style: TextStyle(
                              color: const Color(ColorConfig.subTextColor),
                              fontSize: 14.0)),
                      // SizedBox(height: 20),
                    ],
                  )
                ],
              ),
            ),
          ),
          SliverFixedExtentList(
            delegate: SliverChildBuilderDelegate(_buildListItem,
                childCount: items.length),
            itemExtent: 57.0, //不能少于57
          ),
          SliverToBoxAdapter(
              child: Column(
            children: <Widget>[
              SizedBox(height: 20),
              Divider(height: 1.0),
            ],
          )),
          SliverFixedExtentList(
            delegate: SliverChildBuilderDelegate(_buildSystemListItem,
                childCount: systemItems.length),
            itemExtent: 57.0, //不能少于57
          ),
          SliverToBoxAdapter(
              child: Column(
            children: <Widget>[
              SizedBox(height: 20),
              Divider(height: 1.0),
              Container(
                color: Colors.white,
                child: ListTile(
                  leading: Image.asset('images/icon_mine_logout.png',
                      width: Icon_size, height: Icon_size),
                  onTap: goToLoginPage, // 点击事件
                  title: Text('安全退出',
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.black, fontSize: 15.0)),
                  trailing: Icon(Icons.keyboard_arrow_right,
                      color: Colors.grey, size: 20.0),
                ),
              ),
              Divider(height: 1.0),
            ],
          ))
        ],
      ),
    );
  }

  void goToLoginPage() async {
    /// erase login data from disk before navigator to login page
    await LocalStorage.remove(Config.USER_NAME_KEY);
    await LocalStorage.remove(Config.PW_KEY);
    await LocalStorage.remove(Config.USER_INFO_KEY);
    await LocalStorage.remove(Config.USER_DEPARTMENT_ID).then((_) {
      /// 跳转登录页 且销毁当前页面
      Navigator.of(context).pushAndRemoveUntil(
          new MaterialPageRoute(builder: (context) => new LoginPage()),
          (Route<dynamic> rout) => false);
    }).catchError((e) {
      CommonUtils.showTextToast('退出失败，请稍后重试');
    });
  }
}
