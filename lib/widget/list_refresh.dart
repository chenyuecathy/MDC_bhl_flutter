
import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

class ListRefresh extends StatefulWidget {

  final renderItem;  /// item函数
  final requestAPI;  /// 请求API。 实际是个map
  final headView;    /// 焦点图函数

  ListRefresh([this.requestAPI,this.renderItem,this.headView]) : super();

  _ListRefreshState createState() => _ListRefreshState();
}

class _ListRefreshState extends State<ListRefresh> {

  bool isFetching = false;
  // bool _hasMore = true;

  // int _currentPageIndex = 0;
  // int _totalPageIndex = 0;

  List taskList = new List();
  // ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    // _fetchMoreData();

    // _scrollController.addListener((){
    //   if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
    //     _fetchMoreData();
    //   }
    // });

  }

  /// pull down refresh
  Future<Null> _refresh() async{
    // _currentPageIndex = 0;
    List newTaskList = await _fetchDataFromNet();
    if (this.mounted) {
      setState(() {
        taskList.clear();
        taskList.addAll(newTaskList);
        isFetching = false;
        // _hasMore = true;
        return null;
      });
    }
  }

  // /// pull up refresh
  // Future _fetchMoreData() async{
  //   if (!isFetching /*&& _hasMore*/) {
  //      // 如果上一次异步请求数据完成 同时有数据可以加载
  //     if (mounted) {  // mounted即Flutter内置的当前控件的状态标识
  //       setState(()=> isFetching = true);
  //     }

  //     List newDynamicList = await _fetchDataFromNet();
  //     _hasMore = (_currentPageIndex <= _totalPageIndex);
  //     if (this.mounted) {
  //       setState((){
  //         taskList.addAll(newDynamicList);
  //         isFetching = false;
  //       });
  //     }
  //   }
  //   else if(!isFetching && !_hasMore){
  //     _currentPageIndex = 0;  
  //   }
  // }

  // 获取网络数据
  Future<List> _fetchDataFromNet() async {
    if (widget.requestAPI is Function) {  // requestAPI 是个map
      final listObj = await widget.requestAPI({'pageIndex': 0/*_currentPageIndex*/});  // page++ 在调用页执行
      // _currentPageIndex = listObj['pageIndex'];
      // _totalPageIndex = listObj['total'];
      return listObj['list'];  
    } else {
      return Future.delayed(Duration(seconds: 2), () {
        return [];
      });
    }
  }

  // // 提示框
  // Widget _buildLoadText(){
  //   return Container(
  //     child: Padding(
  //       padding: const EdgeInsets.all(18.0),
  //       child: Center(
  //         child: Text('oops,has no more date!'),
  //       ),
  //     ),
  //   );
  // }

  // // 加载更多 Widget
  // Widget _buildProgressIndicator() {
  //   if (_hasMore) {
  //     return Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Center(
  //         child: Column(
  //           children: <Widget>[
  //             Opacity(
  //               opacity: isFetching?1.0:0.0,
  //               child: CircularProgressIndicator(  // 转圈提示
  //                 valueColor: AlwaysStoppedAnimation(Colors.blue),
  //               ),
  //             ),
  //             const SizedBox(height: 10.0),
  //             Text(
  //               '稍等片刻即精彩',
  //               style: TextStyle(fontSize: 14.0),
  //             )
  //           ],
  //         ),
  //       ),
  //     );
  //   } else {
  //     return _buildLoadText();
  //   }
  // }

  @override
  void dispose() {
    super.dispose();
    // _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        itemCount: taskList.length,
        itemBuilder: (context,index){

          ///焦点图
          if (index == 0 && index != taskList.length) {
            if (widget.headView is Function) {
              return widget.headView();
            }else{
              return Container(height: 0);
            }
          }

          
          // if (index == taskList.length) {
          //   return _buildProgressIndicator();  ///加载更多提示
          // } else {
            if (widget.renderItem is Function) {
              return widget.renderItem(index,taskList[index]);
            }
          // }

           return Container(height: 0);

        },
        // controller: _scrollController,
      ),
      
    );
  }
}