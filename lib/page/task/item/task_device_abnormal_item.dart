import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/db/tab_device_record_manager.dart';
import 'package:mdc_bhl/page/device/device_abnormal_page.dart';
import 'package:mdc_bhl/utils/date_utils.dart';
import 'package:mdc_bhl/model/data_result.dart';

class TaskDeviceAbnormalItem extends StatefulWidget {
  /* 记录状态，对应于记录的recordType字段（0-异常，1-正常，2-开，3-关，4-有，5-无，6-温湿度，7-录入）
   * -1 无状态
   * 0 异常
   * 1 正常
   */
  final TabDeviceRecordModel taskRecordModel;
  final String title;
  final ValueChanged<String> onWrongChanged;
  final ValueChanged<TabDeviceRecordModel> onRecordChanged;

  TaskDeviceAbnormalItem(this.taskRecordModel, this.title, this.onWrongChanged, this.onRecordChanged);

  @override
  createState() => TaskDeviceAbnormalItemState();
}

class TaskDeviceAbnormalItemState extends State<TaskDeviceAbnormalItem> {
  @override
  void initState() {
    _initData();
    super.initState();
  }

  _initData() async {
    Map<String, dynamic> userInfo = json.decode(await LocalStorage.get(Config.USER_INFO_KEY));
    widget.taskRecordModel.inspectorId = userInfo["ID"];
    widget.taskRecordModel.inspectorName = userInfo["REALNAME"];
  }

  @override
  Widget build(BuildContext context) {
    // print('【${widget.taskRecordModel.recordTitle} recordType:${widget.taskRecordModel.recordType} upload:${widget.taskRecordModel.isUpload} time:${widget.taskRecordModel.time} 】widget build');

    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onItemClick,
        child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    widget.taskRecordModel.recordTitle,
                    style: TextStyle(fontSize: 15.0),
                  ),
                  Container(
                    child: Row(children: <Widget>[
                      Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                  (widget.taskRecordModel.recordType != 1)
                                      ? Colors.green
                                      : Colors.white,
                                  width: 0.5),
                              borderRadius: BorderRadius.circular(20),
                              color: (widget.taskRecordModel.recordType != 1)
                                  ? Colors.white
                                  : Colors.green),
                          child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              child: Center(
                                  child: Text("正常",
                                      style: TextStyle(
                                          color: (widget.taskRecordModel.recordType != 1)
                                              ? Colors.black26
                                              : Colors.white,
                                          fontSize: 13.0))),
                              onTap: () async {

                                // 检查巡查时间
                                 DataResult checkResult = await DateUtils.checkInspectionTime(DepartmentTaskType.values[widget.taskRecordModel.inspectionType]);
                                 if (!checkResult.result) {
                                   widget.onWrongChanged(checkResult.description);
                                   return;
                                 }


                                if (widget.taskRecordModel.isUpload == 1) {
                                  if (widget.taskRecordModel.recordType == 0) {
                                    widget.onWrongChanged( '本日【${widget.taskRecordModel.recordTitle} 】巡查内容已上传,不能修改');
                                  }
                                } else {
                                  setState(() {
                                    widget.taskRecordModel.recordType = 1; // 正常
                                    widget.onRecordChanged(widget.taskRecordModel);

                                    /// TODO 更新数据库.  未处理更新失败的情况
                                    TabDeviceRecordManager().insert(widget.taskRecordModel);
                                  });
                                }
                              })),
                      const SizedBox(width: 20),
                      Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                  (widget.taskRecordModel.recordType != 0)
                                      ? Colors.red
                                      : Colors.white,
                                  width: 0.5),
                              borderRadius: BorderRadius.circular(20),
                              color: (widget.taskRecordModel.recordType != 0)
                                  ? Colors.white
                                  : Colors.red),
                          child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              child: Center(
                                  child: Text("异常",
                                      style: TextStyle(
                                          color: (widget.taskRecordModel
                                              .recordType !=
                                              0)
                                              ? Colors.black26
                                              : Colors.white,
                                          fontSize: 13.0))),
                              onTap: () async {

                                // 检查巡查时间
                                 DataResult checkResult = await DateUtils.checkInspectionTime(DepartmentTaskType.values[widget.taskRecordModel.inspectionType]);
                                 if (!checkResult.result) {
                                   widget.onWrongChanged(checkResult.description);
                                   return;
                                 }

                                if (widget.taskRecordModel.isUpload == 1) {
                                  print(
                                      'TaskDeviceAbnormalItem 已上传--点击击了异常 【${widget.taskRecordModel.recordTitle} type:${widget.taskRecordModel.recordType} upload:${widget.taskRecordModel
                                          .isUpload} 】');
                                  if (widget.taskRecordModel.recordType == 1) {
                                    widget.onWrongChanged(
                                        '本日【${widget.taskRecordModel.recordTitle} 】巡查内容已上传,不能修改');
                                  }
                                } else {
                                  setState(() {
                                    widget.taskRecordModel.recordType = 0; // 异常
                                    widget.onRecordChanged(widget.taskRecordModel);
                                    TabDeviceRecordManager().insert(widget.taskRecordModel);


                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return DeviceAbnormalPage(
                                              widget.taskRecordModel, widget.title);
                                        }));
                                  });
                                }
                              }))
                    ]),
                  )
                ])));
  }

  _onItemClick() {
    // debugPrint(taskModel.toString());
    if (widget.taskRecordModel.isUpload == 1 &&
        widget.taskRecordModel.recordType == 0) {
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
            return DeviceAbnormalPage(widget.taskRecordModel, widget.title);
          }));
    }
  }
}
