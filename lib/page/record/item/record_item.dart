import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/event/index.dart';
import 'package:mdc_bhl/utils/eventbus_utils.dart';

import 'package:mdc_bhl/db/tab_office_record_manager.dart';
import 'package:mdc_bhl/db/tab_report_record_manager.dart';
import 'package:mdc_bhl/page/office/office_info_page.dart';
import 'package:mdc_bhl/page/record/collect/my_collect_list_home_page.dart';
import 'package:mdc_bhl/page/report/report_page.dart';
import 'package:mdc_bhl/page/record/collect/secondary_page/collect_seepage_page.dart';
import 'package:mdc_bhl/page/record/collect/secondary_page/collect_stable_page.dart';
import 'package:mdc_bhl/page/record/collect/secondary_page/collect_water_level_page.dart';

/// 记录类型
enum RecordType { office, device, guard, collect, report }

class RecordItem extends StatefulWidget {
  /*
   * recordType该记录的类型
   * 0——办公室（任务）
   * 1——设备科（任务）
   * 2——保卫科（任务）
   * 3——采集
   * 4——异常上报
   */
  final RecordType recordType;
  final TabOfficeRecordModel tabOfficeRecordModel;
  // final String _inspectionId;
  final MyCollectListModel myCollectListModel;
  final TabReportRecordModel tabReportRecordModel;

  RecordItem(
      {this.recordType,
      this.tabOfficeRecordModel,
      this.myCollectListModel,
      this.tabReportRecordModel});

  @override
  createState() {
    if (recordType.index == 0) {
      return OfficeRecordItemState(tabOfficeRecordModel);
    } /*else if (_recordType == 1) {
      return DeviceAndGuardRecordItemState(_inspectionId);
    } else if (_recordType == 2) {
      return DeviceAndGuardRecordItemState(_inspectionId);
    } */
    else if (recordType.index == 3) {
      return CollectRecordItemState(myCollectListModel);
    } else {
      return ReportRecordItemState(tabReportRecordModel);
    }
  }
}

// 办公室
class OfficeRecordItemState extends State<RecordItem> {
  TabOfficeRecordModel _tabOfficeRecordModel;

  OfficeRecordItemState(TabOfficeRecordModel tabOfficeRecordModel) {
    _tabOfficeRecordModel = tabOfficeRecordModel;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          debugPrint(_tabOfficeRecordModel.toString());
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return OfficeInfoPage(_tabOfficeRecordModel);
          })).then((_) {
            // 发送订阅消息刷新办公室列表
            eventBus.fire(EventUtil(Config.REFRESH_MY_OFFICE_LIST, null));
          });
        },
        child: Column(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(_tabOfficeRecordModel.collectionName,
                                    style: TextStyle(fontSize: 16))
                              ]),
                          flex: 1),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                    _tabOfficeRecordModel.isUpload == 0
                                        ? "待上传"
                                        : "已完成",
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 14)),
                                const SizedBox(height: 5.0), // 占位图
                                Text(_tabOfficeRecordModel.time,
                                    style: TextStyle(
                                        color: const Color(0xFF808080),
                                        fontSize: 14))
                              ]),
                          flex: 1)
                    ])),
            Divider()
          ],
        ));
  }
}

// 采集
class CollectRecordItemState extends State<RecordItem> {
  MyCollectListModel _myCollectListModel;

  CollectRecordItemState(MyCollectListModel myCollectListModel) {
    _myCollectListModel = myCollectListModel;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          debugPrint(_myCollectListModel.toString());
          Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) {
            if (_myCollectListModel.recordType == "0") {
              return CollectSeepagePage(_myCollectListModel);
            } else if (_myCollectListModel.recordType == "1") {
              return CollectStablePage(_myCollectListModel);
            } else {
              // _myCollectListModel.recordType == "2"
              return CollectWaterLevelPage(_myCollectListModel);
            }
          }));
        },
        child: Column(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                    _myCollectListModel.recordType == "0"
                                        ? "渗漏水"
                                        : (_myCollectListModel.recordType == "1"
                                            ? "稳定性"
                                            : "水位"),
                                    style: TextStyle(fontSize: 16))
                              ]),
                          flex: 3),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                    _myCollectListModel.isUpload
                                        ? "已完成"
                                        : "待上传",
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 14)),
                                const SizedBox(height: 5.0), // 占位图
                                Text(_myCollectListModel.uploadTime,
                                    style: TextStyle(
                                        color: const Color(0xFF808080),
                                        fontSize: 14))
                              ]),
                          flex: 2)
                    ])),
            Divider()
          ],
        ));
  }
}

