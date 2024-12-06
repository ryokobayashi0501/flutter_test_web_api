import 'package:flutter_web_api/Models/hole_model.dart';

class Course {
  final int? courseId;  // nullableに変更
  String courseName;
  String imageUri; // 画像URIを追加
  List<Hole> holes;

  Course({
    required this.courseId,
    required this.courseName,
    required this.imageUri,
    List<Hole>? holes, // nullableに変更
  }) : holes = holes ?? [];

  factory Course.fromJson(Map<String, dynamic> json) {
    var holesFromJson = json['holes'] as List<dynamic>? ?? [];
    List<Hole> holeList = holesFromJson.map((holeJson) => Hole.fromJson(holeJson)).toList();

    return Course(
      courseId: json['courseId'], // nullableなので null を受け入れる
      courseName: json['courseName'],
      imageUri: json['imageUri'], // JSONからimageUriを取得
      holes: holeList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'imageUri': imageUri, // JSONにimageUriを含める
      'holes': holes.map((hole) => hole.toJson()).toList(),
    };
  }
}
