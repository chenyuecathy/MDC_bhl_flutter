import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mdc_bhl/common/local/local_storage.dart';

import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/config/style.dart';

import 'package:mdc_bhl/utils/common_utils.dart';
import 'package:mdc_bhl/utils/net_utils.dart';
import 'package:mdc_bhl/utils/image_utils.dart' as image_utils;
import 'package:mdc_bhl/widget/gradient_appbar.dart';

import 'package:mdc_bhl/common/net/address.dart';
import 'package:mdc_bhl/model/data_result.dart';

import 'package:mdc_bhl/page/mine/edit_pwd_page.dart';


class PersonalCentralPage extends StatefulWidget {
  final Map<String, dynamic> useInfoMap;
  final ValueChanged<String> onAvatorChange;

  PersonalCentralPage(this.useInfoMap, this.onAvatorChange);

  @override
  State<StatefulWidget> createState() => new PersonalCentralPageState(this.useInfoMap);
}

class PersonalCentralPageState extends State<PersonalCentralPage> {
  Map<String, dynamic> _useInfoMap;
  String _avatorURL;
  // Map<String, dynamic> _newUseInfoMap; // 暂且未用到

  List items = [
    {
      Config.ITEM_ICON: 'images/ic_mine_task.png',
      Config.ITEM_TITLE: '头像',
      Config.ITEM_CONTENT: ''
    },
    {
      Config.ITEM_ICON: 'images/ic_mine_setting.png',
      Config.ITEM_TITLE: '真实姓名  ',
      Config.ITEM_CONTENT: 'REALNAME'
    },
    {
      Config.ITEM_ICON: 'images/ic_mine_about.png',
      Config.ITEM_TITLE: '用户名 ',
      Config.ITEM_CONTENT: 'NAME'
    },
    {
      Config.ITEM_ICON: 'images/ic_mine_about.png',
      Config.ITEM_TITLE: '联系方式',
      Config.ITEM_CONTENT: 'MOBILE'
    },
    {
      Config.ITEM_ICON: 'images/ic_mine_about.png',
      Config.ITEM_TITLE: '所属单位',
      Config.ITEM_CONTENT: 'DWName'
    },
    {
      Config.ITEM_ICON: 'images/ic_mine_about.png',
      Config.ITEM_TITLE: '修改密码',
      Config.ITEM_CONTENT: ' '
    },
  ];

  PersonalCentralPageState(this._useInfoMap);

  @override
  void initState() {
    _avatorURL = _useInfoMap[Config.USER_PHOTOPATH]; // 头像地址

    super.initState();
  }

