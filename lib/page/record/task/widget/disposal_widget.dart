import 'dart:core';

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
// import 'package:date_format/date_format.dart';

import 'package:mdc_bhl/common/config/style.dart';

// const String MIN_DATETIME = '2010-05-12';
// const String MAX_DATETIME = '2021-11-25';
// const String INIT_DATETIME = '2019-05-17';

class DisposalModel {
  String date; // 处置时间
  String method; // 处置方法
  String disposer; // 处置人

  DisposalModel({this.date = '2000-01-01', this.method, this.disposer});
}

class DisposalWidget extends StatefulWidget {
  final int disposalState; // 0 未处置  1 已处置
  final DisposalModel disposalModel;

  final ValueChanged<DisposalModel> onClickDisposal;
  // final VoidCallback callback;

  DisposalWidget(this.disposalState,
      {this.disposalModel, this.onClickDisposal, Key key})
      : super(key: key);

  _DisposalWidgetState createState() =>
      _DisposalWidgetState(this.disposalModel);
}

class _DisposalWidgetState extends State<DisposalWidget> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _methodController = TextEditingController();
  final TextEditingController _disposerController = TextEditingController();

  FocusScopeNode _focusScopeNode = FocusScopeNode();

  FocusNode _methodFocusNode = FocusNode();
  FocusNode _disposerFocusNode = FocusNode();
  FocusNode _dateFocusNode = FocusNode();

  DisposalModel _disposalModel;

  DateTimePickerLocale _locale = DateTimePickerLocale.zh_cn;
  String _format = 'yyyy-MMMM-dd';

  _DisposalWidgetState(this._disposalModel);

  @override
  void initState() {
    setState(() {
      _dateController.text = _disposalModel.date;
      _methodController.text = _disposalModel.method;
      _disposerController.text = _disposalModel.disposer;
    });

    if (_disposalModel == null) {
      _disposalModel = DisposalModel();
    }
    super.initState();
  }

  List<Widget> buildRow(TextEditingController textfieldController,
      FocusNode focusNode, String title, int line) {
    List<Widget> widgets = [];
    Expanded titleExpanded = Expanded(
      child: Text(title,
          style: TextStyle(
              color: const Color(ColorConfig.darkTextColor),
              fontSize: FontConfig.titleTextSize)),
      flex: 1,
    );
    Expanded content = Expanded(
      child: Container(
          // margin: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: const Color(ColorConfig.borderColor), width: 0.5),
              borderRadius: BorderRadius.circular(3)),
          child: TextFormField(
            controller: textfieldController,
            focusNode: focusNode,
            // autofocus: true,
            autocorrect: true,
            maxLength: line == 1 ? null : 200,
            enabled: widget.disposalState == 0 ? true : false,
            style: TextStyle(
                color: const Color(ColorConfig.darkTextColor),
                fontSize: FontConfig.contentTextSize),
            decoration: const InputDecoration(
                fillColor: Colors.white,
                // labelText: hint,
                contentPadding: const EdgeInsets.all(10.0),
                border: InputBorder.none),
            maxLines: line,
            onEditingComplete: () {
              if (_focusScopeNode == null) {
                _focusScopeNode = FocusScope.of(context);
              }
              _focusScopeNode.requestFocus(_disposerFocusNode);
            },
          )),
      flex: 3,
    );
    widgets.add(titleExpanded);
    widgets.add(content);
    return widgets;
  }

  List<Widget> buildDateRow(BuildContext context, String title, int line) {
    List<Widget> widgets = [];
    Expanded titleExpanded = Expanded(
      child: Text(title,
          style: TextStyle(
              color: const Color(ColorConfig.darkTextColor),
              fontSize: FontConfig.titleTextSize)),
      flex: 2,
    );
    Expanded content = Expanded(
      child: Container(
          // margin: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: const Color(ColorConfig.borderColor), width: 0.5),
              borderRadius: BorderRadius.circular(3)),
          child: TextField(
            controller: _dateController,
            focusNode: _dateFocusNode,
            // autofocus: true,
            // autocorrect: true,
            enabled: false,
            style: TextStyle(
                color: const Color(ColorConfig.darkTextColor),
                fontSize: FontConfig.contentTextSize),
            decoration: const InputDecoration(
                fillColor: Colors.white,
                // labelText: hint,
                contentPadding: const EdgeInsets.all(10.0),
                border: InputBorder.none),
          )),
      flex: 5,
    );
    Expanded btn = Expanded(
      child: GestureDetector(
        onTap: () {
          if (widget.disposalState == 0) _showDatePicker(context);
        },
        child: ImageIcon(AssetImage("images/icon_date_picker.png"),
            size: 30, color: Color(ColorConfig.darkTextColor)),
      ),
      flex: 1,
    );
    widgets.add(titleExpanded);
    widgets.add(content);
    widgets.add(btn);
    return widgets;
  }

  void _showDatePicker(context) {
    DatePicker.showDatePicker(
      context,
      pickerTheme: DateTimePickerTheme(
        // showTitle: _showTitle,
        confirm: Text('确定', style: TextStyle(color: Colors.blue, fontSize: 16)),
        cancel: Text('取消', style: TextStyle(color: Colors.cyan, fontSize: 16)),
      ),
      minDateTime: DateTime(2019, 1, 1),
      maxDateTime: DateTime.now(),
      initialDateTime: convertDateString2DateTime(_disposalModel.date),
      dateFormat: _format,
      locale: _locale,
      // onClose: () => print("----- onClose -----"),
      // onCancel: () => print('onCancel'),
      onChange: (dateTime, List<int> index) {
        _dateController.text = dateTime.toString().substring(0, 10);

        setState(() {
          _disposalModel.date = dateTime.toString().substring(0, 10);
        });
      },
      onConfirm: (dateTime, List<int> index) {
        print(dateTime.toString());
        _dateController.text = dateTime.toString().substring(0, 10);
        setState(() {
          _disposalModel.date = dateTime.toString().substring(0, 10);
        });
      },
    );
  }

  DateTime convertDateString2DateTime(String dateStr) {
    // assert(dateStr.length != 10 && !dateStr.contains('-'), '日期格式不正确');
    String nowStr = DateTime.now().toString().substring(0, 10);
    if (dateStr.length != 10 && !dateStr.contains('-')) {
      dateStr = nowStr;
    }
    print('date' + dateStr + ' / ' + nowStr);
    List dateList = dateStr.split('-');
    // if (dateList.length == 3) {
    return DateTime(
      int.parse(dateList[0]), //year
      int.parse(dateList[1]), //month
      int.parse(dateList[2]), //day
    );
    // } else {
    //   return DateTime(2019, 1, 1);
    // }
  }

  @override
  Widget build(BuildContext context) {
    var dateRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buildDateRow(context, '处置时间', 1),
    );

    var methodRow = Row(
      children: buildRow(_methodController, _methodFocusNode, '处置方法', 2),
    );

    var disposaldRow = Row(
      children: buildRow(_disposerController, _disposerFocusNode, '处置人', 1),
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: <Widget>[
          // Divider(height: 1),
          // SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'images/ic_disposal.png',
                width: 24,
                height: 24,
              ),
              SizedBox(width: 5),
              Text(
                '异常处置',
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Divider(),
              SizedBox(height: 20),
              dateRow,
              SizedBox(height: 15),
              methodRow,
              SizedBox(height: 15),
              disposaldRow,
              SizedBox(height: 15),
              (widget.disposalState == 0) // 0未核查 1已核查
                  ? FlatButton(
                      color: Colors.blue,
                      textColor: Colors.white,
                      child: Text('处置'),
                      onPressed: () {
                        widget.onClickDisposal(DisposalModel(
                            date: _dateController.text.trim(),
                            method: _methodController.text.trim(),
                            disposer: _disposerController.text.trim()));
                      },
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }
}