// 异常上报
class ReportRecordItemState extends State<RecordItem> {
  TabReportRecordModel _tabReportRecordModel;

  ReportRecordItemState(TabReportRecordModel tabReportRecordModel) {
    _tabReportRecordModel = tabReportRecordModel;
  }

  Codec<String, String> stringToBase64 = utf8.fuse(base64); // 用于编码

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) {
            print(_tabReportRecordModel);
            return ReportPage(true,
                reportRecord: _tabReportRecordModel,
                showDispoalView:
                    (_tabReportRecordModel.isUpload == 1) ? true : false);
          })).then((disposal) {
            if (disposal == '1' || disposal == '0') {
              setState(() {
                _tabReportRecordModel.isChecked = int.parse(disposal);
              });
            }
          });
        },
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(stringToBase64.decode(_tabReportRecordModel.location),
                                style: TextStyle(fontSize: 16))
                          ]),
                      flex: 3),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                                _tabReportRecordModel.isUpload == 0
                                    ? "待上传"
                                    : _tabReportRecordModel.isChecked == 0
                                        ? '未处置'
                                        : '已处置',
                                style: TextStyle(
                                    color: Colors.blue, fontSize: 14)),
                            const SizedBox(height: 5.0), // 占位图
                            Text(_tabReportRecordModel.time,
                                style: TextStyle(
                                    color: const Color(0xFF808080),
                                    fontSize: 14))
                          ]),
                      flex: 2)
                ])));
  }
}

// // 设备科、保卫科
// class DeviceAndGuardRecordItemState extends State<RecordItem> {
//   String _inspectionId; // 分类依据
//   String _time = ""; // 展示内容

//   List<String> _inspectionContentIdList = []; // 分类依据
//   List<String> _recordTitleList = []; // 展示内容

//   DeviceAndGuardRecordItemState(inspectionId) {
//     _inspectionId = inspectionId;
//     initData();
//   }

//   initData() async {
//     TabDeviceRecordManager _tabDeviceRecordManager = TabDeviceRecordManager();
//     List<TabDeviceRecordModel> tabDeviceRecordModelList =
//         await _tabDeviceRecordManager.queryByInspectionId(_inspectionId);
//     if (tabDeviceRecordModelList.length > 0) {
//       setState(() {
//         _time = tabDeviceRecordModelList[0].time.substring(0, 10);
//         for (int i = 0; i < tabDeviceRecordModelList.length; i++) {
//           if (!_inspectionContentIdList
//               .contains(tabDeviceRecordModelList[i].inspectionContentId)) {
//             // _inspectionContentIdList不存在该inspectionContentId则添加
//             _inspectionContentIdList
//                 .add(tabDeviceRecordModelList[i].inspectionContentId);
//             _recordTitleList.add(tabDeviceRecordModelList[i].recordTitle);
//           }
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(children: <Widget>[
//       Container(
//           padding: EdgeInsets.all(10),
//           child: Row(children: <Widget>[
//             Text(_time, style: TextStyle(color: Colors.blue, fontSize: 16))
//           ])),
//       _getList()
//     ]);
//   }

//   _getList() {
//     // if (_inspectionContentIdList.length != 0) {
//     return Column(children: _getItem());
//     // } else {
//     //   return BlankWidget(false);
//     // }
//   }

//   List<Widget> _getItem() {
//     List<Widget> list = [];
//     for (var i = 0; i < _recordTitleList.length; i++) {
//       Widget widget = Column(children: <Widget>[
//         GestureDetector(
//             behavior: HitTestBehavior.opaque,
//             onTap: () {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (BuildContext context) => TaskSecondaryPage(
//                           _inspectionId, _inspectionContentIdList[i])));
//             },
//             child: Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: Row(children: <Widget>[
//                   Expanded(
//                       child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: <Widget>[
//                             Text(_recordTitleList[i],
//                                 style: TextStyle(fontSize: 16))
//                           ]),
//                       flex: 1),
//                   Expanded(
//                       child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: <Widget>[
//                             Container(
//                                 margin: EdgeInsets.only(top: 3),
//                                 child: Icon(Icons.keyboard_arrow_right,
//                                     size: 20, color: const Color(0xFF808080)))
//                           ]),
//                       flex: 1)
//                 ]))),
//         Divider(),
//         // (i != _recordTitleList.length - 1) ? Divider() : Container(height: 10)
//       ]);
//       list.add(widget);
//     }
//     return list;
//   }
// }
