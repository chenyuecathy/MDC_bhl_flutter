import 'package:flutter/material.dart';

import 'package:mdc_bhl/page/device/device_input_page.dart';
import 'package:mdc_bhl/page/device/device_temperature_and_humidity_page.dart';
import 'package:mdc_bhl/db/tab_device_record_manager.dart';
import 'package:mdc_bhl/utils/date_utils.dart';
import 'package:mdc_bhl/model/data_result.dart';
import 'package:mdc_bhl/common/config/config.dart';

class TaskDeviceDetailItem extends StatefulWidget {
  final TabDeviceRecordModel taskModel;
  final String title;
  final ValueChanged<String> onWrongChanged;

  TaskDeviceDetailItem(this.taskModel, this.title,this.onWrongChanged);

  @override
  createState() => TaskDeviceDetailItemState();
}

class TaskDeviceDetailItemState extends State<TaskDeviceDetailItem> {

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: ()async {
        // 检查巡查时间
        DataResult checkResult = await DateUtils.checkInspectionTime(DepartmentTaskType.values[widget.taskModel.inspectionType]);
        if (!checkResult.result && widget.taskModel.isUpload == 0) { // 在核查时间内且未提交的不可编辑
          widget.onWrongChanged(checkResult.description);
          return;
        }

        Navigator.push(context,MaterialPageRoute(builder: (BuildContext context) {
          if (widget.taskModel.recordState == 1) { // 温湿度
            return DeviceTemperatureAndHumidityPage(widget.taskModel, widget.title);
          } else {
            return DeviceInputPage(widget.taskModel, widget.title);
          }
        }));
      }, // 点击事件
      title: Text(widget.taskModel.recordTitle,
          textAlign: TextAlign.left,
          style: TextStyle(color: Colors.black, fontSize: 15.0)),
      trailing:
          Icon(Icons.keyboard_arrow_right, color: Colors.grey, size: 20.0),
    );
  }
}
