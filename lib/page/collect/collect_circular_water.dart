import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mdc_bhl/common/net/address.dart';
import 'package:mdc_bhl/model/circular_water.dart';
import 'package:mdc_bhl/provider/signalr_provider.dart';
import 'package:mdc_bhl/utils/net_utils.dart';
import 'package:provider/provider.dart';

/* 循环水页面 */
class CollectCircularWaterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CollectCircularWaterPageState();
}

class CollectCircularWaterPageState extends State<CollectCircularWaterPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // StreamSubscription subscription;

  String waterIntakeValue = "0";
  String waterOutakeValue = "0";

  // 主动获取循环水数据（首次加载）
  _getCircularWater() async {
    var circularWaterURL = Address.getCircularWater();
    var response = await NetUtils.get(circularWaterURL);
    print("主动获取循环水数据（首次加载）:$response");
    Map<String, dynamic> responseDictionary = json.decode(response);
    dynamic rsl = responseDictionary['RESULTVALUE'][0]['RSL'];
    dynamic csl = responseDictionary['RESULTVALUE'][0]['CSL'];
    setState(() {
      waterIntakeValue = rsl.toString();
      waterOutakeValue = csl.toString();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 主动获取循环水数据（首次加载）
    _getCircularWater();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    String nowTime = DateTime.now().toString();

    SignalRProvider provider = Provider.of<SignalRProvider>(context);
    String result = provider.clientResult;
//    http://123.146.225.94:9709/swagger/index.html
//    PostData方法：
//    XHSLL
//    result = "[{\"JCSJ\":\"2019-11-22 16:23:30\",\"RSL\":5.6,\"CSL\":7.8}]";
    if (result != '') {
      CircularWater circularWater = CircularWater.fromJson(json.decode(result)[0]);
      waterIntakeValue = circularWater.rsl.toString();
      waterOutakeValue = circularWater.csl.toString();
      nowTime = DateTime.now().toString();
    }
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(children: <Widget>[
          Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
            Container(
                height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 3.5 - 150,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(bottom: 60),
                        child: Column(children: <Widget>[
                          Text(nowTime.substring(0, 4) + "年" + int.parse(nowTime.substring(5, 7)).toString() + "月" + int.parse(nowTime.substring(8, 10)).toString() + "日", style: TextStyle(fontSize: 17)),
                          Text(nowTime.substring(11, 19), style: TextStyle(fontSize: 17))
                        ])),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(width: (MediaQuery.of(context).size.width - 109.5) / 2), // 占位图
                            Image.asset('images/ic_water_outake.png', height: 68, width: 109.5, fit: BoxFit.fill),
                            Container(
                                width: (MediaQuery.of(context).size.width - 109.5) / 2,
                                child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                                  Container(margin: EdgeInsets.only(left: 5, right: 5), child: Text("出水量", textAlign: TextAlign.end)),
                                  Container(child: Text(waterOutakeValue + "m³/h", style: TextStyle(color: Color(0XFF2196f3), fontSize: 18)))
                                ]))
                          ],
                        )),
                    Container(
                        margin: EdgeInsets.only(top: 20),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                width: (MediaQuery.of(context).size.width - 109.5) / 2,
                                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                                  Container(child: Text("入水量", textAlign: TextAlign.end)),
                                  Container(margin: EdgeInsets.only(left: 5, right: 10), child: Text(waterIntakeValue + "m³/h", style: TextStyle(color: Color(0XFF2196f3), fontSize: 18)))
                                ])),
                            Image.asset('images/ic_water_intake.png', height: 68, width: 109.5, fit: BoxFit.fill),
                            SizedBox(width: (MediaQuery.of(context).size.width - 109.5) / 2) // 占位图
                          ],
                        ))
                  ],
                )),
            Image.asset('images/circular_water_bg.png', height: MediaQuery.of(context).size.height / 3.5, width: MediaQuery.of(context).size.width, fit: BoxFit.fill)
          ])
        ]));
  }
}
