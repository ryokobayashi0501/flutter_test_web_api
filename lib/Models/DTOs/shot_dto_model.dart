import 'dart:convert';
import 'package:flutter_web_api/Models/Enums/BallDirection.dart';
import 'package:flutter_web_api/Models/Enums/BallHeight.dart';
import 'package:flutter_web_api/Models/Enums/ClubUsed.dart';
import 'package:flutter_web_api/Models/Enums/Lie.dart';
import 'package:flutter_web_api/Models/Enums/PuttResult.dart';
import 'package:flutter_web_api/Models/Enums/PuttType.dart';
import 'package:flutter_web_api/Models/Enums/ShotResult.dart';
import 'package:flutter_web_api/Models/Enums/ShotType.dart';

class ShotDto {
  final int shotNumber; // Shot number in the sequence
  final int distance; // Distance covered in the shot
  final int remainingDistance; // Remaining distance after the shot
  final ClubUsed clubUsed; // The club used for the shot
  final BallDirection ballDirection; // The direction of the ball
  final Enum shotType; // Either ShotType or PuttType
  final String shotTypeName; // Indicates ShotType or PuttType
  final BallHeight ballHeight; // Height of the ball trajectory
  final Lie lie; // Lie of the ball (e.g., Tee, Fairway, etc.)
  final Enum shotResult; // Either ShotResult or PuttResult
  final String shotResultName; // Indicates ShotResult or PuttResult
  final String? notes; // Optional notes for the shot

  ShotDto({
    required this.shotNumber,
    required this.distance,
    required this.remainingDistance,
    required this.clubUsed,
    required this.ballDirection,
    required this.shotType,
    required this.shotTypeName,
    required this.ballHeight,
    required this.lie,
    required this.shotResult,
    required this.shotResultName,
    this.notes,
  });

  // Factory constructor to create ShotDto from JSON
  factory ShotDto.fromJson(Map<String, dynamic> json) {
    Enum getShotTypeFromJson() {
      if (json['shotTypeName'] == 'PuttType') {
        return PuttType.values.firstWhere((e) => e.toString().split('.').last == json['shotType']);
      } else if (json['shotTypeName'] == 'ShotType') {
        return ShotType.values.firstWhere((e) => e.toString().split('.').last == json['shotType']);
      } else {
        throw ArgumentError("Invalid shotTypeName: ${json['shotTypeName']}");
      }
    }

    Enum getShotResultFromJson() {
      if (json['shotResultName'] == 'PuttResult') {
        return PuttResult.values.firstWhere((e) => e.toString().split('.').last == json['shotResult']);
      } else if (json['shotResultName'] == 'ShotResult') {
        return ShotResult.values.firstWhere((e) => e.toString().split('.').last == json['shotResult']);
      } else {
        throw ArgumentError("Invalid shotResultName: ${json['shotResultName']}");
      }
    }

    return ShotDto(
      shotNumber: json['shotNumber'] as int,
      distance: json['distance'] as int,
      remainingDistance: json['remainingDistance'] as int,
      clubUsed: ClubUsed.values.firstWhere((e) => e.toString().split('.').last == json['clubUsed']),
      ballDirection: BallDirection.values.firstWhere((e) => e.toString().split('.').last == json['ballDirection']),
      shotType: getShotTypeFromJson(),
      shotTypeName: json['shotTypeName'] as String,
      ballHeight: BallHeight.values.firstWhere((e) => e.toString().split('.').last == json['ballHeight']),
      lie: Lie.values.firstWhere((e) => e.toString().split('.').last == json['lie']),
      shotResult: getShotResultFromJson(),
      shotResultName: json['shotResultName'] as String,
      notes: json['notes'] as String?,
    );
  }

  // Convert ShotDto to JSON
  Map<String, dynamic> toJson() {
    return {
      'shotNumber': shotNumber,
      'distance': distance,
      'remainingDistance': remainingDistance,
      'clubUsed': clubUsed.toString().split('.').last,
      'ballDirection': ballDirection.toString().split('.').last,
      'shotType': shotType.toString().split('.').last,
      'shotTypeName': shotType is PuttType ? 'PuttType' : 'ShotType',
      'ballHeight': ballHeight.toString().split('.').last,
      'lie': lie.toString().split('.').last,
      'shotResult': shotResult.toString().split('.').last,
      'shotResultName': shotResult is PuttResult ? 'PuttResult' : 'ShotResult',
      'notes': notes,
    };
  }

  // Debugging utility to convert ShotDto to JSON string format
  String toJsonString() {
    return json.encode(toJson());
  }
}

