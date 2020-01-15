import 'dart:io';

import 'package:flutter/material.dart';

class MaxImgItemPage extends StatefulWidget {
  File _imageFile;

  MaxImgItemPage(this._imageFile);

  @override
  State<StatefulWidget> createState() => new MaxImgItemPageState();
}

class MaxImgItemPageState extends State<MaxImgItemPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: FileImage(widget._imageFile),
                fit: BoxFit.fill
            )
        )
    );
  }
}