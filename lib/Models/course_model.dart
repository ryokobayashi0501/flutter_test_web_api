class Course 
{
  final int courseId;
  //final int userId;
  final String courseName;

  const Course({
    required this.courseId,
    //required this.userId,
    required this.courseName,
  });

  const Course.empty({
    this.courseId = 0,
    //this.userId = 0,
    this.courseName = '',
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        courseId: json['courseId'],
        //userId: json['userId'],
        courseName: json['courseName'],
  );
    
   Map<String, dynamic> toJson()=>{
        "courseId" : courseId,
        //"userId" : userId,
        "courseName" : courseName,
   };
}