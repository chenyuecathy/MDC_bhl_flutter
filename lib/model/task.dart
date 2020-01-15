class TaskModel {
  String id;   /// 巡查内容id
  String xcnr; /// 巡查内容
  int nrlx;    /// 巡查内容类型  0-正常异常 1-温湿度 2-开关 3-有无 4-录入


  @override
  String toString() {
    return 'TaskModel{id: $id, xcnr: $xcnr, nrlx: $nrlx}';
  }

  TaskModel({this.id, this.xcnr, this.nrlx});

  TaskModel.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    xcnr = json['Xcnr'];
    nrlx = json['Nrlx'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Xcnr'] = this.xcnr;
    data['Nrlx'] = this.nrlx;
    return data;
  }
}
