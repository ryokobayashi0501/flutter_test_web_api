import 'package:flutter_web_api/Models/hole_model.dart';

class Course {
  final int? courseId;  // nullableに変更
  String courseName;
  List<Hole> holes;

  Course({
    required this.courseId,
    required this.courseName,
    required this.holes,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    var holesFromJson = json['holes'] as List<dynamic>? ?? [];
    List<Hole> holeList = holesFromJson.map((holeJson) => Hole.fromJson(holeJson)).toList();

    return Course(
      courseId: json['courseId'], // nullableなので null を受け入れる
      courseName: json['courseName'],
      holes: holeList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'holes': holes.map((hole) => hole.toJson()).toList(),
    };
  }
}
