import 'dart:convert';
import 'package:flutter_web_api/Models/course_model.dart';
import 'package:flutter_web_api/Models/user_model.dart';
import 'package:flutter_web_api/Models/users_model.dart';
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

  Future<List<Course>> getCourseData() async {
    List<Course> data = [];

    final uri = Uri.parse(baseUri);
    try {
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8'
        },
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final List<dynamic> jsonData = json.decode(response.body);
        data = jsonData.map((json) => Course.fromJson(json)).toList();
      }
    } catch (e) {
      return data;
    }
    return data;
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
  Future<http.Response> addCourseForUser(int userId, String courseName, List<Hole> holes) async {
  final uri = Uri.parse("$baseUri/Courses/user/$userId");
  late http.Response response;

  // コースデータを作成
  Course newCourse = Course(
    courseId: null,
    courseName: courseName,
    holes: holes,
  );

  try {
    response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        // 必要に応じて認証トークンを追加する
        //'Authorization': 'Bearer <your_access_token>',
      },
      body: json.encode(newCourse.toJson()),
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

}
