import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class Diary {
  String text; // 내용
  DateTime createdAt; // 작성 시간

  Diary({
    required this.text,
    required this.createdAt,
  });

  ///Diary => Map 변경

  Map<String, dynamic> toJson() {
    return {
      "text": text,
      //DateTime은 문자열로 변경해야 jsonString으로 변환 가능
      "createdAt": createdAt.toString(),
    };
  }

  factory Diary.fromJson(Map<String, dynamic> jsonMap) {
    return Diary(
      text: jsonMap["text"],
      createdAt: DateTime.parse(jsonMap["createdAt"]),
    );
  }
}

class DiaryService extends ChangeNotifier {
  DiaryService(this.prefs) {
    List<String> strintDiaryList = prefs.getStringList("diaryList") ?? [];
    for (String stringDiary in strintDiaryList) {
      Map<String, dynamic> jsonMap = jsonDecode(stringDiary);

      Diary diary = Diary.fromJson(jsonMap);
      diaryList.add(diary);
    }
  }

  SharedPreferences prefs;

  List<Diary> diaryList = [];

  List<Diary> getByDate(DateTime date) {
    return diaryList
        .where((diary) => isSameDay(date, diary.createdAt))
        .toList();
  }

  /// Diary 작성
  void create(String text, DateTime selectedDate) {
    DateTime now = DateTime.now();
    //선택된 날짜 (selectedDate)에 현재 시간으로 추가
    DateTime createdAt = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      now.month,
      now.hour,
      now.second,
    );
    Diary diary = Diary(
      text: text,
      createdAt: createdAt,
    );
    diaryList.add(diary);
    notifyListeners();

    //diary 정보가 변경될 때 마다 저장해줍니다.
    _saveDiaryList();
  }

  /// Diary 수정
  void update(DateTime createdAt, String newContent) {
    Diary diary = diaryList.firstWhere(
      (diary) => diary.createdAt == createdAt,
    );

    diary.text = newContent;
    notifyListeners();

    _saveDiaryList();
  }

  /// Diary 삭제
  void delete(DateTime createdAt) {
    diaryList.removeWhere((diary) => diary.createdAt == createdAt);
    notifyListeners();
    _saveDiaryList();
  }


  void _saveDiaryList(){
    List<String> stringDiaryList =[];
    for(Diary diary in diaryList){
      Map<String,dynamic> jsonMap =diary.toJson();


      String stringDiary = jsonEncode(jsonMap);

      stringDiaryList.add(stringDiary);
    }
    prefs.setStringList("diaryList", stringDiaryList);

  }
}
