// lib/Models/hole_model.dart
class Hole {
  int? holeId; // nullableに変更
  int courseId;
  int holeNumber;
  int par;
  int yardage;

  Hole({
    this.holeId, // nullable
    required this.courseId,
    required this.holeNumber,
    required this.par,
    required this.yardage,
  });

  factory Hole.fromJson(Map<String, dynamic> json) {
    return Hole(
      holeId: json['holeId'],
      courseId: json['courseId'],
      holeNumber: json['holeNumber'],
      par: json['par'],
      yardage: json['yardage'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'courseId': courseId,
      'holeNumber': holeNumber,
      'par': par,
      'yardage': yardage,
    };
    if (holeId != null && holeId != 0) { // holeIdが存在する場合のみ追加
      data['holeId'] = holeId;
    }
    return data;
  }
}
