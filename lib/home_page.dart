import 'package:diary/diary_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //달력 보여주는 형식
  CalendarFormat calendarFormat = CalendarFormat.month;

  //선택된 날짜
  DateTime selectedDate = DateTime.now();

  //create text controller
  TextEditingController createTextController = TextEditingController();

  // update texxt controller
  TextEditingController updateTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<DiaryService>(
      builder: (context, diaryService, child) {
        List<Diary> diaryList = diaryService.getByDate(selectedDate);
        return Scaffold(
          //키보드가 올라올때 화면 밀지 않도록 만들기
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: selectedDate,
                  calendarFormat: calendarFormat,
                  onFormatChanged: (format) {
                    setState(
                      () {
                        calendarFormat = format;
                      },
                    );
                  },
                  eventLoader: (date) {
                    //각 날짜에 해당하는 diaryList 보여주기
                    return diaryService.getByDate(date);
                  },
                  calendarStyle: CalendarStyle(
                    todayTextStyle: TextStyle(color: Colors.blueAccent),
                    todayDecoration: BoxDecoration(
                        color: Colors.grey, shape: BoxShape.circle),
                  ),
                  selectedDayPredicate: (day) {
                    return isSameDay(selectedDate, day);
                  },
                  onDaySelected: (_, focusedDay) {
                    setState(() {
                      selectedDate = focusedDay;
                    });
                  },
                ),
                Divider(height: 1),
                Expanded(
                  child: diaryList.isEmpty
                      ? Center(
                          child: Text(
                            "한 줄 일기를 작성해주세요",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: diaryList.length,
                          itemBuilder: (context, index) {
                            //역순으로 보여주기
                            int i = diaryList.length - index - 1;
                            Diary diary = diaryList[i];
                            return ListTile(
                              //Text
                              title: Text(
                                diary.text,
                                style: TextStyle(
                                    fontSize: 24, color: Colors.black),
                              ),
                              //createdAt
                              trailing: Text(
                                DateFormat("kk:mm").format(diary.createdAt),
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              onTap: () {
                                showUpdateDialog(diaryService, diary);
                              },

                              /// 꾹누르면 update
                              onLongPress: () {
                                showDeleteDialog(diaryService, diary);
                              },
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            //item 사이에 Divider 추가
                            return Divider(height: 1);
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.create,color: Colors.white,),
            backgroundColor: Colors.indigo,
            onPressed: () {
              showCreateDialog(diaryService);
            },
          ),
        );
      },
    );
  }

  //작성하기
  // 엔터를 누르거나 작성 버튼을 누르는 경우 호출
  void createDiary(DiaryService diaryService) {
    //앞뒤 공백 삭제
    String newText = createTextController.text.trim();
    if (newText.isNotEmpty) {
      diaryService.create(newText, selectedDate);
      createTextController.text = "";
    }
  }

  void updateDiary(DiaryService diaryService, Diary diary) {
    String updatedText = updateTextController.text.trim();
    if (updatedText.isNotEmpty) {
      diaryService.update(
        diary.createdAt,
        updatedText,
      );
    }
  }

  void showCreateDialog(DiaryService diaryService) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("일기 작성"),
          content: TextField(
            controller: createTextController,
            autofocus: true,
            //커서 색상
            cursorColor: Colors.indigo,
            decoration: InputDecoration(
              hintText: "한 줄 일기를 작성해주세요.",
              //포커스 되었을 때 밑줄 색상
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.indigo),
              ),
            ),
            onSubmitted: (_) {
              //엔터 누를 때 작성하기
              createDiary(diaryService);
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "취소",
                style: TextStyle(color: Colors.indigo),
              ),
            ),
          ],
        );
      },
    );
  }

  void showUpdateDialog(DiaryService diaryService, Diary diary) {
    showDialog(
      context: context,
      builder: (context) {
        updateTextController.text = diary.text;
        return AlertDialog(
          title: Text("일기 수정"),
          content: TextField(
            autofocus: true,
            controller: updateTextController,
            //커서 색상
            cursorColor: Colors.indigo,
            decoration: InputDecoration(
              hintText: "한 줄 일기를 작성해 주세요.",
              //포커스 되었을 때 밑줄 색상
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo)),
            ),
            onSubmitted: (v) {
              //엔터 누를 때 수정하기
              updateDiary(diaryService, diary);
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "취소",
                style: TextStyle(fontSize: 18, color: Colors.indigo),
              ),
            ),
            TextButton(
              onPressed: () {
                updateDiary(diaryService, diary);
                Navigator.pop(context);
              },
              child: Text(
                "수정",
                style: TextStyle(fontSize: 18, color: Colors.indigo),
              ),
            ),
          ],
        );
      },
    );
  }

  void showDeleteDialog(DiaryService diaryService, Diary diary) {
    showDialog(
      context: context,
      builder: (context) {
        updateTextController.text = diary.text;
        return AlertDialog(
          title: Text("일기 삭제"),
          content: Text('"${diary.text}"를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "취소",
                style: TextStyle(fontSize: 18, color: Colors.indigo),
              ),
            ),
            TextButton(
              onPressed: () {
                diaryService.delete(diary.createdAt);
                Navigator.pop(context);
              },
              child: Text(
                "삭제",
                style: TextStyle(fontSize: 18, color: Colors.indigo),
              ),
            ),
          ],
        );
      },
    );
  }
}
