class Shot {
  final int? shotId;
  final int roundHoleId;
  final int shotNumber;
  final double distance;
  final String clubUsed;
  final String ballDirection;
  final String shotType;
  final String ballHeight;
  final String lie;
  final String shotResult;
  final String? notes;

  Shot({
    this.shotId,
    required this.roundHoleId,
    required this.shotNumber,
    required this.distance,
    required this.clubUsed,
    required this.ballDirection,
    required this.shotType,
    required this.ballHeight,
    required this.lie,
    required this.shotResult,
    this.notes,
  });

  factory Shot.fromJson(Map<String, dynamic> json) {
    return Shot(
      shotId: json['shotId'],
      roundHoleId: json['roundHoleId'],
      shotNumber: json['shotNumber'],
      distance: (json['distance'] as num).toDouble(),
      clubUsed: json['clubUsed'],
      ballDirection: json['ballDirection'],
      shotType: json['shotType'],
      ballHeight: json['ballHeight'],
      lie: json['lie'],
      shotResult: json['shotResult'],
      notes: json['notes'] ?? '', // notes が null の場合、空文字に
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shotId': shotId,
      'roundHoleId': roundHoleId,
      'shotNumber': shotNumber,
      'distance': distance,
      'clubUsed': clubUsed,
      'ballDirection': ballDirection,
      'shotType': shotType,
      'ballHeight': ballHeight,
      'lie': lie,
      'shotResult': shotResult,
      'notes': notes ?? '', // null の場合、空文字として送信
    };
  }
}
