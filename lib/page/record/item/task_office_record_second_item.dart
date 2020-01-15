import 'package:flutter/material.dart';
import 'package:mdc_bhl/db/tab_office_record_manager.dart';
import 'package:mdc_bhl/page/office/office_info_page.dart';

class TaskofficeRecordSecondItem extends StatefulWidget {
  final TabOfficeRecordModel tabDeviceRecordModel;

  TaskofficeRecordSecondItem(this.tabDeviceRecordModel);

  @override
  createState() {
    return new TaskofficeRecordSecondItemState(tabDeviceRecordModel);
  }
}

class TaskofficeRecordSecondItemState extends State<TaskofficeRecordSecondItem> {
  TabOfficeRecordModel _tabOfficeRecordModel;

  TaskofficeRecordSecondItemState(this._tabOfficeRecordModel);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
                   Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return OfficeInfoPage(_tabOfficeRecordModel);
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
                                Text(_tabOfficeRecordModel.collectionName,
                                    style: TextStyle(fontSize: 16)),
                                const SizedBox(height: 3.0), // 占位图
                                Text(_tabOfficeRecordModel.time,
                                    style: TextStyle(
                                        color: Color(0xFF808080),
                                        fontSize: 14))
                              ]),
                          flex: 1),
                      Expanded(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text('2019-09-05'),
                                Text('已处置')
                              ]),
                          flex: 1)
                    ])),
            Divider()
          ],
        ));
  }

 
}
