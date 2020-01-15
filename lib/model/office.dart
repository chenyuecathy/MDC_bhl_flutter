class OfficeModel {
  String id;
  String cjdmc;
  int sx;
  int zt;
  String isEditing;

  @override
  String toString() {
    return 'OfficeModel{Id: $id, Cjdmc: $cjdmc, Sx: $sx, Zt: $zt,isEditing: $isEditing}';
  }

  OfficeModel({this.id, this.cjdmc, this.sx,this.zt,this.isEditing});

  OfficeModel.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    cjdmc = json['Cjdmc'];
    sx = json['Sx'];
    zt = json['Zt'];
    isEditing = '0';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Cjdmc'] = this.cjdmc;
    data['Sx'] = this.sx;
    data['Zt'] = this.zt;
    data['isEditing'] = this.isEditing;
    return data;
  }

}