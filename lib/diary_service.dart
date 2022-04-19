import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'main.dart';

class Diary {
  String text;
  DateTime createdAt;

  Diary(this.text, this.createdAt);

  // Diary -> Map
  Map<String, dynamic> toJson() {
    return {
      "text": text,
      "createdAt": createdAt.toString(),
    };
  }

  // Map -> Diary
  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      json["text"],
      DateTime.parse(json["createdAt"]),
    );
  }
}

class DiaryService extends ChangeNotifier {
  /// Diary 목록
  late List<Diary> diaryList = getData();

  void setData() {
    List<String> tmpList = [];

    for (Diary d in diaryList) {
      tmpList.add(jsonEncode(d.toJson()));
    }
    prefs.setStringList("diaryList", tmpList);
  }

  List<Diary> getData() {
    List<Diary> tmpList = [];
    List<String> prefsDiaryList = prefs.getStringList('diaryList') ?? [];

    for (String d in prefsDiaryList) {
      print(prefs.getStringList('diaryList'));
      Map<String, dynamic> jsonMap = jsonDecode(d);
      tmpList.add(Diary.fromJson(jsonMap));
    }
    return tmpList;
  }

  /// 특정 날짜의 diary 조회
  List<Diary> getByDate(DateTime date) {
    List<Diary> tmpList = [];
    for (Diary d in diaryList) {
      if (isSameDay(d.createdAt, date)) {
        tmpList.add(d);
      }
    }
    return tmpList;
  }

  /// Diary 작성
  void create(String text, DateTime selectedDate) {
    // TODO
    diaryList.add(Diary(text, selectedDate));
    setData();
    notifyListeners();
  }

  /// Diary 수정
  void update(DateTime createdAt, String newContent) {
    // TODO
    for (Diary d in diaryList) {
      if (d.createdAt.compareTo(createdAt) == 0) {
        d.text = newContent;
      }
    }
    setData();
    notifyListeners();
  }

  /// Diary 삭제
  void delete(DateTime createdAt) {
    // TODO
    for (int i = 0; i < diaryList.length; i++) {
      if (diaryList[i].createdAt.compareTo(createdAt) == 0) {
        diaryList.removeAt(i);
      }
    }
    setData();
    notifyListeners();
  }
}
// class Diary {
//   String text; // 내용
//   DateTime createdAt; // 작성 시간

//   //왜 안되는지 모르겠음
//   Diary({
//     required this.text,
//     required this.createdAt,
//   });

//   Map<String, dynamic> toJson() {
//     return {"text": text, "createdAt": createdAt.toString()};
//   }

//   factory Diary.fromJson(Map<String, dynamic> json) {
//     return Diary(
//       json["text"],
//       DateTime.parse(json["createdAt"]),
//     );
//   }
// }
//   List<Diary> diaryList = [Diary(text: 'hellllo', createdAt: DateTime.now())];
