import 'dart:convert';
import 'package:flutter_web_api/Models/course_model.dart';
import 'package:flutter_web_api/Models/DTOs/round_hole_dto_model.dart';
import 'package:flutter_web_api/Models/round_hole_model.dart';
import 'package:flutter_web_api/Models/round_model.dart';
import 'package:flutter_web_api/Models/shot_model.dart';
import 'package:flutter_web_api/Models/user_model.dart';
import 'package:flutter_web_api/Models/DTOs/users_model.dart';
import 'package:flutter_web_api/Models/hole_model.dart';

import 'package:http/http.dart' as http;

class ApiHandler {
  final String baseUri = "https://localhost:7287/api";

 Future<List<User>> getUserData() async {
    List<UserDTO> dtoData = [];
    List<User> userData = [];

    final uri = Uri.parse("$baseUri/users");
    try {
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8'
        },
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final List<dynamic> jsonData = json.decode(response.body);
        dtoData = jsonData.map((json) => UserDTO.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return userData; // Return an empty list if there's an error.
    }

    // Transpose UserDTO to User using a for loop.
    for (UserDTO userDto in dtoData) {
      userData.add(User(
        userId: userDto.userId,
        name: userDto.name,
        username: userDto.username,
        email: userDto.email,
        yearsOfExperience: userDto.yearsOfExperience,
        averageScore: userDto.averageScore,
        practiceFrequency: userDto.practiceFrequency,
        scoreGoal: userDto.scoreGoal,
        puttingGoal: double.tryParse(userDto.puttingGoal) ?? 0.0, // Handle string to double conversion. return 0.0 when null.
        approachGoal: userDto.approachGoal,
        shotGoal: userDto.shotGoal,
        passwordHash: userDto.passwordHash,
      ));
    }

    return userData;
  }

  Future<http.Response> updateUser({required int userId, required User user}) async {
    final uri = Uri.parse("$baseUri/users/$userId");
    late http.Response response;

    try {
      response = await http.put(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8'
        },
        body: json.encode(user),
      );
    } catch (e) {
      return response;
    }

