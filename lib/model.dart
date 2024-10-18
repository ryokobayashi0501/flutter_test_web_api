class User{
  final int userId;
  final String name;
  final String username;
  final String email;
  final int yearsOfExperience;
  final int averageScore;
  final int practiceFrequency;
  final int scoreGoal;
  final double puttingGoal;
  final String approachGoal;

  const User({
    required this.userId,
    required this.name,
    required this.username,
    required this.email,
    required this.yearsOfExperience,
    required this.averageScore,
    required this.practiceFrequency,
    required this.scoreGoal,
    required this.puttingGoal,
    required this.approachGoal,
  });

  const User.empty({
    this.userId = 0,
    this.name = '',
    this.username = '',
    this.email = '',
    this.yearsOfExperience = 0,
    this.averageScore = 0,
    this.practiceFrequency = 0,
    this.scoreGoal = 0,
    this.puttingGoal = 0.0,
    this.approachGoal = '',
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json['userId'],
        name: json['name'],
        username: json['username'],
        email: json['email'],
        yearsOfExperience: json['yearsOfExperience'],
        averageScore: json['averageScore'],
        practiceFrequency: json['practiceFrequency'],
        scoreGoal: json['scoreGoal'],
        puttingGoal: json['puttingGoal'],
        approachGoal: json['approachGoal'],
      );

  Map<String, dynamic> toJson()=>{
        "userId" : userId,
        "name" : name,
        "username" : username,
        "email" : email,
        "yearsOfExperience" : yearsOfExperience,
        "averageScore" : averageScore,
        "practiceFrequency" : practiceFrequency,
        "scoreGoal" : scoreGoal,
        "puttingGoal" : puttingGoal,
        "approachGoal" : approachGoal,
      };
}