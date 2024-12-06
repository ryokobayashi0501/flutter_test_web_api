import 'dart:convert';
import 'package:flutter_web_api/Models/DTOs/shot_dto_model.dart';
import 'package:flutter_web_api/Models/course_model.dart';
import 'package:flutter_web_api/Models/DTOs/round_hole_dto_model.dart';
import 'package:flutter_web_api/Models/round_hole_model.dart';
import 'package:flutter_web_api/Models/round_model.dart';
import 'package:flutter_web_api/Models/shot_model.dart';
import 'package:flutter_web_api/Models/user_model.dart';
import 'package:flutter_web_api/Models/DTOs/users_model.dart';
import 'package:flutter_web_api/Models/hole_model.dart';

import 'package:http/http.dart' as http;

class RoundHandler 
{
  final String baseUri = "https://localhost:7287/api";
  final Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<List<Round>> getRoundsByUserId(int userId) async {
  final uri = Uri.parse("$baseUri/Rounds/user/$userId/rounds");
  List<Round> rounds = [];

  try {
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      print('Received JSON data: $jsonData'); // デバッグ用

      rounds = jsonData.map((json) => Round.fromJson(json)).toList();
      print('Parsed rounds: $rounds'); // デバッグ用
    } else {
      print("Failed to fetch rounds: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching rounds: $e");
  } 
  return rounds;
}

Future<http.Response> deleteRound(int roundId) async {
  final uri = Uri.parse("$baseUri/Rounds/$roundId");
  late http.Response response;

  try {
    response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      print("Round deleted successfully.");
    } else {
      print("Failed to delete round: ${response.statusCode}");
    }
  } catch (e) {
    print("Error deleting round: $e");
    rethrow;
  }

  return response;
}

// ラウンドをユーザーに追加するAPI
// ラウンドをユーザーに追加するAPI
Future<http.Response> addRoundForUser(int userId, int courseId) async {
  final uri = Uri.parse('$baseUri/Rounds');
  late http.Response response;

  try {
    // リクエストボディを作成（RoundHoles は含めない）
    Map<String, dynamic> requestBody = {
      "userId": userId,
      "courseId": courseId,
      "roundDate": DateTime.now().toIso8601String(), // 必要であれば日付を追加
    };

    response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 201) {
      print("Round added successfully.");
    } else {
      print("Failed to add round: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  } catch (e) {
    print("Error adding round: $e");
    rethrow;
  }

  return response;
}



  // // ユーザーにRoundHoleを追加するメソッド
  // Future<http.Response> addRoundHoleForUser(int userId, int roundId, int holeId, RoundHoleDto roundHoleDto) async {
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

  // RoundIDからRoundHolesを取得するメソッド
  Future<List<RoundHole>> getRoundHolesByRoundId(int userId, int roundId) async {
    final uri = Uri.parse("$baseUri/users/$userId/rounds/$roundId/holes");
    List<RoundHole> roundHoles = [];

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        roundHoles = jsonData.map((json) => RoundHole.fromJson(json)).toList();
      } else {
        print("Failed to fetch RoundHoles: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error fetching RoundHoles: $e");
    }

    return roundHoles;
  }

// RoundHole の取得メソッド
  Future<http.Response> getRoundHoleForUser(int userId, int roundId, int holeId) async {
    final url = '$baseUri/users/$userId/rounds/$roundId/holes/$holeId';
    final response = await http.get(Uri.parse(url));
    return response;
  }

  // RoundHole の更新メソッド
Future<http.Response> updateRoundHoleForUser(int userId, int roundId, int holeId, RoundHoleDto roundHoleDto) async {
  final url = '$baseUri/users/$userId/rounds/$roundId/holes/$holeId';
  final body = json.encode(roundHoleDto.toJson());
  final headers = {'Content-Type': 'application/json'};

  try {
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    // HTTPステータスコードのチェック
    if (response.statusCode != 200 && response.statusCode != 204) {
      // 200: OK, 204: No Contentが成功の指標とします
      throw Exception('Failed to update RoundHole. Status code: ${response.statusCode}');
    }

    return response;
  } catch (e) {
    print('Exception occurred while updating RoundHole: $e');
    throw Exception('Failed to update RoundHole: $e');
  }
}


  // RoundHole の追加メソッド
  Future<http.Response> addRoundHoleForUser(int userId, int roundId, int holeId, RoundHoleDto roundHoleDto) async {
    final url = '$baseUri/users/$userId/rounds/$roundId/holes/$holeId';
    final body = json.encode({
      'stroke': roundHoleDto.stroke,
      'putts': roundHoleDto.putts,
      'weatherConditions': roundHoleDto.weatherConditions
    });
    final headers = {'Content-Type': 'application/json'};

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
    return response;
  }


  // Shotを追加するメソッド
  Future<http.Response> addShot(int userId, int roundId, int holeId, int roundHoleId, ShotDto shotDto) async {
    final uri = Uri.parse('$baseUri/users/$userId/rounds/$roundId/holes/$holeId/roundHoles/$roundHoleId/shots');
    late http.Response response;

    try {
      response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(shotDto.toJson()),
      );

      if (response.statusCode == 201) {
        print("Shot added successfully.");
      } else {
        print("Failed to add Shot: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error adding Shot: $e");
      rethrow;
    }

    return response;
  }

  // This method sends a bulk insert request to the backend API to add all shots at once.
  Future<http.Response> bulkPostShots({
    required int userId,
    required int roundId,
    required int holeId,
    required int roundHoleId,
    required List<ShotDto> shots,
  }) async {
    final String url = '$baseUri/shots/bulk/$userId/$roundId/$holeId/$roundHoleId';

    // Converting the list of shots to JSON
    List<Map<String, dynamic>> shotsData = shots.map((shot) => shot.toJson()).toList();

    try {
      // Create the post request with the shots JSON
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(shotsData),
      );

      // Debugging output to ensure correct request
      print("Request URL: $url");
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print("Request Body: ${jsonEncode(shotsData)}");

      // Return the response to the caller
      return response;
    } catch (e) {
      // Handle errors by logging and throwing an exception
      print("Error while sending bulk shots: $e");
      throw Exception('Failed to post shots in bulk');
    }
  }

  // RoundHoleIdからShotを取得するメソッド
  Future<List<ShotDto>> getShotsByRoundHoleId(int userId, int roundId, int holeId, int roundHoleId) async {
    final uri = Uri.parse("$baseUri/users/$userId/rounds/$roundId/holes/$holeId/roundHoles/$roundHoleId/shots");
    List<ShotDto> shots = [];

    try {
      // Send the GET request
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        // If successful, parse the shots from the response body
        final List<dynamic> jsonData = json.decode(response.body);
        shots = jsonData.map((json) => ShotDto.fromJson(json)).toList();
      } else {
        // Handle errors
        print("Failed to fetch Shots: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      // Handle any exceptions that occur
      print("Error fetching Shots: $e");
    }

    // Return the list of shots
    return shots;
  }
}