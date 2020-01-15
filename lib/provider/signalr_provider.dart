import 'package:flutter/material.dart';
import 'package:signalr_client/signalr_client.dart';
import 'package:signalr_client/hub_connection.dart';

class SignalRProvider with ChangeNotifier {
  String serverUrl = 'http://123.146.225.94:9709/SignalRService'; // 服务器端发送即时通信的url
  String serverMethod = "XHSLL"; // 服务器端发送即时通信的方法
  String clientResult = '';
  SignalRProvider() {
    print("即时通信开始");
    HubConnection conn = HubConnectionBuilder().withUrl(serverUrl).build();
    conn.start();
    conn.on(serverMethod, (message) {
      print("有推送进入：${message.first.toString()}");
      clientResult = message.first.toString();
      notifyListeners();
    });
  }
}
