import 'package:flutter/material.dart';
import 'package:mdc_bhl/db/tab_office_record_manager.dart';
import 'package:mdc_bhl/page/office/office_info_page.dart';
import 'package:mdc_bhl/model/office.dart';
import 'package:uuid/uuid.dart';


class TaskOfficeItem extends StatelessWidget {
  final OfficeModel officeModel;

  TaskOfficeItem(this.officeModel);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
            /// 赋值
            TabOfficeRecordModel officeRecordModel = TabOfficeRecordModel();
            officeRecordModel.collectionName = officeModel.cjdmc;
            officeRecordModel.collectionId = officeModel.id;
            officeRecordModel.id = Uuid().v1();
            officeRecordModel.areaCount = 0;
            officeRecordModel.crowdLevel = 4;
            return OfficeInfoPage(officeRecordModel);
          }));
        },
        child: Card(
            color: Colors.white,
            // 卡片背景颜色
            elevation: 2.0,
            // 卡片的z坐标,控制卡片下面的阴影大小
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)), // 圆角
            ),
            child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 0, bottom: 0, left: 7, right: 0),
                        child: Text(officeModel.cjdmc,
                            textAlign: TextAlign.left,
                            style:
                                TextStyle(color: Colors.black, fontSize: 15.0)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("采集客流高峰照片",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Colors.blueGrey, fontSize: 14.0)),
                      )
                    ]))));
  }
}
