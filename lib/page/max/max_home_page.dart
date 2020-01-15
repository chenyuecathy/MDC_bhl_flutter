
import 'package:flutter/material.dart';
import 'package:mdc_bhl/widget/gradient_appbar.dart';
import 'package:mdc_bhl/model/media_data.dart';

import 'max_item_page.dart';

/* 大图展示页（图片+视频） */
class MaxHomePage extends StatefulWidget {
  final List<MediaModel> mediaModels;
  final int initialIndex;

  MaxHomePage(this.mediaModels, this.initialIndex);

  @override
  State<StatefulWidget> createState() => new MaxHomePageState();
}

class MaxHomePageState extends State<MaxHomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int currentIndex;

  @override
  void initState() {
    currentIndex = widget.initialIndex;
    super.initState();
    _tabController = new TabController(
        initialIndex: widget.initialIndex,
        vsync: this,
        length: widget.mediaModels.length);
    _tabController.addListener(() {
      setState(() {
        currentIndex = _tabController.index;
        print(currentIndex);
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
                    child: Center(child: Text(_getTitle())))),
            actions: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: Center(
                      child: Text(
                          "${currentIndex + 1}/${widget.mediaModels.length}",
                          style: TextStyle(fontSize: 16))))
            ]),
        body: new TabBarView(controller: _tabController, children: _getItem()));
  }

  String _getTitle() {
    MediaType type = widget.mediaModels[currentIndex].type;
    if (type == MediaType.MediaVideo) {
      return "视频";
    } else {
      return "图片";
    }
  }

  List<Widget> _getItem() {
    List<Widget> list = [];
    for (MediaModel item in widget.mediaModels) {
      list.add(MaxItemPage(item));
    }
    return list;
  }
}
