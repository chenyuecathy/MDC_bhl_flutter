import 'package:flutter/material.dart';

class PreventDoubleTap extends StatefulWidget {
  @override
  PreventDoubleTapState createState() {
    return new PreventDoubleTapState();
  }
}

class PreventDoubleTapState extends State<PreventDoubleTap> {
  //boolean value to determine whetherbutton is tapped
  bool _isButtonTapped = false;

  _onTapped() {
    setState(() => _isButtonTapped =
        !_isButtonTapped); //tapping the button once, disables the button from being tapped again
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prevent Double Tap'),
      ),
      body: Center(
        child: RaisedButton(
          color: Colors.red,
          child: Text('Tap Once'),
          onPressed: _isButtonTapped
              ? null
              : _onTapped, //if button hasnt being tapped, allow user tapped. else, dont allow
        ),
      ),
    );
  }
}