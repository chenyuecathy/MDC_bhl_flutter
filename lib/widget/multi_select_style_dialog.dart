import 'package:flutter/material.dart';
import 'package:flutter_custom_calendar/flutter_custom_calendar.dart';

class MultiSelectStyleDialog extends StatefulWidget {
  CalendarController controller;
  String text = "";

  bool outsideDismiss;
  Function dismissCallback;

  MultiSelectStyleDialog(this.controller,
      {Key key,
        this.outsideDismiss = true,
        this.dismissCallback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => MultiSelectStyleDialogState();
}

class MultiSelectStyleDialogState extends State<MultiSelectStyleDialog> {
  @override
  void initState() {
    widget.text = "${DateTime
        .now()
        .year}年${DateTime
        .now()
        .month}月";

    widget.controller.addMonthChangeListener((year, month) {
      setState(() {
        widget.text = "$year年$month月";
      });
    });

    super.initState();
  }

  _dismissDialog() {
    if (widget.dismissCallback != null) {
      widget.dismissCallback();
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
        onTap: widget.outsideDismiss ? _dismissDialog : null,
        child: Material(
            type: MaterialType.transparency,
            child: new Center(
                child: new SizedBox(
                    width: 300.0,
                    height: 420.0,
                    child: new Container(
                        decoration: ShapeDecoration(
                            color: Color(0xffffffff),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                )
                            )
                        ),
                        child: new SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: new Column(
                                children: <Widget>[
                                  Container(
                                      decoration: ShapeDecoration(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8.0),
                                                topRight: Radius.circular(8.0)
                                            )
                                        ),
                                        gradient: LinearGradient(
                                          colors: const [
                                            Color(0xFF2171F5),
                                            Color(0xFF49A2FC)
                                          ],
                                        ),
                                      ),
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            new IconButton(
                                                icon: Icon(Icons.navigate_before, color: Colors.white),
                                                onPressed: () {
                                                  widget.controller.moveToPreviousMonth();
                                                }),
                                            new Text(widget.text, style: new TextStyle(fontSize: 16, color: Colors.white)),
                                            new IconButton(
                                                icon: Icon(Icons.navigate_next, color: Colors.white),
                                                onPressed: () {
                                                  widget.controller.moveToNextMonth();
                                                }
                                            )
                                          ]
                                      )
                                  ),
                                  CalendarViewWidget(
                                    calendarController: widget.controller,
                                  )
                                ]
                            )
                        )
                    )
                )
            )
        )
    );
  }
}

class CustomStyleWeekBarItem extends BaseWeekBar {
  List<String> weekList = ["一", "二", "三", "四", "五", "六", "日"];

  @override
  Widget getWeekBarItem(int index) {
    return new Container(
        child: new Center(
            child: Column(
                children: <Widget>[
                  SizedBox(height: 10),
                  new Text(weekList[index], style: TextStyle(color: Colors.black)),
                  SizedBox(height: 10)
                ]
            )
        )
    );
  }
}

class CustomStyleDayWidget extends BaseCustomDayWidget {
  CustomStyleDayWidget(DateModel dateModel) : super(dateModel);

  @override
  void drawNormal(DateModel dateModel, Canvas canvas, Size size) {
    bool isInRange = dateModel.isInRange;

    //顶部的文字
    TextPainter dayTextPainter = new TextPainter()
      ..text = TextSpan(
          text: dateModel.day.toString(),
          style: new TextStyle(
              color: !isInRange ? Colors.grey : Colors.blueAccent, fontSize: 14))
      ..textDirection = TextDirection.ltr
      ..textAlign = TextAlign.center;

    dayTextPainter.layout(minWidth: size.width, maxWidth: size.width);
    dayTextPainter.paint(canvas, Offset(0, 6));

    //下面的文字
    TextPainter lunarTextPainter = new TextPainter()
      ..text = new TextSpan(
          text: dateModel.lunarString,
          style: new TextStyle(
              color: !isInRange ? Colors.grey : Colors.blueAccent, fontSize: 10))
      ..textDirection = TextDirection.ltr
      ..textAlign = TextAlign.center;

    lunarTextPainter.layout(minWidth: size.width, maxWidth: size.width);
    lunarTextPainter.paint(canvas, Offset(0, size.height / 2));
  }

  @override
  void drawSelected(DateModel dateModel, Canvas canvas, Size size) {
    //绘制背景
    Paint backGroundPaint = new Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 2;
    double padding = 8;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2),
        (size.width - padding) / 2, backGroundPaint);

    //顶部的文字
    TextPainter dayTextPainter = new TextPainter()
      ..text = TextSpan(
          text: dateModel.day.toString(),
          style: new TextStyle(color: Colors.white, fontSize: 14))
      ..textDirection = TextDirection.ltr
      ..textAlign = TextAlign.center;

    dayTextPainter.layout(minWidth: size.width, maxWidth: size.width);
    dayTextPainter.paint(canvas, Offset(0, 6));

    //下面的文字
    TextPainter lunarTextPainter = new TextPainter()
      ..text = new TextSpan(
          text: dateModel.lunarString,
          style: new TextStyle(color: Colors.white, fontSize: 10))
      ..textDirection = TextDirection.ltr
      ..textAlign = TextAlign.center;

    lunarTextPainter.layout(minWidth: size.width, maxWidth: size.width);
    lunarTextPainter.paint(canvas, Offset(0, size.height / 2));
  }
}