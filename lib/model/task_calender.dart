import 'dart:core';

class TaskCalendar {
  int xclx;
  int bclx;
  String bclxMc;
  String xcjlid;
  String cjsj;
  String xckssj;
  String xcjssj;

  TaskCalendar({this.xclx, this.bclx, this.xcjlid, this.cjsj, this.xckssj, this.xcjssj});

  TaskCalendar.fromJson(Map<String, dynamic> json) {
    xclx = json['Xclx'];
    bclx = json['Bclx'];
    bclxMc = json['BclxMc'];
    xcjlid = json['Xcjlid'];
    cjsj = json['Cjsj'];
    xckssj = json['Xckssj'];
    xcjssj = json['Xcjssj'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Xclx'] = this.xclx;
    data['Bclx'] = this.bclx;
    data['BclxMc'] = this.bclxMc;
    data['Xcjlid'] = this.xcjlid;
    data['Cjsj'] = this.cjsj;
    data['Xckssj'] = this.xckssj;
    data['Xcjssj'] = this.xcjssj;
    return data;
  }

  String toCustomString(){
    String string = ' 巡查班次:${this.bclxMc}\n';
    // switch (this.bclx.toString() ) {
    //   case '0':
    //     string = ' 巡查班次: 早班\n';
    //     break;

    //   case '1':
    //     string = ' 巡查班次: 中班\n';
    //     break;

    //   case '2':
    //     string = ' 巡查班次: 晚班\n';
    //     break;

    //   case '3':
    //     string = ' 巡查班次: 白班\n';
    //     break;

    //   case '4':
    //     string = ' 巡查班次: 夜班\n';
    //     break;
    //   default:
    // }
    return string + ' 巡查开始时间: ${this.xckssj}\n 巡查结束时间: ${this.xcjssj} ';
  }
}