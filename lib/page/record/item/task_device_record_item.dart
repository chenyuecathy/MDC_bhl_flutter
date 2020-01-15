import 'package:flutter/material.dart';

import 'package:mdc_bhl/db/tab_device_record_manager.dart';
import 'package:mdc_bhl/page/record/item/task_device_record_second_item.dart';

class TaskDeviceRecordItem extends StatefulWidget {
  /*
   * recordType该记录的类型
   * 0——办公室（任务）
   * 1——设备科（任务）
   * 2——保卫科（任务）
   * 3——采集
   * 4——异常上报
   */
  final int recordType;
  final String dateTitle;
  final List<TabDeviceRecordModel> taskModels;

  TaskDeviceRecordItem({this.recordType, this.dateTitle, this.taskModels});

  @override
//  createState() {
//      return DeviceAndGuardTaskRecordItemState(this.taskModels);
//  }
  createState() => DeviceAndGuardTaskRecordItemState();
}

// 设备科、保卫科
class DeviceAndGuardTaskRecordItemState extends State<TaskDeviceRecordItem> {
//  List<TabDeviceRecordModel> _taskModels = []; // 展示内容

//  DeviceAndGuardTaskRecordItemState(this._taskModels);

  @override
  Widget build(BuildContext context) {
    return (widget.taskModels != null)
        ? Card(
            color: Colors.white,
            elevation: 2.0,
            margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)), // 圆角
            ),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: buildItems(),
              ),
            ))
        : Container();
  }

  List<Widget> buildItems() {
    List<Widget> items = [];
    items.add(Text(widget.dateTitle, textAlign: TextAlign.left, style: TextStyle(fontSize: 18, color: Colors.blue)));
    items.add(SizedBox(height: 10));
    for (var item in widget.taskModels) {
      items.add(TaskDeviceRecordSecondItem(item));
    }
    return items;
  }
}
