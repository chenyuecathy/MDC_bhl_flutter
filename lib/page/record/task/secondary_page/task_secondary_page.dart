import 'package:flutter/material.dart';
import 'package:mdc_bhl/common/config/style.dart';
import 'package:mdc_bhl/db/tab_device_record_manager.dart';
import 'package:mdc_bhl/page/record/task/secondary_page/task_secondary_item.dart';
import 'package:mdc_bhl/widget/blank_widget.dart';
import 'package:mdc_bhl/widget/gradient_appbar.dart';

/* 设备科、保卫科二级界面 */
class TaskSecondaryPage extends StatefulWidget {
  String _inspectionId;
  String _inspectionContentId;

  TaskSecondaryPage(this._inspectionId, this._inspectionContentId);

  @override
  State<StatefulWidget> createState() => new TaskSecondaryPageState(_inspectionId, _inspectionContentId);
}

class TaskSecondaryPageState extends State<TaskSecondaryPage> {
  String _inspectionId;
  String _inspectionContentId;

  TaskSecondaryPageState(this._inspectionId, this._inspectionContentId) {
    initData();
  }

  List<TabDeviceRecordModel> _tabDeviceRecordModelList = new List();

  initData() async {
    TabDeviceRecordManager _tabDeviceRecordManager = new TabDeviceRecordManager();
    List<TabDeviceRecordModel> tabDeviceRecordModelList = await _tabDeviceRecordManager.queryByInspectionIdAndInspectionContentId(_inspectionId, _inspectionContentId);
    setState(() {
      for (var item in tabDeviceRecordModelList) {
        if (item.recordType != -1) {  // 消除未操作记录
          _tabDeviceRecordModelList.add(item);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(
            gradientStart: Color(0xFF2171F5),
            gradientEnd: Color(0xFF49A2FC),
            leading: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pop(context, "未保存");
                },
                child: Icon(Icons.chevron_left, size: 30)
            ),
            title: Text("我的任务",
                style: TextStyle(fontSize: FontConfig.naviTextSize)),
            centerTitle: true),
        body: _tabDeviceRecordModelList.length == 0
            ? BlankWidget(false)
            : ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            TabDeviceRecordModel tabDeviceRecordModel =
            _tabDeviceRecordModelList[index];
            return TaskSecondaryItem(tabDeviceRecordModel);
          },
          itemCount: _tabDeviceRecordModelList.length,
          // separatorBuilder: (context,index)=>Divider(),
          physics: const AlwaysScrollableScrollPhysics(),
        ));
  }


  /// 获取列表项总数
  int _getItemCount() {
    int length = 1;
    (_tabDeviceRecordModelList.length != 0)
        ? length = _tabDeviceRecordModelList.length
        : length = 1;
    return length;
  }
}
