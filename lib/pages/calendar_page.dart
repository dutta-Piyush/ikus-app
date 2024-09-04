import 'package:flutter/material.dart';
import 'package:ikus_app/components/buttons/ovgu_button.dart';
import 'package:ikus_app/components/cards/ovgu_card.dart';
import 'package:ikus_app/components/event_list.dart';
import 'package:ikus_app/components/icon_text.dart';
import 'package:ikus_app/components/main_list_view.dart';
import 'package:ikus_app/components/popups/channel_popup.dart';
import 'package:ikus_app/components/popups/date_popup.dart';
import 'package:ikus_app/i18n/strings.g.dart';
import 'package:ikus_app/model/channel.dart';
import 'package:ikus_app/model/event.dart';
import 'package:ikus_app/screens/event_screen.dart';
import 'package:ikus_app/service/calendar_service.dart';
import 'package:ikus_app/utility/globals.dart';
import 'package:ikus_app/utility/popups.dart';
import 'package:ikus_app/utility/ui.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  late Map<DateTime, List<Event>> _events;
  late List<Event> _myEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month; // Set default to monthly view

  @override
  void initState() {
    super.initState();
    _updateData();
  }

  void _updateData() {
    _events = CalendarService.instance.getEventsGroupByDate();
    _myEvents = CalendarService.instance.getMyEvents();
  }

  void _updateDataWithSetState() {
    setState(() {
      _updateData();
      nextFrame(() {
        setState(() {});
      });
    });
  }

Map<DateTime, List<Event>> _getVisibleEvents() {
  DateTime startDate;
  DateTime endDate;

  if (_calendarFormat == CalendarFormat.month) {
    startDate = DateTime(_focusedDay.year, _focusedDay.month, 1);
    endDate = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
  } else if (_calendarFormat == CalendarFormat.twoWeeks) {
    startDate = _focusedDay.subtract(Duration(days: _focusedDay.weekday));
    endDate = startDate.add(Duration(days: 13));
  } else {
    startDate = _focusedDay.subtract(Duration(days: _focusedDay.weekday));
    endDate = startDate.add(Duration(days: 6));
  }

  // Initialize visible events map
  Map<DateTime, List<Event>> visibleEvents = {};

  // Iterate through each day from startDate to endDate
  for (DateTime date = startDate; date.isBefore(endDate) || date.isAtSameMomentAs(endDate); date = date.add(Duration(days: 1))) {
    // Calculate the week number for biweekly view
    int weekNumber = (date.difference(startDate).inDays ~/ 7) + 1;

    // Check if _events contains events for the current date or week number in biweekly view
    if (_calendarFormat == CalendarFormat.twoWeeks) {
      if (_events.containsKey(date) || _events.containsKey(weekNumber)) {
        visibleEvents[date] = _events[date] ?? [];
      }
    } else {
      if (_events.containsKey(date)) {
        visibleEvents[date] = _events[date] ?? [];
      }
    }
  }

  return visibleEvents;
}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MainListView(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: OvguPixels.mainScreenPadding,
            child: Row(
              children: [
                Expanded(
                  child: IconText(
                    size: OvguPixels.headerSize,
                    distance: OvguPixels.headerDistance,
                    icon: Icons.today,
                    text: t.main.calendar.title,
                  ),
                ),
                OvguButton(
                  flat: true,
                  callback: () {
                    List<Channel> channels = CalendarService.instance.getChannels();
                    List<Channel> selected = CalendarService.instance.getSubscribed();
                    Popups.generic(
                        context: context,
                        height: ChannelPopup.calculateHeight(context),
                        body: ChannelPopup(
                          available: channels,
                          selected: selected,
                          callback: (channel, selected) async {
                            if (selected)
                              CalendarService.instance.subscribe(channel);
                            else
                              CalendarService.instance.unsubscribe(channel);
                            _updateDataWithSetState();
                          },
                        )
                    );
                  },
                  child: Icon(Icons.filter_list),
                ),
                IconButton(
                  icon: Icon(_calendarFormat == CalendarFormat.month ? Icons.view_agenda : Icons.view_module),
                  onPressed: () {
                    setState(() {
                      _calendarFormat = _calendarFormat == CalendarFormat.month ? CalendarFormat.week : CalendarFormat.month;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: OvguPixels.mainScreenPadding,
            child: OvguCard(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                child: TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime(2020, 8, 1),
                  lastDay: DateTime.now().add(Duration(days: 365)),
                  locale: LocaleSettings.currentLocale.languageTag,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarFormat: _calendarFormat, // Set the calendar format
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: true, // Allow format change
                  ),
                  availableGestures: AvailableGestures.all, // Allow all gestures for better interaction
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: OvguColor.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  eventLoader: (date) {
                    return _events[DateTime(date.year, date.month, date.day)] ?? [];
                  },
                  onPageChanged: (date) {
                    setState(() {
                      _focusedDay = date;
                    });
                  },
                  onDaySelected: (DateTime date, _) {
                    List<Event> currEvents = _events[DateTime(date.year, date.month, date.day)] ?? [];
                    Popups.generic(
                      context: context,
                      height: currEvents.length >= 3 ? 275 : 250,
                      body: DatePopup(
                        date: date,
                        events: currEvents.cast<Event>(),
                        onEventPop: () {
                          // in case that register information has changed
                          _updateDataWithSetState();
                        },
                      )
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
          Padding(
            padding: OvguPixels.mainScreenPadding,
            child: IconText(
              size: OvguPixels.headerSize,
              distance: OvguPixels.headerDistance,
              icon: Icons.list,
              text: t.main.calendar.events,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: EventList(
              events: _getVisibleEvents(),
              highlighted: _myEvents,
              callback: (event) async {
                await pushScreen(context, () => EventScreen(event));
                _updateDataWithSetState();
              },
            ),
          ),
          SizedBox(height: 50)
        ],
      ),
    );
  }
}
