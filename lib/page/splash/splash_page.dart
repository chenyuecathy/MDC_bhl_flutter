import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
// import 'package:mdc_bhl/common/config/config.dart';
// import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/model/data_result.dart';
import 'package:mdc_bhl/page/login/login_page.dart';
import 'package:mdc_bhl/page/tabbar_bottom_page.dart';
import 'package:mdc_bhl/utils/data_utils.dart';
// import 'package:mdc_bhl/utils/date_utils.dart';
import 'package:mdc_bhl/utils/file_utils.dart';
// import 'package:mdc_bhl/utils/task_net_utils.dart';

// import 'package:mdc_bhl/db/db_manager.dart';
// import 'package:mdc_bhl/common/local/local_storage.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => new _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool isStartHomePage = false;

  bool _hasLogin = false;
  bool _isLoading = true;

  String _departmentId;

  // BuildContext context;

  @override
  void initState() {
    super.initState();

    ///开启倒计时
    countDown();

    /// check login
    DataUtils.checkLogin().then((DataResult dataResult) {
      setState(() {
        _hasLogin = dataResult.result;
        _departmentId = dataResult.data;
        _isLoading = false;
      });
    }).catchError((onError) {
      setState(() {
        _hasLogin = true;
        _isLoading = false;
      });
      print('身份信息验证失败:$onError');
    });

    _prepareData();
  }

  void writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytesSync(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  _prepareData() async {
    String dbPath = await FileUtils.getDatabasePath();

    print('database path :::::::: ' + dbPath);

    var isExist = await FileUtils.isExistsFile(dbPath);
    if (!isExist) {
      // copy if not exsit
      print('copy if not exsit');

      ByteData data = await rootBundle.load("assets/mdc_bhl.db");
      writeToFile(data, dbPath);
      // File file = File('assets/mdc_bhl.db');
      // await file.copy(documentsDirectory.path);
    }

  }

  @override
  Widget build(BuildContext context) {
    context = context;
    return new GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: goToHomePage, //设置页面点击事件
        child: new Container(
//            color: Colors.blue,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/splash_bg.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: Image.asset("images/splash_text.png"),
          // new Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          // children: <Widget>[
          //   new Container(
          //       decoration: new BoxDecoration(
          //         border: new Border.all(color: Colors.blue, width: 0.5),
          //         // 边色与边宽度
          //         borderRadius: new BorderRadius.circular(20.0), // 圆角度
          //       ),
          //       margin: EdgeInsets.only(bottom: 50),
          //       child: new Image.asset(
          //         'images/ic_logo.png',
          //         width: 100.0,
          //         height: 100.0,
          //         repeat: ImageRepeat.noRepeat,
          //         //当一个图片占不满容器的时候这个可以控制图片水平ImageRepeat.repeatX， 或者垂直ImageRepeat.repeatY  或者依次排列ImageRepeat.repeat，来占满   或者正常ImageRepeat.noRepeat
          //         fit: BoxFit.fill,
          //         centerSlice: new Rect
          //             .fromCircle( //可以设置图片在拉伸的时候从某一个固定的地方拉伸类似.9
          //           center: const Offset(200.0, 200.0),
          //           radius: 10.0,
          //         ),
          //       )
          //   ),
          // new Text(
          //   '白鹤梁监测云',
          //   style: new TextStyle(
          //     fontSize: 30.0,
          //     color: Colors.blue,
          //     decoration: TextDecoration.none,
          //   ),
          // )
          // ],
          // )
        ));
  }

  void countDown() {
    //设置倒计时三秒后执行跳��方法
    var duration = new Duration(seconds: 3);
    new Future.delayed(duration, goToHomePage);
  }

  void goToHomePage() {
    // 判断是否已经登录
    if (_hasLogin) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => TabBarBottomPage(_departmentId)));
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }
}
