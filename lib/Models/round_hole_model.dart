import 'shot_model.dart';

class RoundHole {
  final int? roundHoleId;
  final int roundId;
  final int holeId;
  final int stroke;
  final int? putts;
  final int? penaltyStrokes;
  final bool fairwayHit; // nullableから変更しデフォルトを設定
  final bool greenInRegulation; // nullableから変更しデフォルトを設定
  final String weatherConditions;
  final int bunkerShotsCount; // nullableから変更しデフォルトを設定
  final bool bunkerRecovery; // nullableから変更しデフォルトを設定
  final bool scrambleAttempted; // nullableから変更しデフォルトを設定
  final bool scrambleSuccess; // nullableから変更しデフォルトを設定
  final List<Shot> shots;

  RoundHole({
    this.roundHoleId,
    required this.roundId,
    required this.holeId,
    required this.stroke,
    this.putts,
    this.penaltyStrokes,
    this.fairwayHit = false, // デフォルト値を設定
    this.greenInRegulation = false, // デフォルト値を設定
    required this.weatherConditions,
    this.bunkerShotsCount = 0, // デフォルト値を設定
    this.bunkerRecovery = false, // デフォルト値を設定
    this.scrambleAttempted = false, // デフォルト値を設定
    this.scrambleSuccess = false, // デフォルト値を設定
    List<Shot>? shots, // null許容をし、空リストを代入
  }) : shots = shots ?? [];

  factory RoundHole.fromJson(Map<String, dynamic> json) {
    var shotsFromJson = json['shots'] as List<dynamic>? ?? [];
    List<Shot> shotList = shotsFromJson.map((shotJson) => Shot.fromJson(shotJson)).toList();

    return RoundHole(
      roundHoleId: json['roundHoleId'],
      roundId: json['roundId'],
      holeId: json['holeId'],
      stroke: json['stroke'],
      putts: json['putts'],
      penaltyStrokes: json['penaltyStrokes'],
      fairwayHit: json['fairwayHit'] ?? false,
      greenInRegulation: json['greenInRegulation'] ?? false,
      weatherConditions: json['weatherConditions'],
      bunkerShotsCount: json['bunkerShotsCount'] ?? 0,
      bunkerRecovery: json['bunkerRecovery'] ?? false,
      scrambleAttempted: json['scrambleAttempted'] ?? false,
      scrambleSuccess: json['scrambleSuccess'] ?? false,
      shots: shotList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roundHoleId': roundHoleId,
      'roundId': roundId,
      'holeId': holeId,
      'stroke': stroke,
      'putts': putts,
      'penaltyStrokes': penaltyStrokes,
      'fairwayHit': fairwayHit,
      'greenInRegulation': greenInRegulation,
      'weatherConditions': weatherConditions,
      'bunkerShotsCount': bunkerShotsCount,
      'bunkerRecovery': bunkerRecovery,
      'scrambleAttempted': scrambleAttempted,
      'scrambleSuccess': scrambleSuccess,
      'shots': shots.map((shot) => shot.toJson()).toList(),
    };
  }
}
