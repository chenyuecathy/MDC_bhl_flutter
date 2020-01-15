import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/widget/gradient_appbar.dart';

class AboutUsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new AboutUsPageState();
}

class AboutUsPageState extends State<AboutUsPage> {
  String _content = "       白鹤梁石鱼智采是一款用于辅助遗产监测，用于采集监测数据的手机App应用。依据国家监测数据采集标准规范、结合白鹤梁题刻遗产特点与监测需求，采用移动互联网技术，能够依据用户权限按部门职责采集日常巡查数据、客流高峰照片，录入保护体稳定性设备监测数据、渗漏水监测数据、长江水位数据，及时上报遗产区日常问题，简化了日常工作流程，提高了工作效率。";

  String version  = '';
  final double leading = 0.5;
  final double textLineHeight = 2; /// 文本间距

//  String url = 'www.baidu.com';
//
//   @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('关于',style:TextStyle(fontSize: FontConfig.naviTextSize)),
//        centerTitle: true,
//        // actions: <Widget>[
//        //   IconButton(
//        //     tooltip: 'Collection',
//        //     color: Colors.white,
//        //     disabledColor: Colors.white,
//        //     icon:Icon(Icons.favorite),
//        //     onPressed:null,
//        //   ),
//        // ],
//        // leading:  IconButton(
//        //   icon: Icon(Icons.chevron_left),
//        //   color: Colors.white,
//        //   disabledColor: Colors.white,
//        //   tooltip: 'Back to flutter Navigator',
//        //   onPressed: ()=> Navigator.pop(context,false),
//        // ),
//      ),
//
////      body: WebviewScaffold(
////        url: 'https://www.baidu.com/',
////        withZoom: false,
////        withLocalStorage: true,
////        withJavascript: true,
////      ),
//    );
//  }

@override
void initState() { 
  super.initState();
  getVersion();
}

void getVersion ()async{  
      PackageInfo info = await PackageInfo.fromPlatform();
      setState(() {
        version = info.version;
      });

}

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new GradientAppBar(
          gradientStart: Color(0xFF2171F5),
          gradientEnd: Color(0xFF49A2FC),
          centerTitle: true,
          title: new Text("关于石鱼智采", style: TextStyle(fontSize: FontConfig.naviTextSize)),
          leading: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.chevron_left, size: 30)
          ),
        ),
        body: new Stack(
            children: <Widget>[
              new Column(
                  children: <Widget>[
                    const SizedBox(height: 20.0), // 占位图

                    Image.asset('images/ic_launcher.png',
                        width: 90,
                        height: 90,
                        repeat: ImageRepeat.noRepeat
                    ),

                    SizedBox(height: 10,),
                    Text('石鱼智采 V$version',textAlign:TextAlign.center,style: TextStyle(fontSize: 17.0),),

                    Padding(padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
                        child: Text(_content,
                            textAlign: TextAlign.justify,
                            strutStyle: StrutStyle(forceStrutHeight: true, height: textLineHeight, leading: leading),
                            style: TextStyle(
                                color: const Color(ColorConfig.darkTextColor),
                                fontSize: 15
                            )
                        )
                    ),

//                    new RaisedButton(
//                        padding: EdgeInsets.fromLTRB(100, 10, 100, 10),
//                        child: Text("官    网"),
//                        color: Theme
//                            .of(context)
//                            .primaryColor,
//                        textColor: Colors.white,
//                        onPressed: () async {}
//                    )
                  ]
              ),

              Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        //                      color: Color.fromARGB(100, 50, 100, 0),
                          child: Center(
                              child: Text(
                                "技术支持：国信司南（北京）地理信息技术有限公司",
                                style: TextStyle(
                                    color: const Color(0xFF808080), fontSize: 12),
                              )
                          )
                      )
                  )
              )
            ]
        )
    );
  }
}