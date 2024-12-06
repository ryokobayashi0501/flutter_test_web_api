class RoundHoleDto {
  int stroke;
  int putts;
  int? penaltyStrokes;
  bool? fairwayHit;
  bool? greenInRegulation;
  String weatherConditions;
  int? bunkerShotsCount;
  bool? bunkerRecovery;
  bool? scrambleAttempted;
  bool? scrambleSuccess;

  RoundHoleDto({
    required this.stroke,
    required this.putts,
    this.penaltyStrokes,
    this.fairwayHit,
    this.greenInRegulation,
    required this.weatherConditions,
    this.bunkerShotsCount,
    this.bunkerRecovery,
    this.scrambleAttempted,
    this.scrambleSuccess,
  });

  Map<String, dynamic> toJson() {
    return {
      'stroke': stroke,
      'putts': putts,
      if (penaltyStrokes != null) 'penaltyStrokes': penaltyStrokes,
      if (fairwayHit != null) 'fairwayHit': fairwayHit,
      if (greenInRegulation != null) 'greenInRegulation': greenInRegulation,
      'weatherConditions': weatherConditions,
      if (bunkerShotsCount != null) 'bunkerShotsCount': bunkerShotsCount,
      if (bunkerRecovery != null) 'bunkerRecovery': bunkerRecovery,
      if (scrambleAttempted != null) 'scrambleAttempted': scrambleAttempted,
      if (scrambleSuccess != null) 'scrambleSuccess': scrambleSuccess,
    };
  }
}
