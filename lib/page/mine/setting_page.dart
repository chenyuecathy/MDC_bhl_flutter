import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/widget/gradient_appbar.dart';


class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  int _checkIndex = 0;

  @override
  void initState() {
    _getDataSaveTime();
    super.initState();
  }

  _getDataSaveTime() async {
    String dataSaveTime = await LocalStorage.get(Config.DATA_SAVE_TIME);
    if (dataSaveTime == Config.A_WEEK) {
      setState(() {
        _checkIndex = 0;
      });
    } else if (dataSaveTime == Config.HALF_MONTH) {
      setState(() {
        _checkIndex = 1;
      });
    } else if (dataSaveTime == Config.A_MONTH) {
      setState(() {
        _checkIndex = 2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(ColorConfig.subLightTextColor),
        appBar: GradientAppBar(
          gradientStart: Color(0xFF2171F5),
          gradientEnd: Color(0xFF49A2FC),
          centerTitle: true,
          title: new Text('系统设置', style: TextStyle(fontSize: FontConfig.naviTextSize)),
          leading: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.chevron_left, size: 30)
          )
        ),
        body: Container(
            color: Colors.white,
            child: Column(
                children: <Widget>[
                  Container(
                      margin: const EdgeInsets.fromLTRB(16, 18, 16, 5),
                      color: Colors.white,
                      child: Column(
                          children: <Widget>[
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Icon(Icons.save, color: Colors.blue, size: 20.0),
                                  Expanded(
                                      child: Container(
                                          margin: const EdgeInsets.only(left: 10),
                                          child: Text("数据保留时间设置",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Color(ColorConfig.primaryDarkValue),
                                                  fontSize: FontConfig.middleTextWhiteSize))
                                      ),
                                      flex: 1
                                  )
                                ]
                            ),
                            Divider(),
                            _getCheckBoxItem("一周", 0),
                            _getCheckBoxItem("半个月", 1),
                            _getCheckBoxItem("一个月", 2),
                          ]
                      )
                  ),
                  Divider()
                ]
            )
        )
    );
  }

  _getCheckBoxItem(String title, int index) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 5),
            child: Text(title, style: TextStyle(color: Color(ColorConfig.primaryDarkValue), fontSize: FontConfig.smallTextSize)),
          ),
          Checkbox(
              value: index == _checkIndex ? true : false,
              onChanged: (bool value) async {
                setState(() {
                  _checkIndex = index;
                });
                if (index == 0) {
                  await LocalStorage.save(Config.DATA_SAVE_TIME, Config.A_WEEK);
                } else if (index == 1) {
                  await LocalStorage.save(Config.DATA_SAVE_TIME, Config.HALF_MONTH);
                } else if (index == 2) {
                  await LocalStorage.save(Config.DATA_SAVE_TIME, Config.A_MONTH);
                }
              },
              tristate: true
          )
        ]
    );
  }
}