import 'package:flutter/material.dart';

import 'package:mdc_bhl/db/tab_device_record_manager.dart';
import 'package:mdc_bhl/utils/date_utils.dart';
import 'package:mdc_bhl/common/config/config.dart';
import 'package:mdc_bhl/model/data_result.dart';

class TaskDeviceSwtichItem extends StatefulWidget {
  final TabDeviceRecordModel taskRecord;
  final ValueChanged<String> onWrongChanged;

  TaskDeviceSwtichItem(this.taskRecord, this.onWrongChanged);

  @override
  createState() => TaskDeviceSwtichItemState();
}

class TaskDeviceSwtichItemState extends State<TaskDeviceSwtichItem> {
  bool _value = false;
  /* 记录状态，对应于记录的recordType字段（0-异常，1-正常，2-开，3-关，4-有，5-无，6-温湿度，7-录入）*/

  @override
  void initState() {
    _value = (widget.taskRecord.recordType == 3 ||
            widget.taskRecord.recordType == -1)
        ? false
        : true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(widget.taskRecord.recordTitle,
              textAlign: TextAlign.left, style: TextStyle(fontSize: 15.0)),
          Switch(
            onChanged: (newValue) async {
               // 检查巡查时间
               DataResult checkResult = await DateUtils.checkInspectionTime(DepartmentTaskType.values[widget.taskRecord.inspectionType]);
               if (!checkResult.result) {
                 widget.onWrongChanged(checkResult.description);
                 return;
               }

              setState(() {
                _value = newValue;
                if (newValue) {
                  widget.taskRecord.recordType = 4; // 开
                } else {
                  widget.taskRecord.recordType = 5; // 关
                }
              });
            },
            value: _value,
            activeColor: Colors.blue, // 激活时原点颜色
          )
        ],
      ),
    );
  }
}
