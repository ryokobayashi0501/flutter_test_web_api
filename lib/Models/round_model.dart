class Round 
{
  final int roundId;
  final int courseId;
  final int userId;
  final String courseName;

  const Round({
    required this.roundId,
    required this.courseId,
    required this.userId,
    required this.courseName,
  });

  const Round.empty({
    this.roundId = 0,
    this.courseId = 0,
    this.userId = 0,
    this.courseName = '',
  });

  factory Round.fromJson(Map<String, dynamic> json) => Round(
    roundId: json['roundId'],
    courseId: json['courseId'],
    userId: json['userId'],
    courseName: json['courseName'],
  );

   Map<String, dynamic> toJson()=>{
    "roundId" : roundId,
    "courseId" : courseId,
    "userId" : userId,
    "courseName" : courseName,
   };
}