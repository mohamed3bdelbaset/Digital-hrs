import 'package:cnattendance/provider/leavecalendarcontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class LeaveCalendarView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final LeaveCalendarController model = Get.find();
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(10),
        child: englishCalendar(model));
  }

  TableCalendar englishCalendar(LeaveCalendarController model) {
    return TableCalendar(
      daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          weekendStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      headerStyle: const HeaderStyle(
          titleTextStyle: TextStyle(color: Colors.white),
          formatButtonTextStyle: TextStyle(
            color: Colors.transparent,
          ),
          formatButtonDecoration: BoxDecoration(color: Colors.transparent),
          leftChevronIcon: Icon(
            Icons.arrow_left,
            color: Colors.white,
          ),
          rightChevronIcon: Icon(
            Icons.arrow_right,
            color: Colors.white,
          )),
      calendarStyle: CalendarStyle(
          defaultTextStyle: TextStyle(color: Colors.white),
          weekendTextStyle: TextStyle(color: Colors.white),
          markerDecoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(20)))),
      eventLoader: (day) {
        var inputDate = day;
        var outputFormat = DateFormat('yyyy-MM-dd');
        var outputDate = outputFormat.format(inputDate);
        if (model.employeeLeaveList.containsKey(outputDate)) {
          return model.employeeLeaveList[outputDate] ?? [];
        } else {
          return [];
        }
      },
      currentDay: model.current.value,
      firstDay:
          DateTime.utc(model.current.value.year, model.currentMonth.value, 01),
      lastDay: DateTime.utc(model.current.value.add(Duration(days: 60)).year,
          model.nextMonth.value, 30),
      focusedDay: model.selected.value,
      selectedDayPredicate: (day) {
        return isSameDay(model.selected.value, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        model.selected.value = selectedDay;
        model.getLeaveByDate(model.selected.value);
      },
    );
  }
}
