class User{
  final int userId;
  final String name;
  final String email;
  final int yearsOfExperience;
  final String averageScore;

  const User({
    required this.userId,
    required this.name,
    required this.email,
    required this.yearsOfExperience,
    required this.averageScore,
  });

  const User.empty({
    this.userId = 0,
    this.name = '',
    this.email = '',
    this.yearsOfExperience = 0,
    this.averageScore = '',
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json['userId'],
        name: json['name'],
        email: json['email'],
        yearsOfExperience: json['yearsOfExperience'],
        averageScore: json['averageScore'],
      );

  Map<String, dynamic> toJson()=>{
        "userId" : userId,
        "name" : name,
        "email" : email,
        "yearsOfExperience" : yearsOfExperience,
        "averageScore" : averageScore,
      };
}