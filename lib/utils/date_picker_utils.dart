import 'package:flutter/material.dart';
// import 'package:flutter_custom_calendar/constants/constants.dart';
// import 'package:flutter_custom_calendar/controller.dart';
import 'package:flutter_custom_calendar/flutter_custom_calendar.dart';
import 'package:flutter_custom_calendar/model/date_model.dart';
import 'package:mdc_bhl/common/event/index.dart';
import 'package:mdc_bhl/common/local/local_storage.dart';
import 'package:mdc_bhl/widget/multi_select_style_dialog.dart';

import 'clean_over_time_date_utils.dart';
import 'eventbus_utils.dart';

class DatePickerUtils {
  /*
   * dateSelectStr 日期选择字符串（格式：2019-08-27, 2019-08-23, 2019-08-28）
   * refreshLabel 需要刷新的列表标识（即需要刷新的是什么列表）
   * saveLabel 存储标识（因为selectDateList.toString不能return）
   */
  static showDataPicker(BuildContext context, String dateSelectStr, String refreshLabel, String saveLabel) async {
    List<String> selectDateList = List();

    // 获取有效日期List
    /**
     * 例：显示范围【2019-8-23~2019-8-29】
     * DateTime minDate; // 2019-8-23
     * DateTime beforeMinDate; // 2019-8-22
     * DateTime maxDate; // 2019-8-29
     * DateTime afterMaxDate; // 2019-8-30
     */
    List<String> getValidDateList = await CleanOverTimeDateUtils.getValidDateList();
    print("有效日期List:" + getValidDateList.toString());
    DateTime minDate = DateTime.parse(getValidDateList[getValidDateList.length - 1]);
    DateTime maxDate = DateTime.now();
    DateTime beforeMinDate = minDate.subtract(new Duration(days: 1));
    DateTime afterMaxDate = maxDate.add(new Duration(days: 1));

    // 初始化controllor
    CalendarController controller = new CalendarController(
        selectMode:Constants.MODE_MULTI_SELECT,
        minSelectYear: beforeMinDate.year,
        minSelectMonth: beforeMinDate.month,
        minSelectDay: beforeMinDate.day,
        maxSelectYear: afterMaxDate.year,
        maxSelectMonth: afterMaxDate.month,
        maxSelectDay: afterMaxDate.day,

        weekBarItemWidgetBuilder: () {
          return CustomStyleWeekBarItem();
        },
        dayWidgetBuilder: (dateModel) {
          return CustomStyleDayWidget(dateModel);
        }
        );

    // 获取存储筛选信息
    print("获取存储筛选信息:" + dateSelectStr.toString());
    if (dateSelectStr != "") {
      String cutStr = dateSelectStr.substring(1, dateSelectStr.length - 1);
      if (cutStr != "") {
        List<String> list = cutStr.split(", ");
        if (list.length != 0) {
          // 已选择日期
          for (var item in list) {
            _setDate(controller, item, selectDateList);
          }
        } else {
          // 没有选择日期时
          _initDate(getValidDateList.toString(), controller, selectDateList);
        }
      } else {
        // 没有选择日期时
        _initDate(getValidDateList.toString(), controller, selectDateList);
      }
    } else {
      // 没有选择日期时
      _initDate(getValidDateList.toString(), controller, selectDateList);
    }

    controller.addOnCalendarSelectListener((dateModel) {
      String selectDate = dateModel.year.toString() + "-"
          + _getFormatDate(dateModel.month.toString()) + "-"
          + _getFormatDate(dateModel.day.toString());
      if (getValidDateList.contains(selectDate)) {
        if (selectDateList.contains(selectDate)) {
          selectDateList.remove(selectDate);
        } else {
          selectDateList.add(selectDate);
        }
      }
      print("选中的时间:\n${selectDateList.toString()}");
    });

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return new MultiSelectStyleDialog(
              controller,
              dismissCallback: () async {
                print("dismiss");
                await LocalStorage.save(saveLabel, selectDateList.toString());
                // 发送订阅消息刷新列表
                eventBus.fire(EventUtil(refreshLabel, null));
              }
          );
        }
    );
  }

  // 初始化日期
  static _initDate(String validDateStr, CalendarController controller, List<String> selectDateList) {
    String cutStr = validDateStr.substring(1, validDateStr.length - 1);
    List<String> list = cutStr.split(", ");
    for (var item in list) {
      _setDate(controller, item, selectDateList);
    }
  }

  // 设置日期
  static _setDate(CalendarController controller, String dateModelStr, List<String> selectDateList) {
    DateModel dateModel = new DateModel();
    dateModel.year = int.parse(dateModelStr.substring(0, 4));
    dateModel.month = int.parse(dateModelStr.substring(5, 7));
    dateModel.day = int.parse(dateModelStr.substring(8, 10));
    controller.selectedDateList.add(dateModel);
    selectDateList.add(dateModel.year.toString() + "-"
        + _getFormatDate(dateModel.month.toString()) + "-"
        + _getFormatDate(dateModel.day.toString()));
  }

  // 格式化日期 例：8→08
  static _getFormatDate(String monthOrDay) {
    String day = (monthOrDay.length == 1) ? "0" + monthOrDay : monthOrDay;
    return day;
  }

  // 判断是不是筛选的日期
  static bool getIsSelectDate(String dateSelectStr, String time) {
    List<String> list = [];
    if (dateSelectStr != "") {
      String cutStr = dateSelectStr.substring(1, dateSelectStr.length - 1);
      list = cutStr.split(", ");
      String date = time.substring(0, 10);
      if (list.contains(date)) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }
}