import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mdc_bhl/model/data_result.dart';
import 'package:mdc_bhl/page/login/login_page.dart';
import 'package:mdc_bhl/page/splash/splash_page.dart';
import 'package:mdc_bhl/page/tabbar_bottom_page.dart';
import 'package:mdc_bhl/provider/signalr_provider.dart';
import 'package:mdc_bhl/utils/data_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import 'camera/CameraHomeScreen.dart';
import 'camera/take_photo_and_video.dart';

List<CameraDescription> cameras; // 相机
const String CAMERA_SCREEN = "/CAMERA_SCREEN"; // 相机
const String TAKE_PHOTO_AND_VIDEO = "/TAKE_PHOTO_AND_VIDEO"; // 拍照和录像

const int ThemeColor = 0xFFC91B3A;

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // flutter 升级后添加

  // 启动相机
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print(e.code);
  }

  // 透明状态栏
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  return runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        builder: (_) => SignalRProvider(),
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasLogin = false;
  bool _isLoading = true;

  String _departmentId;

  @override
  initState() {
    super.initState();

    /// check version
    // DataUtils.checkVersion(
    //         {'_api_key': Address.PGYAPIKey, 'appkey': Address.PGYAPPKey})
    //     .then((VersionResult result) {
    //   if (result.update) {
    //     // 有新版本

    //   } else {
    //     //无新版本

    //   }
    // }).catchError((onError) {
    //   print('获取失败:$onError');
    // });

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

    /// 初始化数据库
    // _initDb();
  }

  // /*
  //  * 初始化数据库
  //  */
  // _initDb() async {
  //   new DbManager();
  // }

  showWelcomePage() {
    if (_isLoading) {
      return Container(
        color: const Color(ThemeColor),
        child: Center(
          child: SpinKitPouringHourglass(color: Colors.white),
        ),
      );
    } else {
      // 判断是否已经登录
      if (_hasLogin) {
        return TabBarBottomPage(_departmentId);
      } else {
        return LoginPage();
      }
    }
  }

  // _UpdateURL() async {
  //   const currUrl =
  //       'https://github.com/alibaba/flutter-go/raw/master/FlutterGo.apk';
  //   if (await canLaunch(currUrl)) {
  //     await launch(currUrl);
  //   } else {
  //     throw 'Could not launch $currUrl';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return OKToast(
        dismissOtherOnShow: true, // 全局变量设置
        child: MaterialApp(
            title: '白鹤梁监测云',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: SplashPage(),
            // Scaffold(body: showWelcomePage()),
            //去掉debug logo
            debugShowCheckedModeBanner: false,
            // onGenerateRoute: Application.router.generator,
            // navigatorObservers: <NavigatorObserver>[Analytics.observer],
            // 路由设置 很关键
            routes: <String, WidgetBuilder>{
              // RecordHomePage.route: (context) => RecordHomePage(),
              // 相机
              CAMERA_SCREEN: (BuildContext context) =>
                  CameraHomeScreen(cameras),
              // 拍照和录像
              TAKE_PHOTO_AND_VIDEO: (BuildContext context) =>
                  TakePhotoAndVideo(cameras)
            },
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[
              DefaultCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('en', 'US'),
              const Locale('zh', 'Hans'),
              const Locale('zh', '')
            ]));
  }
}