  // 列表项
  Widget _buildDetailItem(BuildContext context, int index) {
    String content = _useInfoMap[items[index][Config.ITEM_CONTENT]];
    String title = items[index][Config.ITEM_TITLE];

    if (index != 5) {
      // 账户名和单位
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    width: 80,
                    child: Text(title,
                        style: TextStyle(
                            color: Color(ColorConfig.primaryDarkValue),
                            fontSize: FontConfig.middleTextWhiteSize))),
                Expanded(
                    child: Text(content,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color(ColorConfig.subTextColor),
                            fontSize: FontConfig.middleTextWhiteSize))),
              ],
            ),
          ],
        ),
      );
    } else {
      // 修改密码，跳转下个页面
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => EditPwdPage()));
        },
        child: Column(
          children: <Widget>[
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(title,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Color(ColorConfig.primaryDarkValue),
                          fontSize: FontConfig.middleTextWhiteSize)),
                  Text('',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(ColorConfig.subTextColor),
                          fontSize: FontConfig.middleTextWhiteSize)),
                  Icon(Icons.keyboard_arrow_right,
                      color: Colors.grey, size: 20.0),
                ],
              ),
            ),
            SizedBox(height: 8),
            Divider(height: 1),
          ],
        ),
      );
    }
  }

  Future _uploadAvator() async {
    /// 1.获取图片
    var imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile == null) {
      return;
    }

    String imgFormat = imageFile.path.substring(imageFile.path.length - 4);

    /// 2.压缩图片
    var dir = await path_provider.getTemporaryDirectory();
    var targetPath = dir.absolute.path + Uuid().v1() + imgFormat; // 格式后续修改
    var compressImgFile =
        await image_utils.compressAndGetFile(imageFile, targetPath) ??
            imageFile;

    /// 1.1 成功获取图片
    if (compressImgFile != null) {
      // show Loading Dialog
      CommonUtils.showLoadingDialog(context, '上传头像中...', SpinKitType.SpinKit_Circle);

      /// 3.上传头像图片
      DataResult dataResult =
      await NetUtils.uploadAvator(Address.uploadImg('12'), compressImgFile);
      if (dataResult.result) {
        /// 3.1上传头像成功
        Map<String, dynamic> resultMap = dataResult.data[0];
        String avatorRelativePath = resultMap['FilePath_ex']; // Address.image_host + resultMap['FilePath_ex'];
        Map<String, dynamic> params = {
          'userid': _useInfoMap['ID'],
          'relativepath': avatorRelativePath
        };

        /// 4.更新头像信息
        DataResult dataResult2 =
        await NetUtils.getFromNet(Address.changeAvator(), params);
        if (dataResult2.result) {
          /// 4.1更新头像成功
          _useInfoMap[Config.USER_PHOTOPATH] = resultMap['FilePath'];
          await LocalStorage.save(Config.USER_INFO_KEY, json.encode(_useInfoMap));
          setState(() {
            _avatorURL = resultMap['FilePath'];
          });

          widget.onAvatorChange(resultMap['FilePath']);

          // hide Loading Dialog
          Navigator.pop(context);
          CommonUtils.showTextToast("上传头像成功");
        } else {
          /// 4.2 更新头像失败
          Navigator.pop(context);
          CommonUtils.showTextToast(dataResult2.description);
        }
      } else {
        /// 3.2 上传头像失败
        Navigator.pop(context);
        CommonUtils.showTextToast(dataResult.description);
      }
    } else {
      /// 1.2 获取图片失败
      Navigator.pop(context);
      CommonUtils.showTextToast("从本地获取头像图片失败");
    }
  }

  // 头像
  Widget _buildAvatorItem(BuildContext context, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  width: 80,
                  child: Text(items[index][Config.ITEM_TITLE],
                      style: TextStyle(color: Colors.black, fontSize: 15.0))),
              Expanded(child: Text('')),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _uploadAvator,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    // child: Image(image: CachedNetworkImageProvider(_useInfoMap['PHOTOPATH']),width: 80,height: 80,fit: BoxFit.fill),
                    child: CachedNetworkImage(
                        width: 80,
                        height: 80,
                        fit: BoxFit.fill,
                        imageUrl: _avatorURL,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.error))),
              )
            ],
          ),
        ],
      ),
    );
  }

  // // compress file and get file.
  // Future<File> _compressAndGetFile(File file, String targetPath) async {
  //   var result = await FlutterImageCompress.compressAndGetFile(
  //     file.absolute.path,
  //     targetPath,
  //     // minWidth: 2300,
  //     // minHeight: 1500,
  //     quality: 88,
  //     rotate: 0,
  //   );

  //   print(file.lengthSync());
  //   print(result.lengthSync());

  //   return result;
  // }

  // _showEditDialog(String title, String value, String key, int index) {
  //   String content = value ?? "";
  //   CommonUtils.showEditDialog(context, title, (title) {}, (res) {
  //     content = res;
  //     if (index == 1) {
  //       _newUseInfoMap['REALNAME'] = res;
  //     } else if (index == 3) {
  //       _newUseInfoMap['MOBILE'] = res;
  //     }
  //     print(content);
  //   }, () {
  //     if (content == null || content.length == 0) {
  //       return;
  //     }

  //     Navigator.of(context).pop();
  //   },
  //       titleController: new TextEditingController(),
  //       valueController: new TextEditingController(text: value),
  //       needTitle: false);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(ColorConfig.subLightTextColor),
        appBar: GradientAppBar(
          gradientStart: Color(0xFF2171F5),
          gradientEnd: Color(0xFF49A2FC),
          centerTitle: true,
          title: new Text('个人中心', style: TextStyle(fontSize: FontConfig.naviTextSize)),
          // actions: <Widget>[
          //   new Center(
          //       child: GestureDetector(
          //           onTap: () {
          //             // 保存新的用户信息  TODO：上传后修改
          //             String userInfoString = json.encode(_newUseInfoMap);
          //             LocalStorage.save(Config.USER_INFO_KEY, userInfoString);
          //           },
          //           child: new Padding(
          //               padding: EdgeInsets.all(15),
          //               child: new Text("保存",
          //                   style: new TextStyle(
          //                       color: Colors.white, fontSize: 14)))))
          // ]
        ),
        body: Container(
          color: Colors.white,
          child: ListView.separated(
            itemBuilder: (context, index) {
              return index == 0
                  ? _buildAvatorItem(context, index)
                  : _buildDetailItem(context, index);
            },
            separatorBuilder: (BuildContext context, int index) =>
            new Divider(),
            itemCount: items.length,
          ),
        ));
  }
}
