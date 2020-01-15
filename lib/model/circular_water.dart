class CircularWater {
  String cjsj; // 采集时间
  String rsl; // 入水量
  String csl; //出水量

  CircularWater.fromJson(Map<String, dynamic> json) {
    cjsj = json['JCSJ'];
    rsl = json['RSL'];
    csl = json['CSL'];
  }

  @override
  String toString() {
    return 'CircularWater{cjsj: $cjsj, rsl: $rsl, csl: $csl}';
  }
}
