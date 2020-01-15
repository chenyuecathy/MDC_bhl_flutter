import 'package:flutter/material.dart';
import 'package:mdc_bhl/widget/gradient_appbar.dart';

class  TabBarWidget extends StatefulWidget {
  static const int BOTTOM_TAB = 1;
  static const int TOP_TAB = 2;

  final int type;
  final List<Widget> tabItems;
  final List<Widget> tabViews;

  final Color backgroundColor;
  final Color indicatorColor;

  final Widget title;
  final Widget drawer;
  final Widget floatingActionButton;

  TabBarWidget({
    Key key,
    this.type,
    this.tabItems,
    this.tabViews,
    this.backgroundColor,
    this.indicatorColor,
    this.title,
    this.drawer,
    this.floatingActionButton,
  }) : super(key: key);

  _TabBarState createState() => _TabBarState(type, tabItems, tabViews,
      backgroundColor, indicatorColor, title, drawer, floatingActionButton);
}

class _TabBarState extends State<TabBarWidget>
    with SingleTickerProviderStateMixin {
  // 通过 with SingleTickerProviderStateMixin 实现动画效果。

  final int _type;
  final List<dynamic> _tabItems;
  final List<Widget> _tabViews;

  final Color _backgroundColor;
  final Color _indicatorColor;

  final Widget _title;
  final Widget _drawer;
  final Widget _floatingActionButton;

  TabController _tabController;

  // state构造函数
  _TabBarState(
      this._type,
      this._tabItems,
      this._tabViews,
      this._backgroundColor,
      this._indicatorColor,
      this._title,
      this._drawer,
      this._floatingActionButton)
      : super();

  @override
  void initState() {
    super.initState();

    // 初始化时创建控制器
    _tabController = new TabController(vsync: this, length: _tabItems.length);
  }

  @override
  void dispose() {
    _tabController.dispose(); //页面销毁时，销毁控制器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /** tabBar控件
     * 实现方式：Scaffold + AppBar+ TabBar + TabbarView 
    */

    /* 底部Tabbar */
    if (this._type == TabBarWidget.BOTTOM_TAB) {
      return Scaffold(
        // 设置侧边滑出 drawer，不需要可以不设置
        drawer: _drawer,
        // 设置悬浮按键，不需要可以不设置
        floatingActionButton: _floatingActionButton,

        body: TabBarView(
          controller: _tabController,
          children: _tabViews,
          physics: NeverScrollableScrollPhysics(), //禁止滑动
        ),

        // 底部导航栏，也就是tab栏
        bottomNavigationBar: Material(
          color: _backgroundColor,
          child: TabBar(
            controller: _tabController,
            tabs: _tabItems, // 每一个tab item，是一个List<Widget>
            indicatorColor: _indicatorColor, // tabbar底部选中条颜色
            indicatorWeight: 0.1, // tabbar选中条高度
          ),
        ),
      );
    }

    /* 头部Tabbar */
    return Scaffold(
      // 设置侧边滑出 drawer，不需要可以不设置
      drawer: _drawer,

      // 设置悬浮按键，不需要可以不设置
      floatingActionButton: _floatingActionButton,

      // 标题栏
      appBar: GradientAppBar(
        gradientStart: Color(0xFF2171F5),
        gradientEnd: Color(0xFF49A2FC),
        // backgroundColor: _backgroundColor,
        title: _title,

      // tabBar控件
        bottom: TabBar(
          // 顶部时，tabBar为可以滑动的模式
          isScrollable: true,

          // 必须有的控制器，与pageView的控制器同步
          controller: _tabController,

          // 每一个tab item，是一个List<Widget>
          tabs: _tabItems,

          // tab底部选中条颜色
          indicatorColor: _indicatorColor,
          labelStyle: TextStyle(fontSize: 16),
        ),
      ),

// // 标题栏
//       appBar: PreferredSize(
//         preferredSize:  Size(MediaQuery.of(context).size.width, 45),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Color(0xFF2171F5), Color(0xFF49A2FC)],
//             ),
//           ),
//           child: AppBar(
//             // backgroundColor: _backgroundColor,
//             title: _title,
//             // tabBar控件
//             bottom: TabBar(
//               // 顶部时，tabBar为可以滑动的模式
//               isScrollable: true,

//               // 必须有的控制器，与pageView的控制器同步
//               controller: _tabController,

//               // 每一个tab item，是一个List<Widget>
//               tabs: _tabItems,

//               // tab底部选中条颜色
//               indicatorColor: _indicatorColor,
//             ),
//           ),
//         ),

//       ),

      body: TabBarView(
        controller: _tabController,
        children: _tabViews,
      ),
    );
  }
}
