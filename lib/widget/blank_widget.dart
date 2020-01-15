import 'package:flutter/material.dart';

class BlankWidget extends StatelessWidget {
  final bool showButton;

  final ValueChanged<String> onClickButton;

  const BlankWidget(this.showButton, {this.onClickButton});

  @override
  Widget build(BuildContext context) {
    if (showButton) {
      return Container(
          alignment: Alignment.center,
          child: Container(
            height: 198,
            child: Column(
              children: <Widget>[
                Image.asset('images/no_data.png',
                    width: 120.0, height: 120.0, repeat: ImageRepeat.noRepeat),
                SizedBox(height: 30),
                RaisedButton(
                  padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0), //默认高度48
                  onPressed: () {
                    onClickButton('onValueChange');
                  },
                  child: Text('点我重新加载'),
                  color: Colors.white,
                  textColor: Colors.grey,
                  splashColor: Colors.black38,
                )
              ]
            )
          )
      );
    } else {
      return Container(
          alignment: Alignment.center,
          child: Container(
            height: 120,
            child: Column(
              children: <Widget>[
                // SizedBox(height: 200),
                Image.asset('images/no_data.png',
                    width: 120.0, height: 120.0, repeat: ImageRepeat.noRepeat),
              ]
            )
          )
      );
    }
  }
}