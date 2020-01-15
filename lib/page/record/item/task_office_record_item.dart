import 'package:flutter/material.dart';

import 'package:mdc_bhl/db/tab_office_record_manager.dart';

import 'package:mdc_bhl/page/record/item//task_office_record_second_item.dart';

class TaskOfficeRecordItem extends StatefulWidget {
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
  final List<TabOfficeRecordModel> taskModels;

  TaskOfficeRecordItem({this.recordType, this.dateTitle, this.taskModels});

  @override
  createState() {
      return OfficeTaskRecordItemsState(this.taskModels);
  }
}

// Office
class OfficeTaskRecordItemsState extends State<TaskOfficeRecordItem> {
  List<TabOfficeRecordModel> _taskModels = []; // 展示内容

  OfficeTaskRecordItemsState(this._taskModels);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.white,
        elevation: 0.0,
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(3.0)), // 圆角
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Text(widget.dateTitle, style: TextStyle(fontSize: 14.0)),
              SizedBox(height: 10),
              ListView.builder(
                itemBuilder: (context, index) {
                  TabOfficeRecordModel model = _taskModels[index];
                  return TaskofficeRecordSecondItem(model);
                },
                itemCount: _taskModels.length,
                physics: const AlwaysScrollableScrollPhysics(),
                // controller: _scrollController,
              ),
            ],
          ),
        ));
  }
}

