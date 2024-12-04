class UserDTO{
  final int userId;
  final String name;
  final String username;
  final String email;
  final int yearsOfExperience;
  final int averageScore;
  final int practiceFrequency;
  final int scoreGoal;
  final String puttingGoal;
  final String approachGoal;
  final String shotGoal;
  final String passwordHash;

  const UserDTO({
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
    required this.shotGoal,
    required this.passwordHash
  });

  const UserDTO.empty({
    this.userId = 0,
    this.name = '',
    this.username = '',
    this.email = '',
    this.yearsOfExperience = 0,
    this.averageScore = 0,
    this.practiceFrequency = 0,
    this.scoreGoal = 0,
    this.puttingGoal ='',
    this.approachGoal = '',
    this.shotGoal = '',
    this.passwordHash = ''
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) => UserDTO(
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
        shotGoal: json['shotGoal'],
        passwordHash: json['passwordHash']
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
        "shotGoal" : shotGoal,
        "passwordHash" : passwordHash
      };
}