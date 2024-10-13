class User{
  final int userId;
  final String name;
  final String email;

  const User({
    required this.userId,
    required this.name,
    required this.email
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json['userId'],
        name: json['name'],
        email: json['email'],
      );

  Map<String, dynamic> toJson()=>{
        "userId" : userId,
        "name" : name,
        "email": email,
      };
}