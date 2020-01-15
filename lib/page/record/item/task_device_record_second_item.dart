import 'package:flutter/material.dart';
import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/db/tab_device_record_manager.dart';
import 'package:mdc_bhl/page/device/device_abnormal_page.dart';
import 'package:mdc_bhl/page/device/device_input_page.dart';
import 'package:mdc_bhl/page/device/device_temperature_and_humidity_page.dart';

class TaskDeviceRecordSecondItem extends StatefulWidget {
  final TabDeviceRecordModel tabDeviceRecordModel;

  TaskDeviceRecordSecondItem(this.tabDeviceRecordModel);

  @override
  createState() {
    return new TaskDeviceRecordSecondItemState(tabDeviceRecordModel);
  }
}

class TaskDeviceRecordSecondItemState
    extends State<TaskDeviceRecordSecondItem> {
  TabDeviceRecordModel _tabDeviceRecordModel;

  TaskDeviceRecordSecondItemState(this._tabDeviceRecordModel);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          debugPrint(_tabDeviceRecordModel.toString());
          String _title = "";
          if (_tabDeviceRecordModel.inspectionType == 0) {
            _title = "设备科日巡查记录";
          } else if (_tabDeviceRecordModel.inspectionType == 1) {
            _title = "设备科夜巡查记录";
          } else if (_tabDeviceRecordModel.inspectionType == 2) {
            _title = "保卫科日常巡查记录";
          }
          if (_tabDeviceRecordModel.recordType == 0) {
            Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) => DeviceAbnormalPage(
                          _tabDeviceRecordModel,
                          _title,
                          showDispoalView: true,
                        )))
                .then((disposal) {
              if (disposal == '1' || disposal == '0') {
                setState(() {
                  _tabDeviceRecordModel.isChecked = int.parse(disposal);
                });
              }
            });
          } else if (_tabDeviceRecordModel.recordType == 6) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DeviceTemperatureAndHumidityPage(
                    _tabDeviceRecordModel, _title)));
          } else if (_tabDeviceRecordModel.recordType == 7) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    DeviceInputPage(_tabDeviceRecordModel, _title)));
          }
        },
        child: Column(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(_tabDeviceRecordModel.recordTitle,
                                    style: TextStyle(fontSize: 16)),
                                const SizedBox(height: 5.0), // 占位图
                                Text(_tabDeviceRecordModel.time,
                                    style: TextStyle(
                                        color: Color(0xFF808080), fontSize: 14))
                              ]),
                          flex: 1),
                      Expanded(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                _getRightWidget(_tabDeviceRecordModel)
                              ]),
                          flex: 1)
                    ])),
            // Divider()
          ],
        ));
  }

  Widget _getRightWidget(TabDeviceRecordModel tabDeviceRecordModel) {
    int type = tabDeviceRecordModel.recordType;
    if (type == 0) {
      // 异常
//      return Image.asset('images/ic_abnormal.png', height: 45, width: 45);
      return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text("异常",
                textAlign: TextAlign.right,
                style: new TextStyle(
                    color: Colors.red, fontSize: FontConfig.titleTextSize)),
            SizedBox(
              height: 5,
            ),
            Text((_tabDeviceRecordModel.isChecked == 0) ? "未处置" : "已处置",
                textAlign: TextAlign.right,
                style: new TextStyle(
                    color: Color(ColorConfig.darkTextColor),
                    fontSize: FontConfig.contentTextSize)),
          ]);
    } else if (type == 1) {
      // 正常
//      return Image.asset('images/ic_normal.png', height: 45, width: 45);
      return Text("正常",
          textAlign: TextAlign.right,
          style: new TextStyle(
              color: Colors.green, fontSize: FontConfig.titleTextSize));
    } else if (type == 2) {
      // 开
//      return Image.asset('images/ic_open.png', height: 45, width: 45);
      return Text("开",
          textAlign: TextAlign.right,
          style: new TextStyle(
              color: const Color(ColorConfig.darkTextColor),
              fontSize: FontConfig.titleTextSize));
    } else if (type == 3) {
      // 关
//      return Image.asset('images/ic_close.png', height: 45, width: 45);
      return Text("关",
          textAlign: TextAlign.right,
          style: new TextStyle(
              color: const Color(ColorConfig.darkTextColor),
              fontSize: FontConfig.titleTextSize));
    } else if (type == 4) {
      // 有
//      return Image.asset('images/ic_have.png', height: 45, width: 45);
      return Text("有",
          textAlign: TextAlign.right,
          style: new TextStyle(
              color: const Color(ColorConfig.darkTextColor),
              fontSize: FontConfig.titleTextSize));
    } else if (type == 5) {
      // 无
//      return Image.asset('images/ic_not_have.png', height: 45, width: 45);
      return Text("无",
          textAlign: TextAlign.right,
          style: new TextStyle(
              color: const Color(ColorConfig.darkTextColor),
              fontSize: FontConfig.titleTextSize));
    } else if (type == 6) {
      // 温湿度
      return Container(
          margin: EdgeInsets.only(top: 3),
          child: Icon(Icons.keyboard_arrow_right, color: Colors.black45));
    } else if (type == 7) {
      // 录入
      return Container(
          margin: EdgeInsets.only(top: 3),
          child: Icon(Icons.keyboard_arrow_right, color: Colors.black45));
    } else {
      // 默认
      return Text("未操作",
          textAlign: TextAlign.right,
          style: new TextStyle(
              color: Colors.green, fontSize: FontConfig.titleTextSize));
    }
  }
}
