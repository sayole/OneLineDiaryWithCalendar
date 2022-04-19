import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'diary_service.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDay = DateTime.now();
  List<Diary> selectedDayDiary = [];

  CalendarFormat _calendarFormat = CalendarFormat.month;

  void alertDialogByMode(BuildContext context, String mode, dynamic diary) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController textController = TextEditingController();

        return AlertDialog(
          title: Text('일기 ${mode}'),
          content: contentByMode(mode, textController, diary),
          actions: [
            // 취소 버튼
            TextButton(
              child: Text(
                "취소",
                style: TextStyle(color: Colors.pink),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(mode),
              onPressed: () {
                actionByMode(mode, textController, diary);
              },
            ),
          ],
        );
      },
    );
  }

  dynamic contentByMode(
      String mode, TextEditingController textController, dynamic diary) {
    if (mode == '수정') {
      textController.text = diary.text;
      return TextField(
        controller: textController,
        autofocus: true,
      );
    } else if (mode == '삭제') {
      return Text('${diary.text}를 삭제하시겠습니까?');
    } else {
      return TextField(
        controller: textController,
        autofocus: true,
        decoration: InputDecoration(hintText: '한 줄 일기를 작성해주세요.'),
      );
    }
  }

  void actionByMode(
      String mode, TextEditingController textController, dynamic diary) {
    print(diary);
    DiaryService diaryService = context.read<DiaryService>();
    if (mode == '삭제') {
      diaryService.delete(diary.createdAt);
    } else if (mode == '수정') {
      diaryService.update(diary.createdAt, textController.text);
    } else if (diary == null) {
      diaryService.create(textController.text, DateTime.now());
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('ko');
    return Consumer<DiaryService>(
      builder: (context, diaryService, child) {
        selectedDayDiary = diaryService.getByDate(_selectedDay);
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.now(),
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    isTodayHighlighted: false,
                  ),
                  eventLoader: (day) {
                    return diaryService.getByDate(day);
                  },
                  focusedDay: _selectedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      selectedDayDiary = diaryService.getByDate(selectedDay);
                    });
                  },
                ),
                Divider(),
                selectedDayDiary.isEmpty
                    ? Center(
                        child: Text(
                          '한줄 일기를 작성해보세요!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: selectedDayDiary.length,
                          itemBuilder: (context, index) {
                            var diary = selectedDayDiary[index];
                            return ListTile(
                              title: Text(
                                diary.text,
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Text(
                                DateFormat('hh:mm').format(diary.createdAt),
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.35),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                alertDialogByMode(context, '수정', diary);
                              },
                              onLongPress: () {
                                alertDialogByMode(context, '삭제', diary);
                              },
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
          //글 추가 floating button
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.indigo.shade400,
            child: Icon(
              Icons.edit,
            ),
            onPressed: () {
              if (isSameDay(_selectedDay, DateTime.now())) {
                alertDialogByMode(context, '작성', null);
              }
            },
          ),
        );
      },
    );
  }
}
