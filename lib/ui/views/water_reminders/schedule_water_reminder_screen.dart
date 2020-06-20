import 'package:MedBuzz/core/widgets/timer_wheel.dart';
import 'package:MedBuzz/ui/size_config/config.dart';
import 'package:MedBuzz/ui/views/water_reminders/schedule_water_reminder_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class WaterScheduleScreen extends StatelessWidget {
  //values of water measures - stored as int in case of any need to calculate
  static const routeName = 'schedule-water-reminder';
  final ItemScrollController _scrollController = ItemScrollController();
  WaterScheduleScreen();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return ChangeNotifierProvider<WaterReminderViewModel>(
      create: (context) => WaterReminderViewModel(),
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(color: Theme.of(context).primaryColorDark),
          title: Text(
            'Add a water reminder',
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Consumer<WaterReminderViewModel>(
          builder: (context, waterReminder, child) {
            return SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DropdownButtonHideUnderline(
                      child: DropdownButton(
                        isExpanded: false,
                        // here sets the value to the selected month and if null, it defaults to the present date month from DateTime.now()
                        value: waterReminder.currentMonth,
                        hint: Text('Month'),
                        items: monthValues
                            .map((month) => DropdownMenuItem(
                                  child: Text(
                                    month.month,
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark),
                                  ),
                                  value: month.month,
                                ))
                            .toList(),
                        onChanged: (val) =>
                            waterReminder.updateSelectedMonth(val),
                      ),
                    ),
                    Container(
                      //without specifying this height, flutter throws an error because of the grid
                      height: height * 0.20,
                      child: ScrollablePositionedList.builder(
                        //sets default selected day to the index of Date.now() date
                        initialScrollIndex: waterReminder.selectedDay - 1,
                        itemScrollController: _scrollController,
                        //dynamically sets the itemCount to the number of days in the currently selected month
                        itemCount: waterReminder.daysInMonth,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              waterReminder.updateSelectedDay(index);
                              _scrollController.scrollTo(
                                index: index,
                                duration: Duration(seconds: 1),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: waterReminder.getButtonColor(
                                    context, index),
                                borderRadius:
                                    BorderRadius.circular(height * 0.05),
                              ),
                              alignment: Alignment.bottomRight,
                              margin: EdgeInsets.only(
                                  left: Config.xMargin(context, 2)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: Config.xMargin(context, 4.5)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    (index + 1).toString(),
                                    style: waterReminder.calendarTextStyle(
                                        context, index),
                                  ),
                                  SizedBox(
                                      height: Config.yMargin(context, 1.5)),
                                  Text(
                                    waterReminder.getWeekDay(index),
                                    style: waterReminder.calendarSubTextStyle(
                                        context, index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                          vertical: Config.yMargin(context, 3)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Time'),
                          Container(
                            // this also acts like a negative margin to get rid of the excess space from moving the grid up
                            alignment: Alignment.topCenter,
                            child: Container(
                              height: height * 0.2,
                              transform: Matrix4.translationValues(
                                  0.0, -Config.yMargin(context, 9), 0.0),
                              child: TimePickerSpinner(
                                is24HourMode: false,
                                isForce2Digits: true,
                                spacing: 60,
                                itemHeight: height * 0.1,
                                alignment: Alignment.center,
                                onTimeChange: (val) {
                                  //val is the new time in the format of YYYY-MM-DD HH:MM:SS.mmmm
                                  waterReminder.updateSelectedTime(val);
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // the transform applies sort of a negative margin to cover up for the excess space the grid takes
                    Transform.translate(
                      offset: Offset(0, height * -0.1),
                      child: Container(
                        height: height * 0.4,
                        child: GridView.count(
                          primary: false,
                          padding: EdgeInsets.symmetric(
                              horizontal: Config.xMargin(context, 3)),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          crossAxisCount: 3,
                          children: waterReminder.mls.map((ml) {
                            return GestureDetector(
                              onTap: () => waterReminder.updateSelectedMl(ml),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: waterReminder.getGridItemColor(
                                      context, ml),
                                  borderRadius:
                                      BorderRadius.circular(width * 0.03),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$ml' + 'ml',
                                  style: waterReminder.gridItemTextStyle(
                                      context, ml),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: Config.xMargin(context, 3),
                          right: Config.xMargin(context, 3),
                          bottom: Config.yMargin(context, 6)),
                      child: SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                          color: Theme.of(context).primaryColor,
                          padding: EdgeInsets.symmetric(
                              // horizontal: Config.xMargin(context, 10),
                              vertical: Config.yMargin(context, 3)),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(width * 0.03),
                          ),
                          onPressed:
                              //here the function to save the schedule can be executed, by formatting the selected date as _today.year-selectedMonth-selectedDay i.e YYYY-MM-DD
                              waterReminder.createSchedule,
                          child: Text(
                            "Save",
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontSize: Config.textSize(context, 5)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
