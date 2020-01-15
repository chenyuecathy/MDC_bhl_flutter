import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mdc_bhl/widget/gradient_appbar.dart';

import 'max_img_item_page.dart';

/* 大图展示页（图片） */
class MaxImgHomePage extends StatefulWidget {
  List<File> _imageFiles;
  int _index;

  MaxImgHomePage(this._imageFiles, this._index);

  @override
  State<StatefulWidget> createState() => new MaxImgHomePageState();
}

class MaxImgHomePageState extends State<MaxImgHomePage> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(initialIndex: widget._index, vsync: this, length: widget._imageFiles.length);
    _tabController.addListener(() {
      setState(() {
        widget._index = _tabController.index;
        print(widget._index);
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new GradientAppBar(
            gradientStart: Color(0xFF2171F5),
            gradientEnd: Color(0xFF49A2FC),
            title: Container(
                padding: EdgeInsets.only(right: 50),
                child: Padding(
                    padding: EdgeInsets.only(left: 30),
                    child: Center(
                        child: Text("图片")
                    )
                )
            ),
            actions: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: Center(
                      child: Text("${widget._index + 1}/${widget._imageFiles.length}",
                          style: TextStyle(fontSize: 16)
                      )
                  )
              )
            ]
        ),
        body: new TabBarView(
          controller: _tabController,
          children: _getItem(),
        )
    );
  }

  List<Widget> _getItem() {
    List<Widget> list = [];
    for (var item in widget._imageFiles) {
      list.add(MaxImgItemPage(item));
    }
    return list;
  }
}