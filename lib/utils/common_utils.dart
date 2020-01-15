import 'dart:core';

import 'package:flutter/material.dart';
import 'package:mdc_bhl/common/config/style.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mdc_bhl/widget/issue_edit_dIalog.dart';

enum SpinKitType {
  SpinKit_Circle,
  SpinKit_CubeGrid,
  SpinKit_FoldingCube,
  SpinKit_SpinningCircle,
}

class CommonUtils {
  /*  Toast */
  //  default text toast

  static showTextToast(String text) {
    showToast(
      text,
      duration: Duration(seconds: 2),
      position: ToastPosition.bottom,
      backgroundColor: Colors.black.withOpacity(0.8),
      radius: 3.0,
      textStyle: TextStyle(fontSize: 16.0),
      // dismissOtherToast: true
    );
  }

  static showTopTextToast(String text) {
    showToast(
      text,
      duration: Duration(seconds: 2),
      position: ToastPosition.top,
      backgroundColor: Colors.black.withOpacity(0.8),
      radius: 3.0,
      textStyle: TextStyle(fontSize: 16.0),
      // dismissOtherToast: true
    );
  }

  static showCenterTextToast(String text) {
    showToast(
      text,
      duration: Duration(seconds: 2),
      position: ToastPosition.center,
      backgroundColor: Colors.black.withOpacity(0.8),
      radius: 3.0,
      textStyle: TextStyle(fontSize: 16.0),
      // dismissOtherToast: true
    );
  }

  static Widget _customWidget(String text, IconData iconData) {
    return Center(
        child: Container(
      padding: const EdgeInsets.all(30),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(5.0),
      //   color: Colors.black.withOpacity(0.7)
      // ),
      color: Colors.black.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          Icon(
            iconData,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(text, style: TextStyle(color: Colors.white, fontSize: 16.0))
        ],
        mainAxisSize: MainAxisSize.min,
      ),
    ));
  }

  static showSuccessToast(String text) {
    showToastWidget(_customWidget(text, Icons.done));
  }

  static showFailedToast(String text) {
    showToastWidget(
      _customWidget(text, Icons.clear),
      duration: Duration(seconds: 2),
    );
  }

  /// 弹出 dialog
  static Future<T> showGXDialog<T>({
    @required BuildContext context,
    bool barrierDismissible = true,
    WidgetBuilder builder,
  }) {
    return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) {
          return MediaQuery(

              ///不受系统字体缩放影响
              data: MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                  .copyWith(textScaleFactor: 1),
              child: new SafeArea(child: builder(context)));
        });
  }

  /// Loading Dialog
  static Future<Null> showLoadingDialog(
      BuildContext context, String text, SpinKitType type) {
    return showGXDialog(
        context: context,
        builder: (BuildContext context) {
          return new Material(
              color: Colors.transparent,
              child: WillPopScope(
                onWillPop: () => new Future.value(false),
                child: Center(
                  child: new Container(
                    width: 200.0,
                    height: 200.0,
                    padding: new EdgeInsets.all(4.0),
                    decoration: new BoxDecoration(
                      color: Colors.transparent,
                      //用一个BoxDecoration装饰器提供背景图片
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    ),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Container(child: buildSpinKit(type)),
                        new Container(height: 10.0),
                        new Container(
                            child: new Text(text,
                                style: FontConfig.normalTextWhite)),
                      ],
                    ),
                  ),
                ),
              ));
        });
  }

/*
enum SpinKitType {
  SpinKit_Circle,
  SpinKit_CubeGrid,
  SpinKit_FoldingCube,
  SpinKit_SpinningCircle,
} */
  static buildSpinKit(SpinKitType type) {
    if (type.index == 0) {
      return SpinKitCircle(color: Color(ColorConfig.white));
    } else if (type.index == 1) {
      return SpinKitCubeGrid(color: Color(ColorConfig.white));
    } else if (type.index == 2) {
      return SpinKitFoldingCube(color: Color(ColorConfig.white));
    } else {
      return SpinKitFadingCircle(color: Color(ColorConfig.white));
    }
  }

  static Future<Null> showEditDialog(
    BuildContext context,
    String dialogTitle,
    ValueChanged<String> onTitleChanged, //(title) {}
    ValueChanged<String> onContentChanged, //
    VoidCallback onPressed, {
    TextEditingController titleController,
    TextEditingController valueController,
    bool needTitle = true,
  }) {
    return showGXDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: new IssueEditDialog(
              dialogTitle,
              onTitleChanged,
              onContentChanged,
              onPressed,
              titleController: titleController,
              valueController: valueController,
              needTitle: needTitle,
            ),
          );
        });
  }

  //  _showEditDialog(String title, String value, String key, int index) {
  //   String content = value ?? "";
  //   CommonUtils.showEditDialog(context, title, (title) {}, (res) {
  //     content = res;
  //     if (index == 1) {
  //       _newUseInfoMap['REALNAME'] = res;
  //     } else if (index == 3) {
  //       _newUseInfoMap['MOBILE'] = res;
  //     }
  //     print(content);
  //   }, () {
  //     if (content == null || content.length == 0) {
  //       return;
  //     }

  //     Navigator.of(context).pop();
  //   },
  //       titleController: new TextEditingController(),
  //       valueController: new TextEditingController(text: value),
  //       needTitle: false);
  // }

  static Future<Null> showAlertDialog(BuildContext context, String dialogTitle,
      String dialogContent, VoidCallback onPressed) {
    return showGXDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(dialogTitle),
            content: Text(dialogContent),
            actions: <Widget>[
              FlatButton(
                  child: Text('确定'),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  static Future<int> showMultiAlertDialog(BuildContext context,
      String dialogTitle, String dialogContent, List<String> buttons) async {
    assert(buttons.length >= 0);

    List<Widget> flatButtons = [];
    for (int i = 0; i < buttons.length; i++) {
      flatButtons.add(FlatButton(
          child: Text(buttons[i]),
          onPressed: () {
            Navigator.pop(context, i);
            // return i;
          }));
    }

    if (dialogContent == null || dialogContent.isEmpty) {
      return showGXDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(dialogTitle),
              actions: flatButtons,
            );
          });
    } else {
      return showGXDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(dialogTitle),
              content: Text(dialogContent),
              actions: flatButtons,
            );
          });
    }
  }
}