    return response;
  }

  Future<http.Response> addUser(User user) async { // Previously: {required User user}
    final uri = Uri.parse(baseUri);
    late http.Response response;

    try {
      response = await http.post(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8'
        },
        body: json.encode(user.toJson()), // without .toJson is ok
      );
    } catch (e) {
      return response;
    }

    return response;
  }

  Future<http.Response> deleteUser({required int userId}) async {
    final uri = Uri.parse("$baseUri/$userId");
    late http.Response response;
    try {
      response = await http.delete(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8'
        },
      );
    } catch (e) {
      return response;
    }
    return response;
  }

  Future<User?> getUserById({required int userId}) async {
    final uri = Uri.parse("$baseUri/$userId");
    User? user;
    try {
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        user = User.fromJson(jsonData);
      }
    } catch (e) {
      print("Error fetching user by ID: $e");  // Added error log
      return null;  // Changed to return null
    }
    return user;  // Changed from `user!` to `user` (nullable type)
  }

  Future<User?> getUserByName({required String name}) async {
    final uri = Uri.parse("$baseUri/name/$name");  // New endpoint

    User? user;
    try {
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8'
        },
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        user = User.fromJson(jsonData);
      }
    } catch (e) {
      print("Error fetching user by name: $e");
      return null;
    }
    return user;
  }

  Future<List<Course>> getAllCourses() async {
  print("getAllCourses() called"); // デバッグ用
  List<Course> courses = [];
  final uri = Uri.parse("$baseUri/Courses");
  try {
    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-type': 'application/json; charset=UTF-8'
      },
    );
    print("Response status: ${response.statusCode}"); // デバッグ用
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      final List<dynamic> jsonData = json.decode(response.body);
      print("Received data: $jsonData"); // デバッグ用
      courses = jsonData.map((json) => Course.fromJson(json)).toList();
    } else {
      print("Failed to fetch courses: ${response.statusCode}, ${response.reasonPhrase}");
    }
  } catch (e) {
    print("Error fetching courses: $e");
  }
  print("getAllCourses() completed"); // デバッグ用
  return courses;
}




  Future<Course?> getCourseById(int courseId) async {
  final uri = Uri.parse("$baseUri/Courses/$courseId");
  Course? course;

  try {
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      course = Course.fromJson(jsonData);
    } else {
      print("Failed to fetch course by ID: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching course by ID: $e");
  }

  return course;
}


  Future<http.Response> addCourse(Course course) async { // Previously: {required User user}
    final uri = Uri.parse(baseUri);
    late http.Response response;

    try {
      response = await http.post(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8'
        },
        body: json.encode(course.toJson()), // without .toJson is ok
      );
    } catch (e) {
      return response;
    }

    return response;
  }

  // コースを取得するAPI
  Future<List<Course>> getCoursesByUserId(int userId) async {
    List<Course> courses = [];

    final uri = Uri.parse("$baseUri/Courses/user/$userId");
    try {
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8'
        },
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final List<dynamic> jsonData = json.decode(response.body);
        courses = jsonData.map((json) => Course.fromJson(json)).toList();
      } else {
        print("Failed to fetch courses: ${response.statusCode}, ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error fetching courses: $e");
    }
    return courses;
  }

  // コースを追加するAPI
  Future<http.Response> addCourseForUser(int userId, String courseName, List<Hole> holes, String imageUri) async {
  final uri = Uri.parse("$baseUri/Courses/user/$userId");
  late http.Response response;

  // コースデータを作成
  Course newCourse = Course(
    courseId: null,
    courseName: courseName,
    imageUri: imageUri, // 画像URIを設定
    holes: holes,
  );

  try {
    response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(newCourse.toJson()), // JSONデータを送信
    );

    if (response.statusCode == 201) {
      print("Course added successfully");
    } else {
      print("Failed to add course: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  } catch (e) {
    print("Error adding course: $e");
    rethrow;
  }

  return response;
}




  // コースを編集するAPI
  Future<http.Response> updateCourse(Course course) async {
    final uri = Uri.parse("$baseUri/Courses/${course.courseId}");
    late http.Response response;

    try {
      response = await http.put(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8',
        },
        body: json.encode(course.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        print("Course updated successfully");
      } else {
        print("Failed to update course: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error updating course: $e");
      rethrow; // 例外を再スロー
    }

    return response;
  }

  // コースを削除するAPI
  Future<http.Response> deleteCourse(int courseId) async {
    final uri = Uri.parse("$baseUri/Courses/$courseId");
    late http.Response response;

    try {
      response = await http.delete(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        print("Course deleted successfully");
      } else {
        print("Failed to delete course: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error deleting course: $e");
      rethrow; // 例外を再スロー
    }

    return response;
  }

  // ホールを取得するAPI
  Future<List<Hole>> getHolesByCourseId(int courseId) async {
    List<Hole> holes = [];
    final uri = Uri.parse("$baseUri/Courses/$courseId/Holes");

    try {
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8'
        },
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final List<dynamic> jsonData = json.decode(response.body);
        holes = jsonData.map((json) => Hole.fromJson(json)).toList();
      } else {
        print("Failed to fetch holes: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error fetching holes: $e");
    }
    return holes;
  }

  // ホールを追加するAPI
  // api_handler.dart
Future<http.Response> addHoleForCourse(int courseId, Hole hole) async {
  final uri = Uri.parse("$baseUri/Courses/$courseId/Holes");
  late http.Response response;

  try {
    String holeJson = json.encode(hole.toJson());
    print("Sending Hole JSON: $holeJson"); // デバッグ用

    response = await http.post(
      uri,
      headers: <String, String>{
        'Content-type': 'application/json; charset=UTF-8',
      },
      body: holeJson,
    );

    if (response.statusCode >= 200 && response.statusCode <= 299) {
      print("Hole added successfully");
    } else {
      print("Failed to add hole: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  } catch (e) {
    print("Error adding hole: $e");
    rethrow; // 例外を再スロー
  }

  return response;
}



  // ホールを更新するAPI
  Future<http.Response> updateHole(Hole hole) async {
    final uri = Uri.parse("$baseUri/Courses/${hole.courseId}/Holes/${hole.holeId}");
    late http.Response response;

    try {
      response = await http.put(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8',
        },
        body: json.encode(hole.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        print("Hole updated successfully");
      } else {
        print("Failed to update hole: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error updating hole: $e");
      rethrow; // 例外を再スロー
    }

    return response;
  }

  // ホールを削除するAPI
  Future<http.Response> deleteHole(int courseId, int holeId) async {
    final uri = Uri.parse("$baseUri/Courses/$courseId/Holes/$holeId");
    late http.Response response;

    try {
      response = await http.delete(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        print("Hole deleted successfully");
      } else {
        print("Failed to delete hole: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error deleting hole: $e");
      rethrow; // 例外を再スロー
    }

    return response;
  }


// Future<List<Round>> getRoundsByUserId(int userId) async {
//   final uri = Uri.parse("$baseUri/Rounds/user/$userId/rounds");
//   List<Round> rounds = [];

//   try {
//     final response = await http.get(
//       uri,
//       headers: {'Content-Type': 'application/json; charset=UTF-8'},
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> jsonData = json.decode(response.body);
//       print('Received JSON data: $jsonData'); // デバッグ用

//       rounds = jsonData.map((json) => Round.fromJson(json)).toList();
//       print('Parsed rounds: $rounds'); // デバッグ用
//     } else {
//       print("Failed to fetch rounds: ${response.statusCode}");
//     }
//   } catch (e) {
//     print("Error fetching rounds: $e");
//   } 
//   return rounds;
// }

// Future<http.Response> deleteRound(int roundId) async {
//   final uri = Uri.parse("$baseUri/Rounds/$roundId");
//   late http.Response response;

//   try {
//     response = await http.delete(
//       uri,
//       headers: {'Content-Type': 'application/json; charset=UTF-8'},
//     );
//     if (response.statusCode >= 200 && response.statusCode <= 299) {
//       print("Round deleted successfully.");
//     } else {
//       print("Failed to delete round: ${response.statusCode}");
//     }
//   } catch (e) {
//     print("Error deleting round: $e");
//     rethrow;
//   }

//   return response;
// }

// // ラウンドをユーザーに追加するAPI
// // ラウンドをユーザーに追加するAPI
// Future<http.Response> addRoundForUser(int userId, int courseId, List<Hole> holes) async {
//   final uri = Uri.parse('$baseUri/Rounds');
//   late http.Response response;

//   try {
//     // RoundHoles情報を作成
//     List<Map<String, dynamic>> roundHoles = holes.map((hole) {
//       return {
//         "holeId": hole.holeId,
//         "stroke": 0, // 初期値としてストローク数を0に設定
//         "putts": 0,  // パット数を0に設定
//         "penaltyStrokes": 0, // ペナルティを0に設定
//         "fairwayHit": false, // フェアウェイヒットの初期値
//         "greenInRegulation": false // GIRの初期値
//       };
//     }).toList();

//     // リクエストボディを作成
//     Map<String, dynamic> requestBody = {
//       "userId": userId,
//       "courseId": courseId,
//       "roundDate": DateTime.now().toIso8601String(), // 必要であれば日付を追加
//       "roundHoles": roundHoles, // RoundHolesフィールドを含める
//     };

//     response = await http.post(
//       uri,
//       headers: {'Content-Type': 'application/json; charset=UTF-8'},
//       body: json.encode(requestBody),
//     );

//     if (response.statusCode == 201) {
//       print("Round added successfully.");
//     } else {
//       print("Failed to add round: ${response.statusCode}");
//       print("Response body: ${response.body}");
//     }
//   } catch (e) {
//     print("Error adding round: $e");
//     rethrow;
//   }

//   return response;
// }




// Future<void> addRoundHoleForUser(int userId, int roundId, int holeId) async {
//   final uri = Uri.parse('$baseUri/users/$userId/rounds/$roundId/holes/$holeId');

//   // リクエストボディを作成（RoundHoleの追加）
//   Map<String, dynamic> requestBody = {
//     "stroke": 0, // 初期値としてストローク数を0に設定
//     "putts": 0,  // パット数も0に設定
//     "penaltyStrokes": 0, // ペナルティストロークを0に設定
//     "fairwayHit": false, // 初期値としてフェアウェイヒットをfalseに設定
//     "greenInRegulation": false // 初期値としてGIRをfalseに設定
//   };

//   try {
//     final response = await http.post(
//       uri,
//       headers: {'Content-Type': 'application/json; charset=UTF-8'},
//       body: json.encode(requestBody),
//     );

//     if (response.statusCode == 201) {
//       print("RoundHole added successfully for holeId: $holeId");
//     } else {
//       print("Failed to add RoundHole: ${response.statusCode}");
//       print("Response body: ${response.body}");
//     }
//   } catch (e) {
//     print("Error adding RoundHole for holeId $holeId: $e");
//     rethrow;
//   }
// }


// // RoundHole を追加するメソッド


//   // RoundId から RoundHoles を取得するメソッド
//   Future<List<RoundHole>> getRoundHolesByRoundId(int roundId) async {
//     final uri = Uri.parse("$baseUri/RoundHoles/round/$roundId");
//     List<RoundHole> roundHoles = [];

//     try {
//       final response = await http.get(
//         uri,
//         headers: {'Content-Type': 'application/json; charset=UTF-8'},
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         roundHoles = jsonData.map((json) => RoundHole.fromJson(json)).toList();
//       } else {
//         print("Failed to fetch RoundHoles: ${response.statusCode}");
//         print("Response body: ${response.body}");
//       }
//     } catch (e) {
//       print("Error fetching RoundHoles: $e");
//     }

//     return roundHoles;
//   }

//   // RoundHole を更新するメソッド
//   Future<http.Response> updateRoundHole(RoundHole roundHole) async {
//     final uri = Uri.parse("$baseUri/RoundHoles/${roundHole.roundHoleId}");
//     late http.Response response;

//     try {
//       response = await http.put(
//         uri,
//         headers: {'Content-Type': 'application/json; charset=UTF-8'},
//         body: json.encode(roundHole.toJson()),
//       );

//       if (response.statusCode == 204) {
//         print("RoundHole updated successfully.");
//       } else {
//         print("Failed to update RoundHole: ${response.statusCode}");
//         print("Response body: ${response.body}");
//       }
//     } catch (e) {
//       print("Error updating RoundHole: $e");
//       rethrow;
//     }

//     return response;
//   }

//   // RoundHole を削除するメソッド
//   Future<http.Response> deleteRoundHole(int roundHoleId) async {
//     final uri = Uri.parse("$baseUri/RoundHoles/$roundHoleId");
//     late http.Response response;

//     try {
//       response = await http.delete(
//         uri,
//         headers: {'Content-Type': 'application/json; charset=UTF-8'},
//       );

//       if (response.statusCode == 204) {
//         print("RoundHole deleted successfully.");
//       } else {
//         print("Failed to delete RoundHole: ${response.statusCode}");
//         print("Response body: ${response.body}");
//       }
//     } catch (e) {
//       print("Error deleting RoundHole: $e");
//       rethrow;
//     }

//     return response;
//   }

//   // RoundHoleId から Shots を取得するメソッド
//   Future<List<Shot>> getShotsByRoundHoleId(int roundHoleId) async {
//     final uri = Uri.parse("$baseUri/Shots/roundHole/$roundHoleId");
//     List<Shot> shots = [];

//     try {
//       final response = await http.get(
//         uri,
//         headers: {'Content-Type': 'application/json; charset=UTF-8'},
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         shots = jsonData.map((json) => Shot.fromJson(json)).toList();
//       } else {
//         print("Failed to fetch Shots: ${response.statusCode}");
//         print("Response body: ${response.body}");
//       }
//     } catch (e) {
//       print("Error fetching Shots: $e");
//     }

//     return shots;
//   }

//   // Shot を更新するメソッド
//   Future<http.Response> updateShot(Shot shot) async {
//     final uri = Uri.parse("$baseUri/Shots/${shot.shotId}");
//     late http.Response response;

//     try {
//       response = await http.put(
//         uri,
//         headers: {'Content-Type': 'application/json; charset=UTF-8'},
//         body: json.encode(shot.toJson()),
//       );

//       if (response.statusCode == 204) {
//         print("Shot updated successfully.");
//       } else {
//         print("Failed to update Shot: ${response.statusCode}");
//         print("Response body: ${response.body}");
//       }
//     } catch (e) {
//       print("Error updating Shot: $e");
//       rethrow;
//     }

//     return response;
//   }

//   // Shot を削除するメソッド
//   Future<http.Response> deleteShot(int shotId) async {
//     final uri = Uri.parse("$baseUri/Shots/$shotId");
//     late http.Response response;

//     try {
//       response = await http.delete(
//         uri,
//         headers: {'Content-Type': 'application/json; charset=UTF-8'},
//       );

//       if (response.statusCode == 204) {
//         print("Shot deleted successfully.");
//       } else {
//         print("Failed to delete Shot: ${response.statusCode}");
//         print("Response body: ${response.body}");
//       }
//     } catch (e) {
//       print("Error deleting Shot: $e");
//       rethrow;
//     }

//     return response;
//   }

//   Future<http.Response> addRoundHole(int userId, int roundId, int holeId, RoundHoleDto roundHoleDto) async {
//   final uri = Uri.parse('$baseUri/users/$userId/rounds/$roundId/holes/$holeId');

//   late http.Response response;

//   try {
//     response = await http.post(
//       uri,
//       headers: {'Content-Type': 'application/json; charset=UTF-8'},
//       body: json.encode(roundHoleDto.toJson()),
//     );

//     if (response.statusCode == 201) {
//       print("RoundHole added successfully.");
//     } else {
//       print("Failed to add RoundHole: ${response.statusCode}");
//       print("Response body: ${response.body}");
//     }
//   } catch (e) {
//     print("Error adding RoundHole: $e");
//     rethrow;
//   }

//   return response;
// }

//   // Shot を追加するメソッド
//   Future<http.Response> addShot(int userId, int roundId, int holeId, int roundHoleId, Shot shot) async {
//     final uri = Uri.parse('$baseUri/users/$userId/rounds/$roundId/holes/$holeId/roundHoles/$roundHoleId/shots');
//     late http.Response response;

//     try {
//       response = await http.post(
//         uri,
//         headers: {'Content-Type': 'application/json; charset=UTF-8'},
//         body: json.encode(shot.toJson()),
//       );

//       if (response.statusCode == 201) {
//         print("Shot added successfully.");
//       } else {
//         print("Failed to add Shot: ${response.statusCode}");
//         print("Response body: ${response.body}");
//       }
//     } catch (e) {
//       print("Error adding Shot: $e");
//       rethrow;
//     }

//     return response;
//   }

}
