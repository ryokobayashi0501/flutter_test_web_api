class Hole{
  final int holeId;
  final int courseId;
  final int holeNumber;
  final int par;
  final int yardage;

  const Hole({
    required this.holeId,
    required this.courseId,
    required this.holeNumber,
    required this.par,
    required this.yardage,
  });

  const Hole.empty({
    this.holeId = 0,
    this.courseId = 0,
    this.holeNumber = 0,
    this.par = 0,
    this.yardage = 0,
  });

  factory Hole.fromJson(Map<String, dynamic> json) => Hole(
    holeId: json['holeId'],
    courseId: json['courseId'],
    holeNumber: json['holeNumber'],
    par: json['par'],
    yardage: json['yardage'],
  );

  Map<String, dynamic> toJson()=>{
    "holeId" : holeId,
    "courseId" : courseId,
    "holeNumber" : holeNumber,
    "par" : par,
    "yardage" : yardage,
   };
}